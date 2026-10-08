import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../config/bancos.dart';
import 'modelos.dart';

typedef Sinal = void Function(String evento, Map<String, dynamic> dados);

abstract class TeamsApi {
  String get meuId;
  Future<Equipe> equipe();
  Future<List<Canal>> canais();
  Future<Map<String, int>> pendencias(List<String> setores);
  Future<Map<String, String>> presencas();
  Future<void> definirPresenca(String status);
  Future<String> abrirDireta(String outro);
  Future<String> abrirSetor(String setorId, String nome);
  Future<String> criarGrupo(String nome, List<String> membros);
  Future<void> adicionarMembros(String canal, List<String> ids);
  Future<void> marcarLido(String canal);
  Future<void> marcarVisto(String oQue);
  Future<void> silenciar(String canal, bool valor);
  Future<List<Mensagem>> mensagens(String canal);
  Future<String> enviar(
    String canal, {
    String tipo = 'texto',
    String? corpo,
    Map<String, dynamic>? meta,
    String? respondeA,
    List<String> mencoes = const [],
  });
  Future<void> editar(String id, String corpo);
  Future<void> apagar(String id);
  Future<void> enviarArquivo(
    String canal,
    Uint8List bytes,
    String nome,
    String tipo,
    String contentType,
  );
  Future<String> linkAnexo(String caminho);
  Future<List<Aviso>> avisos();
  Future<Set<String>> avisosVistos();
  Future<Map<String, int>> contagemVistos();
  Future<void> criarAviso({
    required String nivel,
    required String titulo,
    String? corpo,
    String? setorId,
  });
  Future<void> darVisto(String aviso);
  Future<List<Pedido>> pedidos();
  Future<String> criarPedido({
    required String titulo,
    String? descricao,
    required String responsavel,
    DateTime? prazo,
    String? canal,
    String? mensagemId,
  });
  Future<void> mudarStatusPedido(String id, String status);
  Future<List<Reuniao>> reunioes();
  Future<void> criarReuniao({
    required String titulo,
    String? pauta,
    required DateTime inicio,
    DateTime? fim,
    String? canal,
    required List<String> convidados,
  });
  Future<void> confirmarReuniao(String id);
  Stream<String> mudancas();
  void ouvirSinais(Sinal aoChegar);
  Future<void> enviarSinal(
    String destino,
    String evento,
    Map<String, dynamic> dados,
  );
  Future<String> iniciarChamada(String canal, String tipo);
  Future<void> entrarChamada(String chamada);
  Future<void> sairChamada(String chamada);
  Future<void> marcarChamadaAtendida(String chamada);
  Future<void> encerrarChamada(String chamada);
  Future<Map<String, String>?> passeLigacao(String canal);
  Future<List<Empresa>> buscarEmpresas(String texto);
  Future<Map<String, Empresa>> empresas(List<String> ids);
}

class TeamsApiSupabase implements TeamsApi {
  TeamsApiSupabase(this.tm, this.bl);
  final SupabaseClient tm;
  final SupabaseClient bl;
  RealtimeChannel? _canalDados;
  RealtimeChannel? _canalSinal;
  final _mudancas = StreamController<String>.broadcast();

  @override
  String get meuId => tm.auth.currentUser!.id;

  Future<List> _bl(String caminho) async {
    final r = await http.get(
      Uri.parse('${Bancos.blUrl}/rest/v1/$caminho'),
      headers: {
        'apikey': Bancos.blChave,
        'Authorization': 'Bearer ${bl.auth.currentSession?.accessToken}',
      },
    );
    if (r.statusCode >= 300) throw Exception('BL ${r.statusCode}');
    return jsonDecode(r.body) as List;
  }

