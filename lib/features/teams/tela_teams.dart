import 'package:flutter/material.dart';

import '../../core/tema.dart';
import '../../data/teams/modelos.dart';
import 'aba_avisos.dart';
import 'aba_pedidos.dart';
import 'aba_reunioes.dart';
import 'chamada.dart';
import 'comuns.dart';
import 'tela_conversa.dart';
import 'tela_nova_conversa.dart';
import 'teams_store.dart';

class TelaTeams extends StatefulWidget {
  const TelaTeams({
    super.key,
    required this.store,
    required this.chamada,
    this.abaInicial = 0,
    this.canalInicial,
  });
  final TeamsStore store;
  final ChamadaController chamada;
  final int abaInicial;
  final String? canalInicial;
  @override
  State<TelaTeams> createState() => _TelaTeamsState();
}

class _TelaTeamsState extends State<TelaTeams> {
  late int aba = widget.abaInicial;

  @override
  void initState() {
    super.initState();
    if (aba == 1) widget.store.carregarAvisos();
    if (aba == 2) widget.store.carregarPedidos();
    if (aba == 3) widget.store.carregarReunioes();
    final c = widget.canalInicial;
    if (c != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TelaConversa(
              store: widget.store,
              canalId: c,
              chamada: widget.chamada,
            ),
          ),
        );
        widget.store.fecharCanal();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) => Scaffold(
        body: SafeArea(
          top: false,
          bottom: false,
          child: IndexedStack(
            index: aba,
            children: [
              AbaConversas(store: s, chamada: widget.chamada),
              AbaAvisos(store: s),
              AbaPedidos(store: s),
              AbaReunioes(store: s, chamada: widget.chamada),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Cores.linha)),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 58,
              child: Row(
                children: [
                  _aba(
                    0,
                    Icons.chat_bubble_outline_rounded,
                    'Conversas',
                    s.naoLidasTotal,
                  ),
                  _aba(
                    1,
                    Icons.notifications_none_rounded,
                    'Avisos',
                    s.pend['avisos'] ?? 0,
                  ),
                  _aba(
                    2,
                    Icons.assignment_outlined,
                    'Pedidos',
                    s.pend['pedidos'] ?? 0,
                  ),
                  _aba(
                    3,
                    Icons.event_outlined,
                    'Reuniões',
                    s.pend['reunioes'] ?? 0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _aba(int i, IconData ic, String nome, int n) {
    final sel = aba == i;
    return Expanded(
      child: InkWell(
        key: Key('aba-$i'),
        onTap: () {
          setState(() => aba = i);
          if (i == 1) widget.store.carregarAvisos();
          if (i == 2) widget.store.carregarPedidos();
          if (i == 3) widget.store.carregarReunioes();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? Cores.marinho : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    ic,
                    size: 20,
                    color: sel ? Cores.dourado : const Color(0xFF8B97A6),
                  ),
                ),
                Positioned(right: 2, top: -5, child: Selo(n, pequeno: true)),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              nome,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: sel ? Cores.texto : const Color(0xFF8B97A6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AbaConversas extends StatefulWidget {
  const AbaConversas({super.key, required this.store, required this.chamada});
  final TeamsStore store;
  final ChamadaController chamada;
  @override
  State<AbaConversas> createState() => _AbaConversasState();
}

class _AbaConversasState extends State<AbaConversas> {
  String filtro = 'entrada';
  String busca = '';

  Future<void> _abrir(String id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TelaConversa(
          store: widget.store,
          canalId: id,
          chamada: widget.chamada,
        ),
      ),
    );
    widget.store.fecharCanal();
  }

  Future<void> _escolherStatus() async {
    final s = widget.store;
    final st = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => folhaFlutuante(
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final o in opcoesStatus)
              ListTile(
                leading: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: corStatus(o.$1),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(o.$2, style: const TextStyle(fontSize: 13.5)),
                trailing: s.presencas[s.eu] == o.$1
                    ? const Icon(
                        Icons.check_rounded,
                        size: 18,
                        color: Cores.douradoTexto,
                      )
                    : null,
                onTap: () => Navigator.pop(ctx, o.$1),
              ),
          ],
        ),
      ),
    );
    if (st == null) return;
    try {
      await s.mudarStatus(st);
    } catch (_) {
      if (mounted) avisar(context, 'Status não salvou.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final hoje = DateTime.now();
    final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);
    final eu = s.equipe.pessoa(s.eu);
    final meuStatus = s.presencas[s.eu] ?? 'online';
    var lista = [...s.canais];
    lista.sort(
      (a, b) => (b.ultima?.em ?? DateTime(2000)).compareTo(
        a.ultima?.em ?? DateTime(2000),
      ),
    );
    final b = busca.toLowerCase();
    final pessoasBusca = b.isEmpty
        ? <Pessoa>[]
        : s.equipe.pessoas
              .where((p) => p.id != s.eu && p.nome.toLowerCase().contains(b))
              .toList();
    bool deHoje(Canal c) =>
        c.naoLidas > 0 || (c.ultima?.em?.isAfter(inicioHoje) ?? false);
    var setoresSemCanal = <Setor>[];
    if (b.isNotEmpty) {
      lista = lista
          .where(
            (c) =>
                s.nomeCanal(c).toLowerCase().contains(b) ||
                (c.ultima?.corpo ?? '').toLowerCase().contains(b),
          )
          .toList();
    } else if (filtro == 'entrada') {
      lista = lista.where(deHoje).toList();
    } else if (filtro == 'anteriores') {
      lista = lista
          .where((c) => !deHoje(c) && c.ultima != null && c.tipo != 'setor')
          .toList();
    } else {
      final setores = lista.where((c) => c.tipo == 'setor').toList();
      lista = [...setores, ...lista.where((c) => c.tipo == 'grupo')];
      setoresSemCanal = s.equipe.setores
          .where(
            (st) =>
                !s.canais.any((c) => c.tipo == 'setor' && c.setorId == st.id),
          )
          .toList();
    }
    final pessoasDiretas = pessoasBusca
        .where(
          (p) =>
              !lista.any((c) => c.tipo == 'direta' && c.membros.contains(p.id)),
        )
        .toList();

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Faixa(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 14, 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.chevron_left_rounded,
                        color: Cores.dourado,
                        size: 28,
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        key: const Key('meu-status'),
                        onTap: _escolherStatus,
                        child: Row(
                          children: [
                            Bolinha(
                              texto: iniciais(eu.nome),
                              tamanho: 34,

                              status: meuStatus,
                              fotoUrl: eu.fotoUrl,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    eu.nome,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        statusPresenca[meuStatus] ?? 'Online',
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          color: meuStatus == 'online'
                                              ? const Color(0xFF6EE7A0)
                                              : corStatus(meuStatus),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (eu.setores.isNotEmpty)
                                        Flexible(
                                          child: Text(
                                            ' · ${eu.setores.map(s.equipe.nomeSetor).join(', ')}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 10.5,
                                              color: Color(0xFF9DB0C6),
                                            ),
                                          ),
                                        ),
                                      const Icon(
                                        Icons.expand_more_rounded,
                                        size: 14,
                                        color: Color(0xFF9DB0C6),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: TextField(
                key: const Key('busca'),
                onChanged: (v) => setState(() => busca = v.trim()),
                style: const TextStyle(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Buscar conversa ou pessoa',
                  hintStyle: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF8B97A6),
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 18,
                    color: Color(0xFF8B97A6),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFEEF1F4),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (b.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    for (final f in const [
                      ('entrada', 'Caixa de entrada'),
                      ('anteriores', 'Anteriores'),
                      ('grupos', 'Grupos'),
                    ]) ...[
                      Expanded(
                        child: GestureDetector(
                          key: Key('sub-${f.$1}'),
                          onTap: () => setState(() => filtro = f.$1),
                          child: Container(
                            height: 30,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: filtro == f.$1
                                  ? Cores.marinho
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(
                                color: filtro == f.$1
                                    ? Cores.marinho
                                    : Cores.linha,
                              ),
                            ),
                            child: Text(
                              f.$2,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: filtro == f.$1
                                    ? Colors.white
                                    : const Color(0xFF5C6878),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (f.$1 != 'grupos') const SizedBox(width: 5),
                    ],
                  ],
                ),
              ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 90),
                children: [
                  for (final c in lista) _itemCanal(c),
                  for (final st in setoresSemCanal)
                    _linha(
                      const Bolinha(texto: '#', escuro: true, quadrado: true),
                      st.nome,
                      '${s.equipe.doSetor(st.id).length} pessoas',
                      '',
                      0,
                      false,
                      () async => _abrir(await s.abrirSetor(st)),
                    ),
                  for (final p in pessoasDiretas)
                    _linha(
                      bolinhaPessoa(p, status: s.presencas[p.id] ?? 'offline'),
                      p.nome,
                      'Nova conversa',
                      '',
                      0,
                      false,
                      () async => _abrir(await s.abrirDireta(p.id)),
                    ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: GestureDetector(
            key: const Key('nova-conversa'),
            onTap: () async {
              final id = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (_) => TelaNovaConversa(store: s)),
              );
              if (id != null) _abrir(id);
            },
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Cores.marinho,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x800A1B30),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                    spreadRadius: -8,
                  ),
                ],
              ),
              child: const Icon(Icons.add_rounded, color: Cores.dourado),
            ),
          ),
        ),
      ],
    );
  }

  Widget _itemCanal(Canal c) {
    final s = widget.store;
    Widget av;
    if (c.tipo == 'direta') {
      final p = s.equipe.pessoa(s.outroDaDireta(c));
      av = bolinhaPessoa(p, status: s.presencas[p.id] ?? 'offline');
    } else if (c.tipo == 'setor') {
      av = const Bolinha(texto: '#', escuro: true, quadrado: true);
    } else {
      av = Bolinha(texto: iniciais(s.nomeCanal(c)), quadrado: true);
    }
    final u = c.ultima;
    var previa = '';
    if (u != null) {
      final autor = u.autorId == s.eu
          ? 'Você'
          : (c.tipo == 'direta'
                ? ''
                : s.equipe.pessoa(u.autorId).nome.split(' ').first);
      final corpo = switch (u.tipo) {
        'audio' => '🎤 Áudio',
        'arquivo' => '📎 ${u.corpo ?? 'Arquivo'}',
        'pedido' => '📋 ${u.corpo ?? ''}',
        _ => u.corpo ?? '',
      };
      previa = autor.isEmpty ? corpo : '$autor: $corpo';
    }
    return _linha(
      av,
      s.nomeCanal(c),
      previa,
      quando(u?.em),
      c.naoLidas,
      c.silenciado,
      () => _abrir(c.id),
    );
  }

  Widget _linha(
    Widget av,
    String nome,
    String previa,
    String h,
    int n,
    bool mudo,
    VoidCallback aoTocar,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: aoTocar,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
        child: Row(
          children: [
            av,
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nome,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    previa,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11.5, color: Cores.cinza),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  h,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF9AA5B2),
                  ),
                ),
                const SizedBox(height: 4),
                if (mudo)
                  const Icon(
                    Icons.notifications_off_outlined,
                    size: 13,
                    color: Cores.cinzaStatus,
                  )
                else
                  Selo(n),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
