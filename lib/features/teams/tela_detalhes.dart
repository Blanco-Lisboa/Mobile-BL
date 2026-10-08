import 'package:flutter/material.dart';

import '../../core/tema.dart';
import '../../data/teams/modelos.dart';
import 'comuns.dart';
import 'formularios.dart';
import 'teams_store.dart';

class TelaDetalhes extends StatelessWidget {
  const TelaDetalhes({super.key, required this.store, required this.canalId});
  final TeamsStore store;
  final String canalId;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final c = store.canal(canalId);
        if (c == null) return const Scaffold(body: SizedBox());
        final ids = store.participantes(c);
        final arquivos = (store.mensagens[canalId] ?? const <Mensagem>[])
            .expand((m) => m.anexos)
            .where((a) => a.tipo != 'audio')
            .length;
        return Scaffold(
          body: SafeArea(
            top: false,
            child: ListView(
              children: [
                Topo(titulo: store.nomeCanal(c), voltar: true),
                _opcao(
                  'Silenciar conversa',
                  Switch(
                    value: c.silenciado,
                    activeTrackColor: Cores.verde,
                    onChanged: (_) => store.silenciar(c),
                  ),
                ),
                _opcao(
                  'Novo pedido',
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFA9B3BF),
                  ),
                  aoTocar: () =>
                      abrirNovoPedido(context, store, canal: canalId),
                ),
                _opcao(
                  'Marcar reunião',
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFA9B3BF),
                  ),
                  aoTocar: () =>
                      abrirNovaReuniao(context, store, canal: canalId),
                ),
                _opcao(
                  'Arquivos e fotos',
                  Text(
                    '$arquivos',
                    style: const TextStyle(
                      color: Color(0xFFA9B3BF),
                      fontSize: 12,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 6),
                  child: Text(
                    'PARTICIPANTES · ${ids.length}',
                    style: const TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.4,
                      color: Color(0xFF8B97A6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                for (final id in ids)
                  () {
                    final p = store.equipe.pessoa(id);
                    final st = store.presencas[id] ?? 'offline';
                    return ListTile(
                      dense: true,
                      leading: bolinhaPessoa(p, tamanho: 34, status: st),
                      title: Text(
                        id == store.eu ? '${p.nome} (você)' : p.nome,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        statusPresenca[st] ?? 'Offline',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Cores.cinza,
                        ),
                      ),
                      onTap: id == store.eu
                          ? null
                          : () async {
                              final novo = await store.abrirDireta(id);
                              if (context.mounted) Navigator.pop(context, novo);
                            },
                    );
                  }(),
                if (c.tipo == 'grupo')
                  ListTile(
                    title: const Text(
                      '+ Adicionar pessoas',
                      style: TextStyle(
                        color: Cores.douradoTexto,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () async {
                      final r = await escolherPessoas(
                        context,
                        store,
                        titulo: 'Adicionar pessoas',
                        ja: c.membros,
                        acao: 'Adicionar',
                      );
                      if (r == null || r.isEmpty) return;
                      try {
                        await store.api.adicionarMembros(c.id, r);
                        c.membros = [...c.membros, ...r];
                      } catch (_) {
                        if (context.mounted) {
                          avisar(
                            context,
                            'Só quem administra o grupo pode adicionar pessoas.',
                          );
                        }
                      }
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _opcao(String t, Widget fim, {VoidCallback? aoTocar}) => InkWell(
    onTap: aoTocar,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      constraints: const BoxConstraints(minHeight: 46),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF1F3F6))),
      ),
      child: Row(
        children: [
          Expanded(child: Text(t, style: const TextStyle(fontSize: 13))),
          fim,
        ],
      ),
    ),
  );
}
