import 'dart:async';
import 'dart:typed_data';

import 'package:mobile_bl/data/teams/modelos.dart';
import 'package:mobile_bl/data/teams/teams_api.dart';

class TeamsFalso implements TeamsApi {
  final enviadas = <Map<String, dynamic>>[];
  final pedidosCriados = <Map<String, dynamic>>[];
  final vistosDados = <String>[];
  final sinais = <List<dynamic>>[];
  final presencaDefinida = <String>[];
  final mudancasCtrl = StreamController<String>.broadcast();
  Sinal? ouvinte;
  final msgs = <String, List<Mensagem>>{};

  @override
  String get meuId => 'eu';

  @override
  Future<Equipe> equipe() async => const Equipe(
    pessoas: [
      Pessoa(id: 'eu', nome: 'William Ramos', nivel: 'ceo', setores: ['s1']),
      Pessoa(id: 'll', nome: 'Lucas Lisboa', nivel: 'diretor', setores: ['s1']),
      Pessoa(
        id: 'pa',
        nome: 'Paulo Andrade',
        nivel: 'assistente',
        setores: ['s1'],
      ),
    ],
    setores: [Setor(id: 's1', nome: 'Societário')],
  );

  @override
  Future<List<Canal>> canais() async => [
    Canal(
      id: 'c1',
      tipo: 'direta',
      membros: ['eu', 'll'],
      naoLidas: 2,
      ultima: Ultima(
        autorId: 'll',
        corpo: 'Fechei o contrato',
        tipo: 'texto',
        em: DateTime.now(),
      ),
    ),
    Canal(id: 'c2', tipo: 'setor', setorId: 's1', nome: 'Societário'),
  ];

  @override
  Future<Map<String, int>> pendencias(List<String> setores) async => {
    'avisos': 1,
    'pedidos': 0,
    'reunioes': 0,
  };
  @override
  Future<Map<String, String>> presencas() async => {'ll': 'online'};
  @override
  Future<void> definirPresenca(String status) async =>
      presencaDefinida.add(status);
  @override
  Future<String> abrirDireta(String outro) async => 'c1';
  @override
  Future<String> abrirSetor(String setorId, String nome) async => 'c2';
  @override
  Future<String> criarGrupo(String nome, List<String> membros) async => 'g1';
  @override
  Future<void> adicionarMembros(String canal, List<String> ids) async {}
  @override
  Future<void> marcarLido(String canal) async {}
  @override
  Future<void> marcarVisto(String oQue) async {}
  @override
  Future<void> silenciar(String canal, bool valor) async {}
  @override
  Future<List<Mensagem>> mensagens(String canal) async =>
      msgs[canal] ??
      [
        Mensagem(
          id: 'm1',
          canalId: canal,
          autorId: 'll',
          corpo: 'Fechei o contrato',
          criadaEm: DateTime.now(),
        ),
      ];
  @override
  Future<String> enviar(
    String canal, {
    String tipo = 'texto',
    String? corpo,
    Map<String, dynamic>? meta,
    String? respondeA,
    List<String> mencoes = const [],
  }) async {
    enviadas.add({
      'canal': canal,
      'tipo': tipo,
      'corpo': corpo,
      'meta': meta,
      'responde_a': respondeA,
      'mencoes': mencoes,
    });
    return 'nova';
  }

  @override
  Future<void> editar(String id, String corpo) async {}
  @override
  Future<void> apagar(String id) async {}
  @override
  Future<void> enviarArquivo(
    String canal,
    Uint8List bytes,
    String nome,
    String tipo,
    String contentType,
  ) async {}
  @override
  Future<String> linkAnexo(String caminho) async => 'https://exemplo/$caminho';
  @override
  Future<List<Aviso>> avisos() async => [
    Aviso(
      id: 'a1',
      titulo: 'Fechamento antecipado',
      nivel: 'urgente',
      escopo: 'central',
      autorId: 'll',
      criadoEm: DateTime.now(),
    ),
  ];
  @override
  Future<Set<String>> avisosVistos() async => vistosDados.toSet();
  @override
  Future<Map<String, int>> contagemVistos() async => {};
  @override
  Future<void> criarAviso({
    required String nivel,
    required String titulo,
    String? corpo,
    String? setorId,
  }) async {}
  @override
  Future<void> darVisto(String aviso) async => vistosDados.add(aviso);
  @override
  Future<List<Pedido>> pedidos() async => [
    Pedido(
      id: 'p1234567',
      titulo: 'Emitir guia',
      solicitanteId: 'll',
      responsavelId: 'eu',
      status: 'aberto',
      criadoEm: DateTime.now(),
    ),
  ];
  @override
  Future<String> criarPedido({
    required String titulo,
    String? descricao,
    required String responsavel,
    DateTime? prazo,
    String? canal,
    String? mensagemId,
  }) async {
    pedidosCriados.add({
      'titulo': titulo,
      'responsavel': responsavel,
      'canal': canal,
    });
    return 'p2';
  }

  @override
  Future<void> mudarStatusPedido(String id, String status) async {}
  @override
  Future<List<Reuniao>> reunioes() async => [];
  @override
  Future<void> criarReuniao({
    required String titulo,
    String? pauta,
    required DateTime inicio,
    DateTime? fim,
    String? canal,
    required List<String> convidados,
  }) async {}
  @override
  Future<void> confirmarReuniao(String id) async {}
  @override
  Stream<String> mudancas() => mudancasCtrl.stream;
  @override
  void ouvirSinais(Sinal aoChegar) => ouvinte = aoChegar;
  @override
  Future<void> enviarSinal(
    String destino,
    String evento,
    Map<String, dynamic> dados,
  ) async => sinais.add([destino, evento, dados]);
  @override
  Future<String> iniciarChamada(String canal, String tipo) async => 'ch1';
  @override
  Future<void> entrarChamada(String chamada) async {}
  @override
  Future<void> sairChamada(String chamada) async {}
  @override
  Future<void> marcarChamadaAtendida(String chamada) async {}
  @override
  Future<void> encerrarChamada(String chamada) async {}
  @override
  Future<Map<String, String>?> passeLigacao(String canal) async => null;
  @override
  Future<List<Empresa>> buscarEmpresas(String texto) async => [
    const Empresa(
      id: 'e1',
      nome: 'Julia Xavier ME',
      cnpj: '00.000.000/0001-00',
    ),
  ];
  @override
  Future<Map<String, Empresa>> empresas(List<String> ids) async => {};
  @override
  Future<String?> chavePush() async => null;
  @override
  Future<void> salvarInscricao(
    Map<String, dynamic> sub,
    List<String> setores,
  ) async {}
}
