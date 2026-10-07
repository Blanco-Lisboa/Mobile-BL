import 'package:flutter/material.dart';
import '../../core/sessao.dart';
import '../../core/tema.dart';
import '../../data/teams/modelos.dart';
import '../../data/perfil_repo.dart';
import '../perfil/folha_perfil.dart';
import '../teams/chamada.dart';
import '../teams/comuns.dart';
import '../teams/tela_teams.dart';
import '../teams/teams_store.dart';

class TelaInicio extends StatelessWidget {
  const TelaInicio({super.key, required this.sessao, required this.perfil, this.teams, this.chamada});
  final Sessao sessao;
  final PerfilRepo perfil;
  final TeamsStore? teams;
  final ChamadaController? chamada;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Módulos', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -.2)),
              const Spacer(),
              GestureDetector(key: const Key('avatar'), onTap: () => abrirPerfil(context, sessao: sessao, repo: perfil), child: avatar(sessao.perfil, 32)),
            ]),
            const SizedBox(height: 18),
            teams == null ? _card(context, null) : ListenableBuilder(listenable: teams!, builder: (context, _) => _card(context, teams)),
          ]),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, TeamsStore? t) {
    final pronto = t != null && t.pronto;
    final comUltima = pronto ? t.canais.where((c) => c.ultima?.em != null).toList() : <Canal>[];
    comUltima.sort((a, b) => b.ultima!.em!.compareTo(a.ultima!.em!));
    final ultimaCanal = comUltima.isEmpty ? null : comUltima.first;
    final total = pronto ? t.naoLidasTotal : 0;
    return GestureDetector(
      key: const Key('card-teams'),
      onTap: !pronto ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaTeams(store: t, chamada: chamada!))),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Cores.linha),
          boxShadow: const [BoxShadow(color: Color(0x140E1A2B), blurRadius: 24, offset: Offset(0, 8), spreadRadius: -12)],
        ),
        child: Column(children: [
          Row(children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(color: Cores.marinho, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.chat_bubble_outline_rounded, color: Cores.dourado, size: 17),
            ),
            const SizedBox(width: 11),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('TEAM\'s', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                SizedBox(height: 1),
                Text('Conversas e chamadas', style: TextStyle(fontSize: 11, color: Cores.cinza)),
              ]),
            ),
            if (t != null && !pronto)
              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 1.6))
            else
              Selo(total),
          ]),
          if (ultimaCanal != null) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFF0F2F5)),
            const SizedBox(height: 11),
            Row(children: [
              ultimaCanal.tipo == 'direta'
                  ? bolinhaPessoa(t!.equipe.pessoa(t.outroDaDireta(ultimaCanal)), tamanho: 24)
                  : Bolinha(texto: ultimaCanal.tipo == 'setor' ? '#' : iniciais(t!.nomeCanal(ultimaCanal)), tamanho: 24, quadrado: true, escuro: ultimaCanal.tipo == 'setor'),
              const SizedBox(width: 9),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t!.nomeCanal(ultimaCanal), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                  Text(ultimaCanal.ultima!.corpo ?? '', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Cores.cinza)),
                ]),
              ),
              Text(quando(ultimaCanal.ultima!.em), style: const TextStyle(fontSize: 10, color: Color(0xFF9AA5B2))),
            ]),
          ],
        ]),
      ),
    );
  }
}
