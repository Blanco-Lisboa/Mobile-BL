import 'package:flutter/foundation.dart';

import '../data/auth_repo.dart';

enum EstadoSessao { carregando, fora, dentro }

class Sessao extends ChangeNotifier {
  Sessao(this.repo);
  final AuthRepo repo;
  EstadoSessao estado = EstadoSessao.carregando;
  String? erro;
  Map<String, dynamic>? perfil;

  Future<void> iniciar() async {
    if (repo.temSessaoBl) {
      await _concluir();
    } else {
      estado = EstadoSessao.fora;
      notifyListeners();
    }
  }

  Future<void> entrar(String email, String senha) async {
    erro = null;
    try {
      await repo.entrarBl(email, senha);
    } on ErroLogin {
      erro = 'E-mail ou senha incorretos';
      estado = EstadoSessao.fora;
      notifyListeners();
      return;
    }
    await _concluir();
  }

  Future<void> _concluir() async {
    try {
      final p = await repo.lerPerfil();
      if (p == null || p['nivel'] != 'ceo') {
        await repo.sair();
        erro = 'Acesso exclusivo para CEO';
        estado = EstadoSessao.fora;
        notifyListeners();
        return;
      }
      perfil = p;
      await repo.entrarTeams();
      estado = EstadoSessao.dentro;
    } catch (_) {
      await repo.sair();
      erro ??= 'Não foi possível entrar no TEAM\'s';
      estado = EstadoSessao.fora;
    }
    notifyListeners();
  }

  Future<void> sair() async {
    await repo.sair();
    perfil = null;
    estado = EstadoSessao.fora;
    notifyListeners();
  }
}
