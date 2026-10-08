import 'dart:async';
import 'package:flutter/foundation.dart';
import 'sons.dart';
import '../../data/teams/modelos.dart';
import '../../data/teams/teams_api.dart';

class TeamsStore extends ChangeNotifier {
  TeamsStore(this.api);
  final TeamsApi api;

  bool pronto = false;
  Equipe equipe = const Equipe();
  List<Canal> canais = [];
  Map<String, String> presencas = {};
  Map<String, int> pend = {'avisos': 0, 'pedidos': 0, 'reunioes': 0};
  final Map<String, List<Mensagem>> mensagens = {};
  final Map<String, Empresa> empresas = {};
  List<Aviso> avisos = [];
  Set<String> vistos = {};
  Map<String, int> contagemVistos = {};
  List<Pedido> pedidos = [];
  List<Reuniao> reunioes = [];
  String? canalAberto;
  StreamSubscription<String>? _sub;
  final Map<String, Timer> _adiar = {};

  String get eu => api.meuId;
  int get naoLidasTotal => canais.where((c) => !c.silenciado).fold(0, (s, c) => s + c.naoLidas);
  List<String> get meusSetores => equipe.pessoa(eu).setores;

  Future<void> iniciar() async {
    if (pronto) return;
    final r = await Future.wait([api.equipe(), api.canais(), api.presencas()]);
    equipe = r[0] as Equipe;
    canais = r[1] as List<Canal>;
    presencas = r[2] as Map<String, String>;
    await api.definirPresenca('online');
    presencas[eu] = 'online';
    await _carregarPend();
    pronto = true;
    notifyListeners();
    _sub = api.mudancas().listen(_mudou);
  }

  void _mudou(String tabela) {
    _adiar[tabela]?.cancel();
    _adiar[tabela] = Timer(const Duration(milliseconds: 250), () => _recarregar(tabela));
  }

