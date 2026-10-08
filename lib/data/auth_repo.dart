import 'package:supabase_flutter/supabase_flutter.dart';

class ErroLogin implements Exception {
  const ErroLogin();
}

abstract class AuthRepo {
  bool get temSessaoBl;
  Future<void> entrarBl(String email, String senha);
  Future<Map<String, dynamic>?> lerPerfil();
  Future<void> entrarTeams();
  Future<void> sair();
}

class AuthRepoSupabase implements AuthRepo {
  AuthRepoSupabase(this.bl, this.teams);
  final SupabaseClient bl;
  final SupabaseClient teams;

  @override
  bool get temSessaoBl => bl.auth.currentSession != null;

  @override
  Future<void> entrarBl(String email, String senha) async {
    try {
      await bl.auth.signInWithPassword(email: email.trim(), password: senha);
    } on AuthException {
      throw const ErroLogin();
    }
  }

  @override
  Future<Map<String, dynamic>?> lerPerfil() async {
    final r = await bl.rpc('meu_perfil_ler');
    return r == null ? null : Map<String, dynamic>.from(r as Map);
  }

  @override
  Future<void> entrarTeams() async {
    final token = bl.auth.currentSession?.accessToken;
    final r = await teams.functions.invoke(
      'teams-entrar',
      body: {'bl_token': token},
    );
    final d = r.data as Map;
    if (d['ok'] != true) throw Exception('teams');
    await teams.auth.setSession(d['refresh_token'] as String);
  }

  @override
  Future<void> sair() async {
    try {
      await teams.auth.signOut();
    } catch (_) {}
    try {
      await bl.auth.signOut();
    } catch (_) {}
  }
}