  @override
  Future<Equipe> equipe() async {
    final res = await Future.wait([
      _bl(
        'usuarios_internos?select=id,nome,email,nivel,foto_url&ativo=eq.true&order=nome&limit=1000',
      ),
      _bl('usuario_setores?select=usuario_id,setor_id,principal&limit=5000'),
      _bl(
        'setores?select=id,nome&eh_departamento=eq.true&order=nome&limit=200',
      ),
    ]);
    final setores = res[2]
        .map(
          (s) => Setor(
            id: s['id'] as String,
            nome: (s['nome'] as String?) ?? 'Setor',
          ),
        )
        .toList();
    final ids = setores.map((s) => s.id).toSet();
    final rel = <String, List<String>>{};
    for (final r in res[1]) {
      final sid = r['setor_id'] as String?;
      if (sid == null || !ids.contains(sid)) continue;
      (rel[r['usuario_id'] as String] ??= []).add(sid);
    }
    final pessoas = res[0]
        .map(
          (u) =>
              Pessoa.deMapa({...u as Map, 'setores': rel[u['id']] ?? const []}),
        )
        .toList();
    return Equipe(pessoas: pessoas, setores: setores);
  }

  @override
  Future<List<Canal>> canais() async {
    final r = await tm.rpc('chat_resumo');
    return ((r as List?) ?? const [])
        .map((c) => Canal.deMapa(c as Map))
        .toList();
  }

  @override
  Future<Map<String, int>> pendencias(List<String> setores) async {
    final r = Map<String, dynamic>.from(
      await tm.rpc('chat_pendencias', params: {'p_setores': setores}) as Map,
    );
    return r.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  @override
  Future<Map<String, String>> presencas() async {
    final r = await tm.from('chat_presenca').select('usuario_id,status');
    return {
      for (final x in r) x['usuario_id'] as String: x['status'] as String,
    };
  }

  @override
  Future<void> definirPresenca(String status) async {
    final agora = DateTime.now().toUtc().toIso8601String();
    await tm.from('chat_presenca').upsert({
      'usuario_id': meuId,
      'status': status,
      'visto_por_ultimo_em': agora,
      'atualizado_em': agora,
    });
  }

  @override
  Future<String> abrirDireta(String outro) async =>
      await tm.rpc('chat_abrir_direta', params: {'p_outro': outro}) as String;

  @override
  Future<String> abrirSetor(String setorId, String nome) async => await tm.rpc(
    'chat_abrir_setor',
    params: {'p_setor': setorId, 'p_nome': nome},
  ) as String;

  @override
  Future<String> criarGrupo(String nome, List<String> membros) async =>
      await tm.rpc(
        'chat_criar_grupo',
        params: {'p_nome': nome, 'p_membros': membros},
      ) as String;

  @override
  Future<void> adicionarMembros(String canal, List<String> ids) => tm
      .from('chat_canal_membro')
      .insert(
        ids
            .map((u) => {'canal_id': canal, 'usuario_id': u, 'papel': 'membro'})
            .toList(),
      );

  @override
  Future<void> marcarLido(String canal) =>
      tm.rpc('chat_marcar_lido', params: {'p_canal': canal});

  @override
  Future<void> marcarVisto(String oQue) =>
      tm.rpc('chat_marcar_visto', params: {'p_o_que': oQue});

  @override
  Future<void> silenciar(String canal, bool valor) => tm
      .from('chat_canal_membro')
      .update({'silenciado': valor})
      .eq('canal_id', canal)
      .eq('usuario_id', meuId);

  @override
  Future<List<Mensagem>> mensagens(String canal) async {
    final r = await tm
        .from('chat_mensagem')
        .select(
          'id,canal_id,autor_id,tipo,corpo,meta,responde_a,criada_em,editada_em,excluida_em,chat_anexo(id,tipo,nome,url,tamanho,transcricao),chat_recibo(usuario_id,lido_em)',
        )
        .eq('canal_id', canal)
        .isFilter('excluida_em', null)
        .order('criada_em', ascending: false)
        .limit(300);
    return r.reversed.map((m) => Mensagem.deMapa(m)).toList();
  }

  @override
  Future<String> enviar(
    String canal, {
    String tipo = 'texto',
    String? corpo,
    Map<String, dynamic>? meta,
    String? respondeA,
    List<String> mencoes = const [],
  }) async {
    final r = await tm
        .from('chat_mensagem')
        .insert({
          'canal_id': canal,
          'autor_id': meuId,
          'tipo': tipo,
          'corpo': corpo,
          'meta': meta ?? {},
          'responde_a': respondeA,
        })
        .select('id')
        .single();
    final id = r['id'] as String;
    if (mencoes.isNotEmpty) {
      await tm
          .from('chat_mencao')
          .insert(
            mencoes.map((u) => {'mensagem_id': id, 'usuario_id': u}).toList(),
          );
    }
    unawaited(
      tm
          .from('chat_evento')
          .insert({
            'direcao': 'SAIDA',
            'tipo': 'mensagem',
            'origem': 'mobile-ceo',
            'canal_id': canal,
            'mensagem_id': id,
            'payload': {'tipo': tipo},
          })
          .then((_) {}, onError: (_) {}),
    );
    return id;
  }

  @override
  Future<void> editar(String id, String corpo) => tm
      .from('chat_mensagem')
      .update({
        'corpo': corpo,
        'editada_em': DateTime.now().toUtc().toIso8601String(),
      })
      .eq('id', id);

  @override
  Future<void> apagar(String id) => tm
      .from('chat_mensagem')
      .update({'excluida_em': DateTime.now().toUtc().toIso8601String()})
      .eq('id', id);

  @override
  Future<void> enviarArquivo(
    String canal,
    Uint8List bytes,
    String nome,
    String tipo,
    String contentType,
  ) async {
    if (bytes.length > 100 * 1048576) throw Exception('grande');
    var ext = nome.contains('.')
        ? nome.split('.').last.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '')
        : 'bin';
    if (ext.isEmpty) ext = 'bin';
    if (ext.length > 5) ext = ext.substring(0, 5);
    final caminho = '$canal/${const Uuid().v4()}.$ext';
    await tm.storage
        .from('chat-anexo')
        .uploadBinary(
          caminho,
          bytes,
          fileOptions: FileOptions(contentType: contentType),
        );
    final id = await enviar(
      canal,
      tipo: tipo == 'audio' ? 'audio' : 'arquivo',
      corpo: tipo == 'audio' ? 'Áudio' : nome,
    );
    await tm.from('chat_anexo').insert({
      'mensagem_id': id,
      'tipo': tipo,
      'nome': nome,
      'url': caminho,
      'tamanho': bytes.length,
    });
  }

