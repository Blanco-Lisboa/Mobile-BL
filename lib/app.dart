import 'package:flutter/material.dart';

import 'core/area/area_segura.dart';
import 'core/sessao.dart';
import 'core/tema.dart';
import 'data/perfil_repo.dart';
import 'data/teams/teams_api.dart';
import 'features/inicio/tela_inicio.dart';
import 'features/login/tela_login.dart';
import 'features/teams/chamada.dart';
import 'core/push/push.dart';
import 'features/teams/sons.dart';
import 'features/teams/tela_teams.dart';
import 'features/teams/teams_store.dart';

class AppBl extends StatefulWidget {
  const AppBl({
    super.key,
    required this.sessao,
    required this.perfil,
    this.criarTeams,
  });
  final Sessao sessao;
  final PerfilRepo perfil;
  final TeamsApi Function()? criarTeams;
  @override
  State<AppBl> createState() => _AppBlState();
}

class _AppBlState extends State<AppBl> {
  TeamsStore? store;
  ChamadaController? chamada;
  final _nav = GlobalKey<NavigatorState>();
  Uri? _destino = Uri.base.queryParameters.isEmpty ? null : Uri.base;

  void _irPara(Uri u) {
    final s = store;
    final c = chamada;
    final canal = u.queryParameters['canal'];
    final abaTxt = u.queryParameters['aba'];
    if (canal == null && abaTxt == null) return;
    if (s == null || c == null || !s.pronto) {
      _destino = u;
      return;
    }
    _destino = null;
    final aba = switch (abaTxt) {
      'avisos' => 1,
      'pedidos' => 2,
      'reunioes' => 3,
      _ => 0,
    };
    _nav.currentState?.popUntil((r) => r.isFirst);
    _nav.currentState?.push(
      MaterialPageRoute(
        builder: (_) => TelaTeams(
          store: s,
          chamada: c,
          abaInicial: aba,
          canalInicial: canal,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    widget.sessao.addListener(_sessaoMudou);
    _sessaoMudou();
    Push.aoAbrir((url) => _irPara(Uri.parse(url)));
  }

  @override
  void dispose() {
    widget.sessao.removeListener(_sessaoMudou);
    super.dispose();
  }

  void _sessaoMudou() {
    final dentro = widget.sessao.estado == EstadoSessao.dentro;
    if (dentro && store == null && widget.criarTeams != null) {
      final s = TeamsStore(widget.criarTeams!());
      final c = ChamadaController(s);
      setState(() {
        store = s;
        chamada = c;
      });
      s
          .iniciar()
          .then((_) {
            c.iniciar();
            final d = _destino;
            if (d != null) _irPara(d);
          })
          .catchError((_) {});
    } else if (!dentro && store != null) {
      final s = store!;
      final c = chamada!;
      setState(() {
        store = null;
        chamada = null;
      });
      c.encerrar();
      s.sair().whenComplete(s.dispose);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BL CEO',
      navigatorKey: _nav,
      debugShowCheckedModeBanner: false,
      theme: temaClaro(),
      builder: (context, filho) => Listener(
        onPointerDown: (_) {
          Sons.i.destravar();
          store?.ativarAvisos();
        },
        child: AreaSegura(
          child: chamada == null
              ? filho!
              : CamadaChamada(controle: chamada!, child: filho!),
        ),
      ),
      home: ListenableBuilder(
        listenable: widget.sessao,
        builder: (_, _) => switch (widget.sessao.estado) {
          EstadoSessao.carregando => const Scaffold(
            backgroundColor: Cores.loginFundo,
          ),
          EstadoSessao.fora => TelaLogin(sessao: widget.sessao),
          EstadoSessao.dentro => TelaInicio(
            sessao: widget.sessao,
            perfil: widget.perfil,
            teams: store,
            chamada: chamada,
          ),
        },
      ),
    );
  }
}
