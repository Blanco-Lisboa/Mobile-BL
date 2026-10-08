import { createClient } from "npm:@supabase/supabase-js@2";
import webpush from "npm:web-push@3.6.7";

const URL_SB = Deno.env.get("SUPABASE_URL")!;
const admin = createClient(URL_SB, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!, { auth: { persistSession: false } });

const CORS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
};
const json = (b: unknown, status = 200) =>
  new Response(JSON.stringify(b), { status, headers: { ...CORS, "Content-Type": "application/json" } });

type Vapid = { publica: string; privada: string };
let vapidCache: Vapid | null = null;

async function segredo(nome: string): Promise<string | null> {
  const r = await admin.rpc("teams_push_segredo", { p_nome: nome });
  return r.error ? null : (r.data as string | null);
}

async function vapid(): Promise<Vapid> {
  if (vapidCache) return vapidCache;
  let txt = await segredo("teams_push_vapid");
  if (!txt) {
    const k = webpush.generateVAPIDKeys();
    const novo = JSON.stringify({ publica: k.publicKey, privada: k.privateKey });
    const g = await admin.rpc("teams_push_guardar", { p_nome: "teams_push_vapid", p_valor: novo });
    txt = g.error ? await segredo("teams_push_vapid") : novo;
  }
  vapidCache = JSON.parse(txt!);
  webpush.setVapidDetails("mailto:admin@it-ia.tec.br", vapidCache!.publica, vapidCache!.privada);
  return vapidCache!;
}

const nomes = new Map<string, string>();
async function nome(id: string | null): Promise<string> {
  if (!id) return "Alguém";
  if (nomes.has(id)) return nomes.get(id)!;
  const u = await admin.auth.admin.getUserById(id);
  const n = (u.data?.user?.app_metadata?.nome as string) ?? u.data?.user?.email ?? "Alguém";
  nomes.set(id, n);
  return n;
}

function previa(tipo: string, corpo: string | null, anexoTipo?: string, meta?: Record<string, unknown>): string {
  if (tipo === "audio" || anexoTipo === "audio") return "🎤 Mensagem de voz";
  if (anexoTipo === "imagem") return "📷 Foto";
  if (tipo === "arquivo") return `📄 ${corpo ?? "Documento"}`;
  if (tipo === "pedido") return `📋 Pedido: ${corpo ?? ""}`;
  if (meta && meta["cliente_id"] && (!corpo || corpo === "Cliente citado")) return "🏢 Cliente citado";
  return corpo ?? "";
}

type Alvo = { usuario: string; titulo: string; corpo: string; tag: string; url: string; tipo: string };

async function quemVeCanal(canal: { id: string; tipo: string; setor_id: string | null }): Promise<{ id: string; silenciado: boolean }[]> {
  const membros = await admin.from("chat_canal_membro").select("usuario_id,silenciado").eq("canal_id", canal.id);
  const mapa = new Map<string, boolean>();
  for (const m of membros.data ?? []) mapa.set(m.usuario_id, !!m.silenciado);
  if (canal.tipo === "setor" && canal.setor_id) {
    const ins = await admin.from("chat_push_inscricao").select("usuario_id").contains("setores", [canal.setor_id]);
    for (const i of ins.data ?? []) if (!mapa.has(i.usuario_id)) mapa.set(i.usuario_id, false);
  }
  return [...mapa.entries()].map(([id, silenciado]) => ({ id, silenciado }));
}

async function nomeCanal(canal: { tipo: string; nome: string | null }, autor: string | null) {
  if (canal.tipo === "direta") return await nome(autor);
  return canal.nome ?? "Grupo";
}

