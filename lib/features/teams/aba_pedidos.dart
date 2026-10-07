import 'package:flutter/material.dart';
import '../../data/teams/modelos.dart';
import 'comuns.dart';
import 'formularios.dart';
import 'teams_store.dart';

class AbaPedidos extends StatefulWidget {
  const AbaPedidos({super.key, required this.store});
  final TeamsStore store;
  @override
  State<AbaPedidos> createState() => _AbaPedidosState();
}

class _AbaPedidosState extends State<AbaPedidos> {
  String filtro = 'meus';

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final lista = s.pedidos
        .where((p) => filtro == 'meus' ? p.responsavelId == s.eu : filtro == 'pedi' ? p.solicitanteId == s.eu : true)
        .toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Topo(titulo: 'Pedidos', acoes: [BotaoRedondo(chave: const Key('novo-pedido'), icone: Icons.add_rounded, aoTocar: () => abrirNovoPedido(context, s))]),
      Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        child: Segmentos(opcoes: const [('meus', 'Para mim'), ('pedi', 'Que eu pedi'), ('todos', 'Todos')], valor: filtro, aoMudar: (v) => setState(() => filtro = v)),
      ),
      Expanded(
        child: RefreshIndicator(
          onRefresh: s.carregarPedidos,
          child: ListView(padding: const EdgeInsets.only(bottom: 20), children: [for (final p in lista) _cartao(p)]),
        ),
      ),
    ]);
  }

  Widget _cartao(Pedido p) {
    final s = widget.store;
    final (fundo, cor) = switch (p.status) {
      'em_andamento' => (const Color(0xFFFBF1DC), const Color(0xFFA87414)),
      'concluido' => (const Color(0xFFE6F4EC), const Color(0xFF2E9E5B)),
      'cancelado' => (const Color(0xFFF1F3F6), const Color(0xFF7A8797)),
      _ => (const Color(0xFFE8EFFD), const Color(0xFF2F6FED)),
    };
    final pode = p.responsavelId == s.eu || p.solicitanteId == s.eu;
    final de = p.responsavelId == s.eu ? 'De ${s.equipe.pessoa(p.solicitanteId).nome.split(' ').first}' : 'Dono: ${s.equipe.pessoa(p.responsavelId).nome.split(' ').first}';
    return Cartao(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(p.codigo, style: const TextStyle(fontSize: 9.5, letterSpacing: .6, fontWeight: FontWeight.w600, color: Color(0xFFB07F1C))),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(6)),
            child: Text(statusPedido[p.status] ?? p.status, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: cor)),
          ),
        ]),
        const SizedBox(height: 5),
        Text(p.titulo, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
        if ((p.descricao ?? '').isNotEmpty)
          Padding(padding: const EdgeInsets.only(top: 3), child: Text(p.descricao!, style: const TextStyle(fontSize: 11, color: Color(0xFF5C6878)))),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: Text('$de${p.prazo != null ? ' · prazo ${dataCurta(p.prazo!)}' : ''}', style: const TextStyle(fontSize: 10, color: Color(0xFF8B97A6)))),
          if (pode && p.status != 'concluido' && p.status != 'cancelado')
            GestureDetector(
              onTap: () => _mudar(p),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFF1F3F6), borderRadius: BorderRadius.circular(9)),
                child: const Text('Mudar status', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
              ),
            ),
        ]),
      ]),
    );
  }

  Future<void> _mudar(Pedido p) async {
    final novo = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          for (final e in statusPedido.entries.where((e) => e.key != p.status))
            ListTile(title: Text(e.value), onTap: () => Navigator.pop(ctx, e.key)),
        ]),
      ),
    );
    if (novo == null) return;
    try {
      await widget.store.api.mudarStatusPedido(p.id, novo);
      await widget.store.carregarPedidos();
    } catch (_) {
      if (mounted) avisar(context, 'Não foi possível atualizar o pedido.');
    }
  }
}
