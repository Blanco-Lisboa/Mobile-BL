# App BL CEO (Mobile-BL) — desenho aprovado

Data: 07/10/2026 · Dono: William · Repositório: github.com/Blanco-Lisboa/Mobile-BL (PÚBLICO — nunca segredo no código)
Telas aprovadas: `.superpowers/brainstorm/.../content/todas-as-telas-v2.html` (16 telas).

## Objetivo
App de celular exclusivo dos CEOs da BL. Começa com um módulo (TEAM's); outros módulos entram depois como cards.

## Decisões do William
- Só entra usuário com nível **CEO**.
- Visual: identidade do CEO (azul-marinho #0A1B30/#011D3A, dourado #EDB449), login escuro com o logo estático, dentro do app claro e limpo, letra Inter, leve, estilo iPhone atual.
- Início: só o card TEAM's; sem saudação nem data; bolinha do perfil abre "Meu perfil".
- TEAM's com tudo do TEAM's completo, menos Senha (cofre) e Decisão do CEO (fora por enquanto).
- Distribuição: **versão web instalável** (Safari → "Adicionar à Tela de Início"; Android pelo Chrome). Sem custo de licença. App nativo fica para depois.
- Mesmas tabelas/funções que os Javas: nada de tabela própria do app.

## Arquitetura
- **Flutter** (um código só), compilado para **web** (PWA: manifest, ícones, service worker). Depois o mesmo código gera Android/iPhone nativos.
- **Dois bancos Supabase, só pela chave pública + login do usuário:**
  1. **BL central** `wfqcoocfastgsfgegpcm` — login (e-mail/senha), nível, perfil, presença do perfil, pessoas, setores, clientes.
     - `auth` e-mail/senha → `rpc/meu_perfil_ler` (se `nivel` ≠ `ceo` → sai e recusa).
     - Meu perfil: `meu_perfil_ler`, `meu_perfil_salvar`, `presenca_minha_ler`, `presenca_minha_definir`, edge `ceo-trocar-senha` (iguais ao painel Java).
  2. **TEAM's** `lhqjfdexfexpmnoqhbyv` — conversas.
     - Entrada: edge `teams-entrar` com `{bl_token}` → devolve sessão do TEAM's (usuário-sombra com selo interno).
     - Conversas: `chat_resumo`, `chat_pendencias`, `chat_marcar_visto`, `chat_marcar_lido`, `chat_abrir_direta`, `chat_abrir_setor`, `chat_criar_grupo`, tabelas `chat_mensagem`, `chat_mencao`, `chat_anexo`, `chat_canal_membro` (silenciar), `chat_evento`.
     - Avisos `chat_aviso` (+ nível) e `chat_aviso_visto`; Pedidos `chat_pedido`; Reuniões `chat_reuniao` + `chat_reuniao_participante`; presença `chat_presenca`.
     - Anexos/áudio: bucket privado `chat-anexo` (links assinados).
     - Chamadas: edge `teams-ligacao-token` (LiveKit) + `chat_chamada`/`chat_chamada_participante`.
     - Tempo real: Realtime (push), **nunca** consulta repetida.
- Cliente citado: guarda só o `cliente_id`; nome/CNPJ lidos da BL na hora (regra da base única).

## Telas (16)
Login · Início · Meu perfil · Conversas (Entrada/Anteriores/Grupos/Setores, busca, não lidas) · Conversa (texto, responder, @menção, cliente, anexo, foto, câmera, áudio, editar, apagar, copiar, criar pedido, recibo) · Ações (+) · Chamada · Chamada chegando · Avisos · Novo aviso · Pedidos (filtros e status) · Novo pedido · Reuniões (confirmar, entrar) · Marcar reunião · Nova conversa/grupo (filtro setor/nível) · Detalhes (silenciar, participantes, arquivos).

## Organização do código (unidades pequenas)
- `lib/config/` endereços e chaves públicas dos 2 bancos.
- `lib/core/` tema (cores/letras), roteamento, sessão dos 2 bancos.
- `lib/data/` um repositório por assunto (auth, perfil, conversas, mensagens, avisos, pedidos, reuniões, anexos, chamadas, pessoas, clientes) — só eles falam com o banco.
- `lib/features/<tela>/` telas e componentes.
- Testes: unidade para repositórios (com banco falso) e widget para telas; teste real no navegador contra o banco antes de dizer "pronto".

## Segurança
- Só chave pública no código; nenhum segredo no repositório público.
- O bloqueio "só CEO" é do app; a proteção real dos dados é a RLS dos bancos (TEAM's já restrito a internos e a quem participa).
- Sessões guardadas só no aparelho; sair limpa as duas.

## Pendências fora do app (não bloqueiam começar)
- Repontar o TEAM's do **Java CEO** para o banco do TEAM's (Agent BL) — senão o Java CEO não vê o que o celular grava.
- Endereço HTTPS para publicar a versão web (decidir: Vercel ou Cloudflare Pages).
- Aviso no celular (push web): configurar depois da primeira versão funcionando.
- Chamadas: LiveKit precisa estar configurado no banco do TEAM's (`teams-ligacao-token` responde "ligacao_nao_configurada" se faltar).

## Ordem de entrega
1. Base do projeto + tema + login (só CEO) + início + Meu perfil.
2. Conversas + conversa (texto, tempo real, lidas).
3. Anexos, fotos, áudio, menção, cliente, responder/editar/apagar.
4. Avisos, Pedidos, Reuniões, Nova conversa/grupo, Detalhes.
5. Chamadas.
6. Publicar a versão web instalável.
