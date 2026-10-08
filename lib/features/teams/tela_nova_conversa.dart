import 'package:flutter/material.dart';

import '../../core/tema.dart';
import 'comuns.dart';
import 'teams_store.dart';

class TelaNovaConversa extends StatefulWidget {
  const TelaNovaConversa({super.key, required this.store});
  final TeamsStore store;
  @override
  State<TelaNovaConversa> createState() => _TelaNovaConversaState();
}

class _TelaNovaConversaState extends State<TelaNovaConversa> {
  final sel = <String>{};
  String busca = '';
  String filtro = '';
  final nomeGrupo = TextEditingController();
  bool criando = false;
  bool modoGrupo = false;

  static const _niveis = [
    ('ceo', 'CEO'),
    ('diretor', 'Diretor'),
    ('gerente', 'Gerente'),
    ('assistente', 'Assistente'),
    ('colaborador', 'Colaborador'),
  ];

  Future<void> _criarGrupo() async {
    if (nomeGrupo.text.trim().isEmpty) {
      avisar(context, 'Escreva o nome do grupo.');
      return;
    }
    setState(() => criando = true);
    try {
      final id = await widget.store.criarGrupo(
        nomeGrupo.text.trim(),
        sel.toList(),
      );
      if (mounted) Navigator.pop(context, id);
    } catch (_) {
      if (mounted) {
        setState(() => criando = false);
        avisar(context, 'Não foi possível criar o grupo.');
      }
    }
  }

  Future<void> _direta(String id) async {
    try {
      final c = await widget.store.abrirDireta(id);
      if (mounted) Navigator.pop(context, c);
    } catch (_) {
      if (mounted) avisar(context, 'Não foi possível abrir a conversa.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final lista = s.equipe.pessoas
        .where((p) => p.id != s.eu)
        .where(
          (p) =>
              busca.isEmpty ||
              p.nome.toLowerCase().contains(busca.toLowerCase()),
        )
        .where(
          (p) =>
              filtro.isEmpty || p.setores.contains(filtro) || p.nivel == filtro,
        )
        .toList();
    final grupo = modoGrupo;
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            cabecalhoFormulario(
              context,
              titulo: grupo ? 'Novo grupo' : 'Nova conversa',
              acao: grupo ? (criando ? '…' : 'Criar') : '',
              aoConfirmar: grupo && !criando && sel.isNotEmpty
                  ? _criarGrupo
                  : null,
              escuro: true,
            ),
            const SizedBox(height: 10),
            if (grupo)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  key: const Key('nome-grupo'),
                  controller: nomeGrupo,
                  decoration: campo(
                    'Nome do grupo (${sel.length + 1} pessoas)',
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => busca = v.trim()),
                decoration: campo('Buscar pessoa'),
              ),
            ),
            SizedBox(
              height: 34,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _chip('', 'Todos'),
                  for (final st in s.equipe.setores) _chip(st.id, st.nome),
                  for (final n in _niveis) _chip(n.$1, n.$2),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView(
                children: [
                  if (!grupo)
                    ListTile(
                      key: const Key('novo-grupo'),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Cores.marinho,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.group_add_outlined,
                          size: 18,
                          color: Cores.dourado,
                        ),
                      ),
                      title: const Text(
                        'Novo grupo',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () => setState(() => modoGrupo = true),
                    ),
                  for (final p in lista)
                    ListTile(
                      leading: bolinhaPessoa(
                        p,
                        tamanho: 36,
                        status: s.presencas[p.id] ?? 'offline',
                      ),
                      title: Text(
                        p.nome,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        [
                          if (p.nivel != null)
                            '${p.nivel![0].toUpperCase()}${p.nivel!.substring(1)}',
                          ...p.setores.map(s.equipe.nomeSetor),
                        ].join(' · '),
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Cores.cinza,
                        ),
                      ),
                      trailing: grupo
                          ? Icon(
                              sel.contains(p.id)
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: sel.contains(p.id)
                                  ? Cores.marinho
                                  : const Color(0xFFC9D1DB),
                            )
                          : null,
                      onTap: grupo
                          ? () => setState(
                              () => sel.contains(p.id)
                                  ? sel.remove(p.id)
                                  : sel.add(p.id),
                            )
                          : () => _direta(p.id),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String id, String nome) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: GestureDetector(
      onTap: () => setState(() => filtro = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: filtro == id ? Cores.marinho : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: filtro == id ? Cores.marinho : Cores.linha),
        ),
        child: Text(
          nome,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: filtro == id ? Colors.white : const Color(0xFF5C6878),
          ),
        ),
      ),
    ),
  );
}