  @override
  Future<String> linkAnexo(String caminho) =>
      tm.storage.from('chat-anexo').createSignedUrl(caminho, 3600);

  @override
  Future<List<Aviso>> avisos() async {
    final r = await tm
        .from('chat_aviso')
        .select('id,titulo,corpo,nivel,escopo,setor_id,autor_id,criado_em')
        .order('criado_em', ascending: false)
        .limit(100);
    return r.map((a) => Aviso.deMapa(a)).toList();
  }

  @override
  Future<Set<String>> avisosVistos() async {
    final r = await tm
        .from('chat_aviso_visto')
        .select('aviso_id')
        .eq('usuario_id', meuId);
    return r.map((x) => x['aviso_id'] as String).toSet();
  }

  @override
  Future<Map<String, int>> contagemVistos() async {
    final r = await tm.from('chat_aviso_visto').select('aviso_id');
    final m = <String, int>{};
    for (final x in r) {
      m[x['aviso_id'] as String] = (m[x['aviso_id']] ?? 0) + 1;
    }
    return m;
  }

  @override
  Future<void> criarAviso({
    required String nivel,
    required String titulo,
    String? corpo,
    String? setorId,
  }) => tm.from('chat_aviso').insert({
    'nivel': nivel,
    'titulo': titulo,
    'corpo': corpo,
    'escopo': setorId == null ? 'central' : 'setor',
    'setor_id': setorId,
    'autor_id': meuId,
  });

