import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_bl/features/teams/chamada.dart';
import 'package:mobile_bl/features/teams/tela_teams.dart';
import 'package:mobile_bl/features/teams/teams_store.dart';
import 'teams_falso.dart';

Future<(TeamsFalso, TeamsStore, ChamadaController)> _montar(WidgetTester t) async {
  final api = TeamsFalso();
  final s = TeamsStore(api);
  final c = ChamadaController(s);
  await s.iniciar();
  c.iniciar();
  t.view.physicalSize = const Size(400, 860);
  t.view.devicePixelRatio = 1;
  await t.pumpWidget(MaterialApp(builder: (_, f) => CamadaChamada(controle: c, child: f!), home: TelaTeams(store: s, chamada: c)));
  await t.pumpAndSettle();
  return (api, s, c);
}

void main() {
  tearDown(() => TestWidgetsFlutterBinding.instance.platformDispatcher.views.first.resetPhysicalSize());

  testWidgets('entra no TEAM\'s, fica online e lista conversas com não lidas', (t) async {
    final (api, s, _) = await _montar(t);
    expect(api.presencaDefinida, ['online']);
    expect(find.text('Lucas Lisboa'), findsOneWidget);
    expect(find.text('2'), findsWidgets);
    expect(s.naoLidasTotal, 2);
  });

  testWidgets('abre conversa e envia mensagem com menção', (t) async {
    final (api, _, _) = await _montar(t);
    await t.tap(find.text('Lucas Lisboa'));
    await t.pumpAndSettle();
    expect(find.text('Fechei o contrato'), findsOneWidget);
    await t.enterText(find.byKey(const Key('mensagem')), 'Conferi. @Paulo Andrade emite hoje?');
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('enviar')));
    await t.pumpAndSettle();
    expect(api.enviadas.single['corpo'], 'Conferi. @Paulo Andrade emite hoje?');
    expect(api.enviadas.single['mencoes'], ['pa']);
  });

  testWidgets('avisos: dar visto grava no banco', (t) async {
    final (api, _, _) = await _montar(t);
    await t.tap(find.byKey(const Key('aba-1')));
    await t.pumpAndSettle();
    expect(find.text('Fechamento antecipado'), findsOneWidget);
    await t.tap(find.text('Dar visto'));
    await t.pumpAndSettle();
    expect(api.vistosDados, ['a1']);
    expect(find.text('✓ Visto'), findsOneWidget);
  });

  testWidgets('pedidos: lista os pedidos para mim', (t) async {
    await _montar(t);
    await t.tap(find.byKey(const Key('aba-2')));
    await t.pumpAndSettle();
    expect(find.text('Emitir guia'), findsOneWidget);
    expect(find.text('Aberto'), findsOneWidget);
  });

  testWidgets('chamada recebida mostra atender e recusa avisa quem ligou', (t) async {
    final (api, _, c) = await _montar(t);
    api.ouvinte!('ligar', {'chamada': 'x1', 'canal': 'c1', 'tipo': 'voz', 'de': 'll', 'nome': 'Lucas Lisboa', 'canal_nome': 'Lucas Lisboa', 'participantes': ['ll', 'eu']});
    await t.pump();
    expect(c.estado, EstadoChamada.tocando);
    expect(find.text('Atender'), findsOneWidget);
    await t.tap(find.text('Recusar'));
    await t.pumpAndSettle();
    expect(c.estado, EstadoChamada.nenhuma);
    expect(api.sinais.last[0], 'll');
    expect(api.sinais.last[1], 'recusar');
  });

  testWidgets('ligação ocupada responde ocupado', (t) async {
    final (api, _, c) = await _montar(t);
    api.ouvinte!('ligar', {'chamada': 'x1', 'canal': 'c1', 'tipo': 'voz', 'de': 'll', 'participantes': ['ll', 'eu']});
    api.ouvinte!('ligar', {'chamada': 'x2', 'canal': 'c2', 'tipo': 'voz', 'de': 'pa', 'participantes': ['pa', 'eu']});
    await t.pump();
    expect(c.id, 'x1');
    expect(api.sinais.last[1], 'ocupado');
    await c.recusar();
    await t.pumpAndSettle();
  });

  testWidgets('topo troca status para Não me interrompam e Grupos mostra departamentos', (t) async {
    final (api, s, _) = await _montar(t);
    await t.tap(find.byKey(const Key('meu-status')));
    await t.pumpAndSettle();
    await t.tap(find.text('Não me interrompam').last);
    await t.pumpAndSettle();
    expect(api.presencaDefinida.last, 'nao_interromper');
    expect(s.presencas['eu'], 'nao_interromper');
    await t.tap(find.byKey(const Key('sub-grupos')));
    await t.pumpAndSettle();
    expect(find.text('Societário'), findsWidgets);
  });
}