  Future<void> _recarregar(String t) async {
    try {
      switch (t) {
        case 'chat_mensagem':
        case 'chat_anexo':
        case 'chat_recibo':
          final antes = naoLidasTotal;
          canais = await api.canais();
          final c = canalAberto;
          if (c != null) {
            mensagens[c] = await api.mensagens(c);
            await api.marcarLido(c);
            canais.where((x) => x.id == c).forEach((x) => x.naoLidas = 0);
            await _resolverEmpresas(mensagens[c]!);
          }
          if (t == 'chat_mensagem' && naoLidasTotal > antes) Sons.i.mensagem();
        case 'chat_canal':
        case 'chat_canal_membro':
          canais = await api.canais();
        case 'chat_presenca':
          presencas = await api.presencas();
        case 'chat_aviso':
        case 'chat_aviso_visto':
          await _carregarPend();
          if (avisos.isNotEmpty) await carregarAvisos();
        case 'chat_pedido':
          await _carregarPend();
          if (pedidos.isNotEmpty) await carregarPedidos();
        case 'chat_reuniao_participante':
          await _carregarPend();
          await carregarReunioes();
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _carregarPend() async {
    try {
      pend = await api.pendencias(meusSetores);
    } catch (_) {}
  }

  Canal? canal(String id) {
    for (final c in canais) {
      if (c.id == id) return c;
    }
    return null;
  }

  String nomeCanal(Canal c) {
    if (c.tipo == 'direta') {
      final outro = c.membros.firstWhere((m) => m != eu, orElse: () => eu);
      return equipe.pessoa(outro).nome;
    }
    if (c.tipo == 'setor') return c.nome ?? equipe.nomeSetor(c.setorId);
    return c.nome ?? 'Grupo';
  }

  String? outroDaDireta(Canal c) => c.tipo == 'direta' ? c.membros.firstWhere((m) => m != eu, orElse: () => eu) : null;

  List<String> alvos(Canal c) {
    if (c.tipo == 'setor') return equipe.doSetor(c.setorId).map((p) => p.id).where((x) => x != eu).toList();
    return c.membros.where((x) => x != eu).toList();
  }

  List<String> participantes(Canal c) => c.tipo == 'setor' ? equipe.doSetor(c.setorId).map((p) => p.id).toList() : c.membros;

  Future<void> abrirCanal(String id) async {
    canalAberto = id;
    final c = canal(id);
    if (c != null) c.naoLidas = 0;
    notifyListeners();
    mensagens[id] = await api.mensagens(id);
    await _resolverEmpresas(mensagens[id]!);
    notifyListeners();
    await api.marcarLido(id);
  }

  void fecharCanal() => canalAberto = null;

  Future<void> _resolverEmpresas(List<Mensagem> ms) async {
    final faltam = ms.map((m) => m.meta['cliente_id'] as String?).whereType<String>().where((e) => !empresas.containsKey(e)).toList();
    if (faltam.isEmpty) return;
    try {
      empresas.addAll(await api.empresas(faltam));
    } catch (_) {}
  }

  Future<String> abrirDireta(String pessoa) async {
    final id = await api.abrirDireta(pessoa);
    canais = await api.canais();
    return id;
  }

  Future<String> abrirSetor(Setor s) async {
    final id = await api.abrirSetor(s.id, s.nome);
    canais = await api.canais();
    return id;
  }

  Future<String> criarGrupo(String nome, List<String> ids) async {
    final id = await api.criarGrupo(nome, ids);
    canais = await api.canais();
    return id;
  }

  List<String> mencoesDe(String texto) => equipe.pessoas.where((p) => texto.contains('@${p.nome}')).map((p) => p.id).toList();

  Future<void> enviarTexto(String canal, String texto, {String? respondeA}) async {
    final lista = mensagens[canal] ??= [];
    final tmp = Mensagem(id: 'tmp-${DateTime.now().microsecondsSinceEpoch}', canalId: canal, autorId: eu, corpo: texto,
        respondeA: respondeA, criadaEm: DateTime.now(), provisoria: true);
    lista.add(tmp);
    notifyListeners();
    try {
      await api.enviar(canal, corpo: texto, respondeA: respondeA, mencoes: mencoesDe(texto));
    } catch (_) {
      lista.remove(tmp);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> citarCliente(String canal, Empresa e, String comentario) async {
    empresas[e.id] = e;
    await api.enviar(canal, corpo: comentario.isEmpty ? 'Cliente citado' : comentario, meta: {'cliente_id': e.id}, mencoes: mencoesDe(comentario));
  }

  Future<void> mudarStatus(String st) async {
    await api.definirPresenca(st);
    presencas[eu] = st;
    notifyListeners();
  }

  Future<void> silenciar(Canal c) async {
    await api.marcarLido(c.id);
    await api.silenciar(c.id, !c.silenciado);
    c.silenciado = !c.silenciado;
    notifyListeners();
  }

  Future<void> carregarAvisos() async {
    final r = await Future.wait([api.avisos(), api.avisosVistos(), api.contagemVistos()]);
    final setores = meusSetores.toSet();
    avisos = (r[0] as List<Aviso>).where((a) => a.escopo != 'setor' || setores.contains(a.setorId) || a.autorId == eu).toList();
    vistos = r[1] as Set<String>;
    contagemVistos = r[2] as Map<String, int>;
    notifyListeners();
  }

  Future<void> darVisto(String id) async {
    await api.darVisto(id);
    vistos.add(id);
    await _carregarPend();
    notifyListeners();
  }

  Future<void> carregarPedidos() async {
    pedidos = await api.pedidos();
    if ((pend['pedidos'] ?? 0) > 0) {
      await api.marcarVisto('pedidos');
      await _carregarPend();
    }
    notifyListeners();
  }

  Future<void> carregarReunioes() async {
    reunioes = await api.reunioes();
    if ((pend['reunioes'] ?? 0) > 0) {
      await api.marcarVisto('reunioes');
      await _carregarPend();
    }
    notifyListeners();
  }

  Future<void> sair() async {
    await _sub?.cancel();
    try {
      await api.definirPresenca('offline');
    } catch (_) {}
  }

  @override
  void dispose() {
    _sub?.cancel();
    for (final t in _adiar.values) {
      t.cancel();
    }
    super.dispose();
  }
}