  @override
  Future<void> darVisto(String aviso) => tm.from('chat_aviso_visto').upsert({
    'aviso_id': aviso,
    'usuario_id': meuId,
  });

  @override
  Future<List<Pedido>> pedidos() async {
    final r = await tm
        .from('chat_pedido')
        .select(
          'id,titulo,descricao,solicitante_id,responsavel_id,status,prazo,criado_em,canal_id',
        )
        .order('criado_em', ascending: false)
        .limit(300);
    return r.map((p) => Pedido.deMapa(p)).toList();
  }

  @override
  Future<String> criarPedido({
    required String titulo,
    String? descricao,
    required String responsavel,
    DateTime? prazo,
    String? canal,
    String? mensagemId,
  }) async {
    final prazoTxt = prazo == null
        ? null
        : '${prazo.year.toString().padLeft(4, '0')}-${prazo.month.toString().padLeft(2, '0')}-${prazo.day.toString().padLeft(2, '0')}';
    final r = await tm
        .from('chat_pedido')
        .insert({
          'canal_id': canal,
          'mensagem_id': mensagemId,
          'titulo': titulo,
          'descricao': descricao,
          'solicitante_id': meuId,
          'responsavel_id': responsavel,
          'prazo': prazoTxt,
        })
        .select('id')
        .single();
    final id = r['id'] as String;
    if (canal != null) {
      await enviar(
        canal,
        tipo: 'pedido',
        corpo: titulo,
        meta: {
          'pedido_id': id,
          'responsavel_id': responsavel,
          'prazo': prazoTxt,
        },
        mencoes: [responsavel],
      );
    }
    return id;
  }

  @override
  Future<void> mudarStatusPedido(String id, String status) => tm
      .from('chat_pedido')
      .update({
        'status': status,
        'atualizado_em': DateTime.now().toUtc().toIso8601String(),
      })
      .eq('id', id);

  @override
  Future<List<Reuniao>> reunioes() async {
    final r = await tm
        .from('chat_reuniao')
        .select(
          'id,titulo,pauta,inicio,fim,criado_por,canal_id,chat_reuniao_participante(usuario_id,confirmado)',
        )
        .order('inicio', ascending: true)
        .limit(200);
    return r.map((x) => Reuniao.deMapa(x)).toList();
  }

  @override
  Future<void> criarReuniao({
    required String titulo,
    String? pauta,
    required DateTime inicio,
    DateTime? fim,
    String? canal,
    required List<String> convidados,
  }) async {
    final r = await tm
        .from('chat_reuniao')
        .insert({
          'titulo': titulo,
          'pauta': pauta,
          'inicio': inicio.toUtc().toIso8601String(),
          'fim': fim?.toUtc().toIso8601String(),
          'canal_id': canal,
          'criado_por': meuId,
        })
        .select('id')
        .single();
    final ids = {meuId, ...convidados};
    await tm
        .from('chat_reuniao_participante')
        .insert(
          ids
              .map(
                (u) => {
                  'reuniao_id': r['id'],
                  'usuario_id': u,
                  'confirmado': u == meuId,
                },
              )
              .toList(),
        );
  }

  @override
  Future<void> confirmarReuniao(String id) => tm
      .from('chat_reuniao_participante')
      .update({'confirmado': true})
      .eq('reuniao_id', id)
      .eq('usuario_id', meuId);

