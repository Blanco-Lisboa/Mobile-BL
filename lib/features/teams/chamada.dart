import 'dart:async';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;
import '../../core/tema.dart';
import '../../data/teams/modelos.dart';
import 'comuns.dart';
import 'teams_store.dart';

enum EstadoChamada { nenhuma, chamando, tocando, conectando, ativa }

class ChamadaController extends ChangeNotifier {
  ChamadaController(this.store);
  final TeamsStore store;

  EstadoChamada estado = EstadoChamada.nenhuma;
  String? id;
  String? canalId;
  String tipo = 'voz';
  String nome = '';
  String? de;
  bool dono = false;
  bool mudo = false;
  bool camera = false;
  bool tela = false;
  List<String> participantes = [];
  DateTime? inicio;
  lk.Room? sala;
  lk.EventsListener<lk.RoomEvent>? _ouvinte;
  Timer? _limite;
  Timer? _relogio;
  int recusas = 0;
  String? aviso;

  void iniciar() => store.api.ouvirSinais(_sinal);

  Duration get duracao => inicio == null ? Duration.zero : DateTime.now().difference(inicio!);

  List<(String, lk.VideoTrack?)> get quadros => [
        for (final p in sala?.remoteParticipants.values ?? const <lk.RemoteParticipant>[])
          (
            p.identity,
            p.videoTrackPublications
                .where((pub) => pub.track != null && !pub.muted)
                .map((pub) => pub.track as lk.VideoTrack)
                .firstOrNull,
          ),
      ];

  lk.VideoTrack? get videoLocal {
    for (final pub in sala?.localParticipant?.videoTrackPublications ?? const <lk.LocalTrackPublication>[]) {
      if (pub.track != null && !pub.muted && pub.source == lk.TrackSource.camera) return pub.track as lk.VideoTrack;
    }
    return null;
  }

  Future<void> ligar(Canal c, String t) async {
    if (estado != EstadoChamada.nenhuma) return;
    final alvos = store.alvos(c);
    if (alvos.isEmpty) return;
    try {
      id = await store.api.iniciarChamada(c.id, t);
    } catch (_) {
      aviso = 'Não foi possível iniciar a ligação.';
      notifyListeners();
      return;
    }
    canalId = c.id;
    tipo = t;
    nome = store.nomeCanal(c);
    dono = true;
    recusas = 0;
    participantes = [store.eu, ...alvos];
    estado = EstadoChamada.chamando;
    notifyListeners();
    if (!await _entrarSala(t == 'video')) {
      await encerrar('Não foi possível conectar');
      return;
    }
    final meuNome = store.equipe.pessoa(store.eu).nome;
    for (final u in alvos) {
      unawaited(store.api.enviarSinal(u, 'ligar', {
        'chamada': id, 'canal': c.id, 'tipo': t, 'modo': 'lk', 'nome': meuNome, 'canal_nome': c.tipo == 'direta' ? meuNome : nome, 'participantes': participantes,
      }));
    }
    _limite = Timer(const Duration(seconds: 45), () {
      if (estado == EstadoChamada.chamando) encerrar('Chamada não atendida');
    });
  }

  void _sinal(String ev, Map<String, dynamic> p) {
    if (ev == 'ligar') {
      if (estado != EstadoChamada.nenhuma) {
        store.api.enviarSinal(p['de'] as String, 'ocupado', {'chamada': p['chamada']});
        return;
      }
      id = p['chamada'] as String?;
      canalId = p['canal'] as String?;
      tipo = (p['tipo'] as String?) ?? 'voz';
      de = p['de'] as String?;
      nome = (p['canal_nome'] as String?) ?? (p['nome'] as String?) ?? store.equipe.pessoa(de).nome;
      participantes = ((p['participantes'] as List?) ?? [de]).map((e) => e.toString()).toList();
      dono = false;
      estado = EstadoChamada.tocando;
      notifyListeners();
      _limite = Timer(const Duration(seconds: 45), () {
        if (estado == EstadoChamada.tocando) _limpar();
      });
      return;
    }
    if (p['chamada'] != id) return;
    final quem = p['de'] as String?;
    switch (ev) {
      case 'entrou':
        if (estado == EstadoChamada.tocando) return;
        if (quem != null && !participantes.contains(quem)) participantes.add(quem);
        if (estado == EstadoChamada.chamando) {
          estado = EstadoChamada.ativa;
          inicio ??= DateTime.now();
          _limite?.cancel();
          _comecarRelogio();
          store.api.marcarChamadaAtendida(id!);
        }
        notifyListeners();
      case 'sair':
        if (estado == EstadoChamada.tocando && quem == de) {
          _limpar();
          return;
        }
        if ((sala?.remoteParticipants.isEmpty ?? true) && estado == EstadoChamada.ativa) encerrar();
      case 'recusar':
      case 'ocupado':
        if (estado == EstadoChamada.chamando) {
          recusas++;
          if (recusas >= participantes.length - 1) encerrar(ev == 'ocupado' ? 'Ocupado' : 'Chamada recusada');
        }
    }
  }

