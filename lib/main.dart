import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/bancos.dart';
import 'core/sessao.dart';
import 'data/auth_repo.dart';
import 'data/perfil_repo.dart';
import 'data/teams/teams_api.dart';

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: Bancos.blUrl, publishableKey: Bancos.blChave);
  final bl = Supabase.instance.client;
  final teams = SupabaseClient(
    Bancos.teamsUrl,
    Bancos.teamsChave,
    authOptions: const AuthClientOptions(autoRefreshToken: true),
  );
  final sessao = Sessao(AuthRepoSupabase(bl, teams));
  runApp(
    AppBl(
      sessao: sessao,
      perfil: PerfilRepoSupabase(bl),
      criarTeams: () => TeamsApiSupabase(teams, bl),
    ),
  );
  await sessao.iniciar();
}
