import 'package:flutter/material.dart';
import 'core/sessao.dart';
import 'core/tema.dart';
import 'data/perfil_repo.dart';
import 'features/inicio/tela_inicio.dart';
import 'features/login/tela_login.dart';

class AppBl extends StatelessWidget {
  const AppBl({super.key, required this.sessao, required this.perfil});
  final Sessao sessao; final PerfilRepo perfil;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BL CEO', debugShowCheckedModeBanner: false, theme: temaClaro(),
      home: ListenableBuilder(
        listenable: sessao,
        builder: (_, _) => switch (sessao.estado) {
          EstadoSessao.carregando => const Scaffold(backgroundColor: Cores.loginFundo),
          EstadoSessao.fora => TelaLogin(sessao: sessao),
          EstadoSessao.dentro => TelaInicio(sessao: sessao, perfil: perfil),
        },
      ),
    );
  }
}