  Future<void> atender(bool comVideo) async {
    if (estado != EstadoChamada.tocando) return;
    _limite?.cancel();
    estado = EstadoChamada.conectando;
    notifyListeners();
    if (!await _entrarSala(comVideo)) {
      aviso = 'Não foi possível entrar na ligação.';
      await recusar();
      return;
    }
    inicio ??= DateTime.now();
    estado = EstadoChamada.ativa;
    _comecarRelogio();
    notifyListeners();
    try {
      await store.api.entrarChamada(id!);
    } catch (_) {}
    for (final u in participantes.where((u) => u != store.eu)) {
      unawaited(store.api.enviarSinal(u, 'entrou', {'chamada': id}));
    }
  }

  Future<void> recusar() async {
    final quem = de;
    final ch = id;
    await _sairSala();
    if (quem != null) unawaited(store.api.enviarSinal(quem, 'recusar', {'chamada': ch}));
    _limpar();
  }

  Future<bool> _entrarSala(bool video) async {
    final passe = await store.api.passeLigacao(canalId!).catchError((_) => null);
    if (passe == null) return false;
    final room = lk.Room(roomOptions: const lk.RoomOptions(adaptiveStream: true, dynacast: true));
    final ouv = room.createListener();
    ouv
      ..on<lk.ParticipantConnectedEvent>((_) {
        if (estado == EstadoChamada.chamando) {
          estado = EstadoChamada.ativa;
          inicio ??= DateTime.now();
          _limite?.cancel();
          _comecarRelogio();
          store.api.marcarChamadaAtendida(id!);
        }
        notifyListeners();
      })
      ..on<lk.TrackSubscribedEvent>((_) => notifyListeners())
      ..on<lk.TrackUnsubscribedEvent>((_) => notifyListeners())
      ..on<lk.TrackMutedEvent>((_) => notifyListeners())
      ..on<lk.TrackUnmutedEvent>((_) => notifyListeners())
      ..on<lk.ParticipantDisconnectedEvent>((_) {
        if (room.remoteParticipants.isEmpty && estado == EstadoChamada.ativa) {
          encerrar();
        } else {
          notifyListeners();
        }
      })
      ..on<lk.RoomDisconnectedEvent>((_) {
        if (sala == room) {
          sala = null;
          encerrar('A conexão caiu');
        }
      });
    try {
      await room.connect(passe['url']!, passe['token']!);
    } catch (_) {
      await ouv.dispose();
      return false;
    }
    sala = room;
    _ouvinte = ouv;
    try {
      await room.localParticipant?.setMicrophoneEnabled(true);
    } catch (_) {
      aviso = 'Sem acesso ao microfone.';
    }
    if (video) {
      try {
        await room.localParticipant?.setCameraEnabled(true);
        camera = true;
      } catch (_) {
        aviso = 'Sem acesso à câmera.';
      }
    }
    notifyListeners();
    return true;
  }

  Future<void> alternarMudo() async {
    mudo = !mudo;
    await sala?.localParticipant?.setMicrophoneEnabled(!mudo);
    notifyListeners();
  }

  Future<void> alternarCamera() async {
    try {
      await sala?.localParticipant?.setCameraEnabled(!camera);
      camera = !camera;
    } catch (_) {
      aviso = 'Sem acesso à câmera.';
    }
    notifyListeners();
  }