  @override
  Stream<String> mudancas() {
    if (_canalDados == null) {
      final ch = tm.channel('teams-mobile');
      for (final t in [
        'chat_mensagem',
        'chat_presenca',
        'chat_canal',
        'chat_canal_membro',
        'chat_pedido',
        'chat_aviso',
        'chat_aviso_visto',
        'chat_anexo',
        'chat_reuniao_participante',
        'chat_recibo',
      ]) {
        ch.onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: t,
          callback: (_) => _mudancas.add(t),
        );
      }
      _canalDados = ch..subscribe();
    }
    return _mudancas.stream;
  }

  @override
  void ouvirSinais(Sinal aoChegar) {
    _canalSinal?.unsubscribe();
    _canalSinal =
        tm
            .channel(
              'tm-u-$meuId',
              opts: const RealtimeChannelConfig(private: true),
            )
            .onBroadcast(
              event: '*',
              callback: (p) {
                final ev = (p['event'] ?? '').toString();
                final dados = Map<String, dynamic>.from(
                  (p['payload'] as Map?) ?? const {},
                );
                aoChegar(ev, dados);
              },
            )
          ..subscribe();
  }

  @override
  Future<void> enviarSinal(
    String destino,
    String evento,
    Map<String, dynamic> dados,
  ) async {
    final token = tm.auth.currentSession?.accessToken;
    if (token == null) return;
    await http.post(
      Uri.parse('${Bancos.teamsUrl}/realtime/v1/api/broadcast'),
      headers: {
        'Content-Type': 'application/json',
        'apikey': Bancos.teamsChave,
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'messages': [
          {
            'topic': 'tm-u-$destino',
            'event': evento,
            'payload': {...dados, 'de': meuId},
            'private': true,
          },
        ],
      }),
    );
  }

  @override
  Future<String> iniciarChamada(String canal, String tipo) async {
    final r = await tm
        .from('chat_chamada')
        .insert({'canal_id': canal, 'tipo': tipo, 'iniciada_por': meuId})
        .select('id')
        .single();
    final id = r['id'] as String;
    await entrarChamada(id);
    return id;
  }

  @override
  Future<void> entrarChamada(String chamada) =>
      tm.from('chat_chamada_participante').insert({
        'chamada_id': chamada,
        'usuario_id': meuId,
        'entrou_em': DateTime.now().toUtc().toIso8601String(),
      });

  @override
  Future<void> sairChamada(String chamada) => tm
      .from('chat_chamada_participante')
      .update({'saiu_em': DateTime.now().toUtc().toIso8601String()})
      .eq('chamada_id', chamada)
      .eq('usuario_id', meuId);

  @override
  Future<void> marcarChamadaAtendida(String chamada) => tm
      .from('chat_chamada')
      .update({'atendida_em': DateTime.now().toUtc().toIso8601String()})
      .eq('id', chamada);

  @override
  Future<void> encerrarChamada(String chamada) => tm
      .from('chat_chamada')
      .update({'encerrada_em': DateTime.now().toUtc().toIso8601String()})
      .eq('id', chamada);

  @override
  Future<Map<String, String>?> passeLigacao(String canal) async {
    final r = await tm.functions.invoke(
      'teams-ligacao-token',
      body: {'canal_id': canal},
    );
    final d = r.data as Map?;
    if (d?['ok'] != true) return null;
    return {'url': d!['url'] as String, 'token': d['token'] as String};
  }

  @override
  Future<List<Empresa>> buscarEmpresas(String texto) async {
    final t = texto.replaceAll(RegExp(r'[,()*]'), ' ').trim();
    if (t.length < 2) return const [];
    final q = Uri.encodeQueryComponent(
      '(razao_social.ilike.*$t*,nome_fantasia.ilike.*$t*,cnpj.ilike.*$t*)',
    );
    final r = await _bl(
      'empresa?select=id,razao_social,nome_fantasia,cnpj,regime_tributario&or=$q&order=razao_social&limit=20',
    );
    return r.map((e) => Empresa.deMapa(e as Map)).toList();
  }

  @override
  Future<Map<String, Empresa>> empresas(List<String> ids) async {
    if (ids.isEmpty) return const {};
    final r = await _bl(
      'empresa?select=id,razao_social,nome_fantasia,cnpj,regime_tributario&id=in.(${ids.toSet().join(',')})',
    );
    return {for (final e in r) (e as Map)['id'] as String: Empresa.deMapa(e)};
  }
}
