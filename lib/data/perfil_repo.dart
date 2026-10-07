import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/bancos.dart';

abstract class PerfilRepo {
  Future<Map<String, dynamic>> ler();
  Future<String> lerStatus();
  Future<void> salvar({required String email, required String whatsapp, String? fotoDataUrl});
  Future<void> definirStatus(String status);
  Future<String?> trocarSenha(String nova);
}

class PerfilRepoSupabase implements PerfilRepo {
  PerfilRepoSupabase(this.bl);
  final SupabaseClient bl;

  @override
  Future<Map<String, dynamic>> ler() async => Map<String, dynamic>.from(await bl.rpc('meu_perfil_ler') as Map);

  @override
  Future<String> lerStatus() async {
    try {
      final r = await bl.rpc('presenca_minha_ler') as Map?;
      return ((r?['presenca'] as Map?)?['status'] as String?) ?? 'online';
    } catch (_) {
      return 'online';
    }
  }

  @override
  Future<void> salvar({required String email, required String whatsapp, String? fotoDataUrl}) async {
    final p = <String, dynamic>{'p_email': email, 'p_whatsapp': whatsapp};
    if (fotoDataUrl != null) p['p_foto_url'] = fotoDataUrl;
    await bl.rpc('meu_perfil_salvar', params: p);
  }

  @override
  Future<void> definirStatus(String status) => bl.rpc('presenca_minha_definir', params: {'p_status': status});

  @override
  Future<String?> trocarSenha(String nova) async {
    if (nova.length < 8) return 'A senha precisa de 8 ou mais caracteres';
    final token = bl.auth.currentSession?.accessToken;
    final r = await bl.functions.invoke('ceo-trocar-senha', body: {'access_token': token, 'nova_senha': nova},
        headers: {'apikey': Bancos.blChave});
    final d = r.data as Map?;
    return d?['ok'] == true ? null : (d?['erro']?.toString() ?? 'Não foi possível trocar a senha');
  }
}