  Future<void> alternarTela() async {
    try {
      await sala?.localParticipant?.setScreenShareEnabled(!tela);
      tela = !tela;
    } catch (_) {
      aviso = 'Este aparelho não permite compartilhar a tela.';
    }
    notifyListeners();
  }

  void _comecarRelogio() {
    _relogio?.cancel();
    _relogio = Timer.periodic(const Duration(seconds: 1), (_) => notifyListeners());
  }

  Future<void> encerrar([String? motivo]) async {
    if (estado == EstadoChamada.nenhuma) return;
    final ch = id;
    final canal = canalId;
    final eraDono = dono;
    final teve = inicio;
    final t = tipo;
    final outros = participantes.where((u) => u != store.eu).toList();
    await _sairSala();
    _limpar();
    if (ch == null) return;
    for (final u in outros) {
      unawaited(store.api.enviarSinal(u, 'sair', {'chamada': ch}));
    }
    try {
      await store.api.sairChamada(ch);
    } catch (_) {}
    if (eraDono && canal != null) {
      final dur = teve == null ? 0 : DateTime.now().difference(teve).inSeconds;
      final mm = '${(dur ~/ 60).toString().padLeft(2, '0')}:${(dur % 60).toString().padLeft(2, '0')}';
      try {
        await store.api.encerrarChamada(ch);
        await store.api.enviar(canal, tipo: 'sistema', corpo: '${t == 'video' ? '🎥 Chamada de vídeo' : '📞 Chamada de voz'} · ${motivo ?? mm}', meta: {'chamada_id': ch});
      } catch (_) {}
    }
  }

  Future<void> _sairSala() async {
    final r = sala;
    sala = null;
    await _ouvinte?.dispose();
    _ouvinte = null;
    try {
      await r?.disconnect();
    } catch (_) {}
  }

  void _limpar() {
    _limite?.cancel();
    _relogio?.cancel();
    estado = EstadoChamada.nenhuma;
    id = null;
    canalId = null;
    de = null;
    inicio = null;
    mudo = false;
    camera = false;
    tela = false;
    participantes = [];
    notifyListeners();
  }
}

class CamadaChamada extends StatelessWidget {
  const CamadaChamada({super.key, required this.controle, required this.child});
  final ChamadaController controle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controle,
      builder: (context, _) {
        final c = controle;
        if (c.aviso != null) {
          final a = c.aviso!;
          c.aviso = null;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final m = ScaffoldMessenger.maybeOf(context);
            m?.showSnackBar(SnackBar(content: Text(a), behavior: SnackBarBehavior.floating));
          });
        }
        return Stack(children: [
          child,
          if (c.estado != EstadoChamada.nenhuma) Positioned.fill(child: _TelaChamada(c: c)),
        ]);
      },
    );
  }
}

class _TelaChamada extends StatelessWidget {
  const _TelaChamada({required this.c});
  final ChamadaController c;

