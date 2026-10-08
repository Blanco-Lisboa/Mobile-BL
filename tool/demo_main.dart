import 'package:flutter/material.dart';
import 'package:mobile_bl/core/tema.dart';
import 'package:mobile_bl/features/teams/chamada.dart';
import 'package:mobile_bl/features/teams/tela_conversa.dart';
import 'package:mobile_bl/features/teams/tela_teams.dart';
import 'package:mobile_bl/features/teams/teams_store.dart';

import '../test/features/teams/teams_falso.dart';

Future<void> main() async {
  final s = TeamsStore(TeamsFalso());
  await s.iniciar();
  final c = ChamadaController(s);
  final tela = Uri.base.queryParameters['tela'] ?? 'lista';
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: temaClaro(),
      home: tela == 'chat'
          ? TelaConversa(store: s, canalId: 'c1', chamada: c)
          : TelaTeams(store: s, chamada: c),
    ),
  );
}
