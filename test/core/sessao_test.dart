import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_bl/core/sessao.dart';
import 'package:mobile_bl/data/auth_repo.dart';

class RepoFalso implements AuthRepo {
  RepoFalso({this.nivel = 'ceo', this.senhaOk = true, this.teamsOk = true});
  final String nivel;
  final bool senhaOk;
  final bool teamsOk;
  bool saiu = false;
  bool logado = false;
  @override
  bool get temSessaoBl => logado;
  @override
  Future<void> entrarBl(String e, String s) async {
    if (!senhaOk) throw const ErroLogin();
    logado = true;
  }

  @override
  Future<Map<String, dynamic>?> lerPerfil() async => {
    'nome': 'William Ramos',
    'nivel': nivel,
  };
  @override
  Future<void> entrarTeams() async {
    if (!teamsOk) throw Exception('x');
  }

  @override
  Future<void> sair() async {
    saiu = true;
    logado = false;
  }
}

void main() {
  test('CEO entra', () async {
    final s = Sessao(RepoFalso());
    await s.entrar('a@b.com', '12345678');
    expect(s.estado, EstadoSessao.dentro);
    expect(s.perfil!['nome'], 'William Ramos');
  });
  test('quem não é CEO é recusado e desconectado', () async {
    final r = RepoFalso(nivel: 'diretor');
    final s = Sessao(r);
    await s.entrar('a@b.com', '12345678');
    expect(s.estado, EstadoSessao.fora);
    expect(s.erro, 'Acesso exclusivo para CEO');
    expect(r.saiu, isTrue);
  });
  test('senha errada', () async {
    final s = Sessao(RepoFalso(senhaOk: false));
    await s.entrar('a@b.com', 'x');
    expect(s.erro, 'E-mail ou senha incorretos');
    expect(s.estado, EstadoSessao.fora);
  });
  test('falha no TEAM\'s desconecta', () async {
    final r = RepoFalso(teamsOk: false);
    final s = Sessao(r);
    await s.entrar('a@b.com', '12345678');
    expect(s.erro, 'Não foi possível entrar no TEAM\'s');
    expect(r.saiu, isTrue);
  });
  test('iniciar com sessão guardada de CEO entra direto', () async {
    final r = RepoFalso()..logado = true;
    final s = Sessao(r);
    await s.iniciar();
    expect(s.estado, EstadoSessao.dentro);
  });
}
