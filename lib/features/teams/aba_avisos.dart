import 'package:flutter/material.dart';
import '../../core/tema.dart';
import '../../data/teams/modelos.dart';
import 'comuns.dart';
import 'formularios.dart';
import 'teams_store.dart';

class AbaAvisos extends StatefulWidget {
  const AbaAvisos({super.key, required this.store});
  final TeamsStore store;
  @override
  State<AbaAvisos> createState() => _AbaAvisosState();
}

class _AbaAvisosState extends State<AbaAvisos> {
  String filtro = 'todos';

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final lista = s.avisos.where((a) => filtro == 'todos' || (filtro == 'central' ? a.escopo == 'central' : a.escopo == 'setor')).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Topo(titulo: 'Avisos', acoes: [BotaoRedondo(chave: const Key('novo-aviso'), icone: Icons.add_rounded, aoTocar: () => abrirNovoAviso(context, s))]),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: Segmentos(opcoes: const [('todos', 'Todos'), ('central', 'Central'), ('setor', 'Meu setor')], valor: filtro, aoMudar: (v) => setState(() => filtro = v)),
      ),
      Expanded(
        child: RefreshIndicator(
          onRefresh: s.carregarAvisos,
          child: ListView(padding: const EdgeInsets.only(bottom: 20), children: [for (final a in lista) _cartao(a)]),
        ),
      ),
    ]);
  }

  Widget _cartao(Aviso a) {
    final s = widget.store;
    final (fundo, cor) = switch (a.nivel) {
      'urgente' => (const Color(0xFFFBE8E8), const Color(0xFFC23B3B)),
      'visto' => (const Color(0xFFFBF1DC), const Color(0xFFA87414)),
      _ => (const Color(0xFFE8EFFD), const Color(0xFF2F6FED)),
    };
    final meu = a.autorId == s.eu;
    final vi = s.vistos.contains(a.id);
    final total = s.contagemVistos[a.id] ?? 0;
    return Cartao(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(6)),
          child: Text('● ${nivelAviso[a.nivel] ?? 'Informativo'}'.toUpperCase(), style: TextStyle(fontSize: 9, letterSpacing: .7, fontWeight: FontWeight.w600, color: cor)),
        ),
        const SizedBox(height: 7),
        Text(a.titulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        if ((a.corpo ?? '').isNotEmpty)
          Padding(padding: const EdgeInsets.only(top: 3), child: Text(a.corpo!, style: const TextStyle(fontSize: 11.5, height: 1.4, color: Color(0xFF5C6878)))),
        const SizedBox(height: 9),
        Row(children: [
          Expanded(
            child: Text(
              '${s.equipe.pessoa(a.autorId).nome.split(' ').first} · ${quando(a.criadoEm)}${a.escopo == 'setor' ? ' · ${s.equipe.nomeSetor(a.setorId)}' : ''}${meu ? ' · $total viram' : ''}',
              style: const TextStyle(fontSize: 10, color: Color(0xFF8B97A6)),
            ),
          ),
          if (!meu && vi) const Text('✓ Visto', style: TextStyle(fontSize: 10.5, color: Cores.verde, fontWeight: FontWeight.w500)),
          if (!meu && !vi)
            GestureDetector(
              onTap: () => s.darVisto(a.id).catchError((_) {
                if (mounted) avisar(context, 'Não foi possível marcar.');
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Cores.marinho, borderRadius: BorderRadius.circular(9)),
                child: const Text('Dar visto', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ),
        ]),
      ]),
    );
  }
}