async function eventoMensagem(id: string): Promise<Alvo[]> {
  await new Promise((r) => setTimeout(r, 1500));
  const m = await admin.from("chat_mensagem")
    .select("id,canal_id,autor_id,tipo,corpo,meta,responde_a,excluida_em,chat_anexo(tipo)").eq("id", id).maybeSingle();
  if (!m.data || m.data.excluida_em || m.data.tipo === "sistema") return [];
  const msg = m.data;
  const c = await admin.from("chat_canal").select("id,tipo,nome,setor_id").eq("id", msg.canal_id).single();
  if (!c.data) return [];
  const mencoes = new Set(((await admin.from("chat_mencao").select("usuario_id").eq("mensagem_id", id)).data ?? []).map((x) => x.usuario_id));
  let autorRespondido: string | null = null;
  if (msg.responde_a) {
    const o = await admin.from("chat_mensagem").select("autor_id").eq("id", msg.responde_a).maybeSingle();
    autorRespondido = o.data?.autor_id ?? null;
  }
  const autorNome = await nome(msg.autor_id);
  const texto = previa(msg.tipo, msg.corpo, (msg.chat_anexo as { tipo: string }[] | null)?.[0]?.tipo, msg.meta);
  const titulo = await nomeCanal(c.data, msg.autor_id);
  const corpo = c.data.tipo === "direta" ? texto : `${autorNome.split(" ")[0]}: ${texto}`;
  const alvos: Alvo[] = [];
  for (const p of await quemVeCanal(c.data)) {
    if (p.id === msg.autor_id) continue;
    const furaSilencio = mencoes.has(p.id) || autorRespondido === p.id;
    if (p.silenciado && !furaSilencio) continue;
    alvos.push({ usuario: p.id, titulo, corpo, tag: `canal-${c.data.id}`, url: `./?canal=${c.data.id}`, tipo: "mensagem" });
  }
  return alvos;
}

async function eventoChamada(id: string, perdida: boolean): Promise<Alvo[]> {
  const ch = await admin.from("chat_chamada").select("id,canal_id,tipo,iniciada_por").eq("id", id).maybeSingle();
  if (!ch.data?.canal_id) return [];
  const c = await admin.from("chat_canal").select("id,tipo,nome,setor_id").eq("id", ch.data.canal_id).single();
  if (!c.data) return [];
  const quem = await nome(ch.data.iniciada_por);
  const video = ch.data.tipo === "video";
  const grupo = c.data.tipo !== "direta";
  const entrou = new Set(((await admin.from("chat_chamada_participante").select("usuario_id,entrou_em").eq("chamada_id", id)).data ?? [])
    .filter((x) => x.entrou_em).map((x) => x.usuario_id));
  const alvos: Alvo[] = [];
  for (const p of await quemVeCanal(c.data)) {
    if (p.id === ch.data.iniciada_por) continue;
    if (perdida && entrou.has(p.id)) continue;
    const titulo = grupo ? c.data.nome ?? "Grupo" : quem;
    const corpo = perdida
      ? (video ? "📹 Chamada de vídeo perdida" : "📞 Chamada de voz perdida") + (grupo ? ` · ${quem}` : "")
      : grupo
        ? `${quem} está chamando para uma chamada ${video ? "de vídeo" : "de voz"} em grupo`
        : video ? "📹 Chamada de vídeo recebida" : "📞 Chamada de voz recebida";
    alvos.push({ usuario: p.id, titulo, corpo, tag: perdida ? `perdida-${id}` : `chamada-${id}`, url: `./?canal=${c.data.id}`, tipo: perdida ? "chamada_perdida" : "chamada" });
  }
  return alvos;
}

async function eventoAviso(id: string): Promise<Alvo[]> {
  const a = await admin.from("chat_aviso").select("id,titulo,corpo,nivel,escopo,setor_id,autor_id").eq("id", id).maybeSingle();
  if (!a.data) return [];
  let q = admin.from("chat_push_inscricao").select("usuario_id");
  if (a.data.escopo === "setor" && a.data.setor_id) q = q.contains("setores", [a.data.setor_id]);
  const us = new Set(((await q).data ?? []).map((x) => x.usuario_id));
  us.delete(a.data.autor_id);
  const rot = a.data.nivel === "urgente" ? "🔴 Urgente" : a.data.nivel === "visto" ? "Exige visto" : "Aviso";
  return [...us].map((u) => ({ usuario: u, titulo: `${rot} · ${a.data!.titulo}`, corpo: a.data!.corpo ?? "", tag: `aviso-${id}`, url: "./?aba=avisos", tipo: "aviso" }));
}