  @override
  Widget build(BuildContext context) {
    final remotos = c.quadros;
    final local = c.videoLocal;
    final pessoa = c.dono ? null : c.store.equipe.pessoa(c.de);
    final d = c.duracao;
    final sub = switch (c.estado) {
      EstadoChamada.chamando => 'Chamando…',
      EstadoChamada.tocando => 'TEAM\'s · chamada de ${c.tipo == 'video' ? 'vídeo' : 'voz'}',
      EstadoChamada.conectando => 'Conectando…',
      _ => '${c.tipo == 'video' ? 'Vídeo' : 'Voz'} · ${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}',
    };
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment(0, -.8), radius: 1.3, colors: [Color(0xFF1B3A5E), Color(0xFF061527), Color(0xFF02080F)], stops: [0, .55, 1]),
        ),
        child: SafeArea(
          child: Stack(children: [
            if (remotos.isNotEmpty)
              Positioned.fill(
                bottom: 120,
                child: remotos.length == 1
                    ? _quadro(remotos.first)
                    : GridView.count(
                        padding: const EdgeInsets.fromLTRB(10, 40, 10, 0),
                        crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: .75,
                        children: [for (final q in remotos) ClipRRect(borderRadius: BorderRadius.circular(16), child: _quadro(q))],
                      ),
              ),
            if (remotos.isEmpty)
              Align(
                alignment: const Alignment(0, -.35),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                      BoxShadow(color: Cores.dourado.withValues(alpha: .08), spreadRadius: 10),
                      BoxShadow(color: Cores.dourado.withValues(alpha: .04), spreadRadius: 22),
                    ]),
                    child: pessoa != null
                        ? bolinhaPessoa(pessoa, tamanho: 96)
                        : Bolinha(texto: iniciais(c.nome), tamanho: 96),
                  ),
                  const SizedBox(height: 16),
                  Text(c.nome, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(sub, style: const TextStyle(color: Color(0xFF9DB0C6), fontSize: 12)),
                ]),
              ),
            if (remotos.isNotEmpty)
              Positioned(
                left: 0, right: 0, top: 12,
                child: Text(sub, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 12, shadows: [Shadow(blurRadius: 6)])),
              ),
            if (local != null)
              Positioned(
                right: 16, top: 40, width: 92, height: 128,
                child: ClipRRect(borderRadius: BorderRadius.circular(14), child: lk.VideoTrackRenderer(local, fit: lk.VideoViewFit.cover, mirrorMode: lk.VideoViewMirrorMode.mirror)),
              ),
            Positioned(left: 22, right: 22, bottom: 30, child: c.estado == EstadoChamada.tocando ? _tocando() : _controles()),
          ]),
        ),
      ),
    );
  }

  Widget _quadro((String, lk.VideoTrack?) q) {
    if (q.$2 != null) return lk.VideoTrackRenderer(q.$2!, fit: lk.VideoViewFit.cover);
    final p = c.store.equipe.pessoa(q.$1);
    return Container(
      color: const Color(0xFF0E2238),
      alignment: Alignment.center,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        bolinhaPessoa(p, tamanho: 72),
        const SizedBox(height: 10),
        Text(p.nome, style: const TextStyle(color: Colors.white, fontSize: 13)),
      ]),
    );
  }

  Widget _tocando() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _grande(Icons.call_end_rounded, Cores.vermelho, 'Recusar', c.recusar),
        if (c.tipo == 'video') _grande(Icons.call_rounded, const Color(0xFF3A4B60), 'Só voz', () => c.atender(false)),
        _grande(c.tipo == 'video' ? Icons.videocam_rounded : Icons.call_rounded, Cores.verde, 'Atender', () => c.atender(c.tipo == 'video')),
      ]);

  Widget _controles() => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        _pequeno(c.mudo ? Icons.mic_off_rounded : Icons.mic_none_rounded, 'Mudo', c.mudo, c.alternarMudo),
        _pequeno(c.camera ? Icons.videocam_rounded : Icons.videocam_off_outlined, 'Câmera', c.camera, c.alternarCamera),
        _pequeno(Icons.screen_share_outlined, 'Tela', c.tela, c.alternarTela),
        _pequeno(Icons.call_end_rounded, 'Encerrar', false, () => c.encerrar(), vermelho: true),
      ]);

  Widget _grande(IconData ic, Color cor, String t, VoidCallback f) => GestureDetector(
        onTap: f,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 62, height: 62, decoration: BoxDecoration(color: cor, shape: BoxShape.circle), child: Icon(ic, color: Colors.white, size: 26)),
          const SizedBox(height: 8),
          Text(t, style: const TextStyle(color: Color(0xFFC9D6E4), fontSize: 11)),
        ]),
      );

  Widget _pequeno(IconData ic, String t, bool ligado, VoidCallback f, {bool vermelho = false}) => GestureDetector(
        onTap: f,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: vermelho ? Cores.vermelho : (ligado ? Colors.white : Colors.white.withValues(alpha: .12)), shape: BoxShape.circle),
            child: Icon(ic, color: ligado && !vermelho ? Cores.marinho : Colors.white, size: 21),
          ),
          const SizedBox(height: 7),
          Text(t, style: const TextStyle(color: Color(0xFF9DB0C6), fontSize: 9.5)),
        ]),
      );
}
