import 'package:flutter/material.dart';
import '../../core/sessao.dart';
import '../../core/tema.dart';
import '../../data/perfil_repo.dart';
import '../perfil/folha_perfil.dart';

class TelaInicio extends StatelessWidget {
  const TelaInicio({super.key, required this.sessao, required this.perfil});
  final Sessao sessao; final PerfilRepo perfil;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('Módulos', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -.2)),
            const Spacer(),
            GestureDetector(key: const Key('avatar'), onTap: () => abrirPerfil(context, sessao: sessao, repo: perfil), child: avatar(sessao.perfil, 32)),
          ]),
          const SizedBox(height: 18),
          Container(
            key: const Key('card-teams'),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Cores.linha),
                boxShadow: const [BoxShadow(color: Color(0x140E1A2B), blurRadius: 24, offset: Offset(0, 8), spreadRadius: -12)]),
            child: Row(children: [
              Container(width: 34, height: 34, decoration: BoxDecoration(color: Cores.marinho, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.chat_bubble_outline_rounded, color: Cores.dourado, size: 17)),
              const SizedBox(width: 11),
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('TEAM\'s', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                SizedBox(height: 1),
                Text('Conversas e chamadas', style: TextStyle(fontSize: 11, color: Cores.cinza)),
              ]),
            ]),
          ),
        ]),
      )),
    );
  }
}