async function eventoPedido(id: string): Promise<Alvo[]> {
  const p = await admin.from("chat_pedido").select("id,titulo,solicitante_id,responsavel_id,canal_id").eq("id", id).maybeSingle();
  if (!p.data?.responsavel_id || p.data.responsavel_id === p.data.solicitante_id) return [];
  if (p.data.canal_id) return [];
  return [{ usuario: p.data.responsavel_id, titulo: `Pedido de ${await nome(p.data.solicitante_id)}`, corpo: p.data.titulo, tag: `pedido-${id}`, url: "./?aba=pedidos", tipo: "pedido" }];
}

async function eventoReuniao(id: string, usuario: string): Promise<Alvo[]> {
  const r = await admin.from("chat_reuniao").select("id,titulo,inicio,criado_por").eq("id", id).maybeSingle();
  if (!r.data || r.data.criado_por === usuario) return [];
  const quando = r.data.inicio ? new Date(r.data.inicio).toLocaleString("pt-BR", { timeZone: "America/Sao_Paulo", day: "2-digit", month: "2-digit", hour: "2-digit", minute: "2-digit" }) : "";
  return [{ usuario, titulo: `Reunião · ${r.data.titulo}`, corpo: `${await nome(r.data.criado_por)} convidou você${quando ? ` · ${quando}` : ""}`, tag: `reuniao-${id}`, url: "./?aba=reunioes", tipo: "reuniao" }];
}

async function enviar(alvos: Alvo[]) {
  if (!alvos.length) return { enviados: 0 };
  await vapid();
  const usuarios = [...new Set(alvos.map((a) => a.usuario))];
  const ins = await admin.from("chat_push_inscricao").select("id,usuario_id,plataforma,endpoint,p256dh,auth").in("usuario_id", usuarios);
  const contador = new Map<string, number>();
  for (const u of usuarios) {
    const r = await admin.rpc("teams_push_nao_lidas", { p_usuario: u });
    contador.set(u, (r.data as number) ?? 0);
  }
  let enviados = 0;
  for (const i of ins.data ?? []) {
    if (i.plataforma !== "web" || !i.p256dh || !i.auth) continue;
    for (const a of alvos.filter((x) => x.usuario === i.usuario_id)) {
      const corpo = JSON.stringify({ titulo: a.titulo, corpo: a.corpo, tag: a.tag, url: a.url, tipo: a.tipo, contador: contador.get(a.usuario) ?? 0 });
      try {
        await webpush.sendNotification({ endpoint: i.endpoint, keys: { p256dh: i.p256dh, auth: i.auth } }, corpo,
          { TTL: a.tipo === "chamada" ? 60 : 86400, urgency: "high" });
        enviados++;
      } catch (e) {
        const st = (e as { statusCode?: number }).statusCode;
        if (st === 404 || st === 410) await admin.from("chat_push_inscricao").delete().eq("id", i.id);
        else console.error("push", st, (e as Error).message);
      }
    }
  }
  return { enviados };
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method === "GET") return json({ ok: true, publica: (await vapid()).publica });
  let corpo: { evento?: string; id?: string; usuario_id?: string };
  try { corpo = await req.json(); } catch { return json({ ok: false }, 400); }
  if (corpo.evento === "chave") return json({ ok: true, publica: (await vapid()).publica });
  const g = await segredo("teams_push_gatilho");
  if (!g || req.headers.get("x-gatilho") !== g) return json({ ok: false }, 403);
  const id = String(corpo.id ?? "");
  let alvos: Alvo[] = [];
  if (corpo.evento === "mensagem") alvos = await eventoMensagem(id);
  else if (corpo.evento === "chamada") alvos = await eventoChamada(id, false);
  else if (corpo.evento === "chamada_perdida") alvos = await eventoChamada(id, true);
  else if (corpo.evento === "aviso") alvos = await eventoAviso(id);
  else if (corpo.evento === "pedido") alvos = await eventoPedido(id);
  else if (corpo.evento === "reuniao" && corpo.usuario_id) alvos = await eventoReuniao(id, corpo.usuario_id);
  return json({ ok: true, ...(await enviar(alvos)) });
});
