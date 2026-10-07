import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/tema.dart';
import '../../data/teams/modelos.dart';
import 'comuns.dart';
import 'teams_store.dart';

Future<T?> _folha<T>(BuildContext context, Widget Function(BuildContext) corpo) => showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Cores.fundoApp,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * .9),
          child: SafeArea(top: false, child: corpo(ctx)),
        ),
      ),
    );

Future<String?> escolherPessoa(BuildContext context, TeamsStore s, {String titulo = 'Escolher pessoa'}) async {
  final r = await escolherPessoas(context, s, titulo: titulo, unica: true);
  return r == null || r.isEmpty ? null : r.first;
}

Future<List<String>?> escolherPessoas(BuildContext context, TeamsStore s,
    {String titulo = 'Escolher pessoas', bool unica = false, List<String> ja = const [], String acao = 'Pronto'}) {
  return _folha<List<String>>(context, (ctx) => _Escolher(store: s, titulo: titulo, unica: unica, ja: ja, acao: acao));
}

class _Escolher extends StatefulWidget {
  const _Escolher({required this.store, required this.titulo, required this.unica, required this.ja, required this.acao});
  final TeamsStore store;
  final String titulo;
  final bool unica;
  final List<String> ja;
  final String acao;
  @override
  State<_Escolher> createState() => _EscolherState();
}

class _EscolherState extends State<_Escolher> {
  final sel = <String>{};
  String busca = '';
  String setor = '';

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    final lista = s.equipe.pessoas
        .where((p) => p.id != s.eu && !widget.ja.contains(p.id))
        .where((p) => busca.isEmpty || p.nome.toLowerCase().contains(busca.toLowerCase()))
        .where((p) => setor.isEmpty || p.setores.contains(setor))
        .toList();
    return Column(mainAxisSize: MainAxisSize.min, children: [
      cabecalhoFormulario(context, titulo: widget.titulo, acao: widget.unica ? '' : widget.acao,
          aoConfirmar: widget.unica || sel.isEmpty ? null : () => Navigator.pop(context, sel.toList())),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: TextField(onChanged: (v) => setState(() => busca = v.trim()), decoration: campo('Buscar pessoa')),
      ),
      SizedBox(
        height: 34,
        child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16), children: [
          _chip('', 'Todos'),
          for (final st in s.equipe.setores) _chip(st.id, st.nome),
        ]),
      ),
      const SizedBox(height: 6),
      Flexible(
        child: ListView(shrinkWrap: true, children: [
          for (final p in lista)
            ListTile(
              dense: true,
              leading: bolinhaPessoa(p, tamanho: 34, status: s.presencas[p.id] ?? 'offline'),
              title: Text(p.nome, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              subtitle: Text(
                [if (p.nivel != null) '${p.nivel![0].toUpperCase()}${p.nivel!.substring(1)}', ...p.setores.map(s.equipe.nomeSetor)].join(' · '),
                style: const TextStyle(fontSize: 10.5, color: Cores.cinza),
              ),
              trailing: widget.unica
                  ? null
                  : Icon(sel.contains(p.id) ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: sel.contains(p.id) ? Cores.marinho : const Color(0xFFC9D1DB)),
              onTap: () {
                if (widget.unica) {
                  Navigator.pop(context, [p.id]);
                  return;
                }
                setState(() => sel.contains(p.id) ? sel.remove(p.id) : sel.add(p.id));
              },
            ),
        ]),
      ),
    ]);
  }

  Widget _chip(String id, String nome) => Padding(
        padding: const EdgeInsets.only(right: 6),
        child: GestureDetector(
          onTap: () => setState(() => setor = id),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: setor == id ? Cores.marinho : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: setor == id ? Cores.marinho : Cores.linha),
            ),
            child: Text(nome, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: setor == id ? Colors.white : const Color(0xFF5C6878))),
          ),
        ),
      );
}

Future<void> abrirNovoPedido(BuildContext context, TeamsStore s, {String? canal, Mensagem? origem}) =>
    _folha(context, (ctx) => _NovoPedido(store: s, canal: canal, origem: origem));

class _NovoPedido extends StatefulWidget {
  const _NovoPedido({required this.store, this.canal, this.origem});
  final TeamsStore store;
  final String? canal;
  final Mensagem? origem;
  @override
  State<_NovoPedido> createState() => _NovoPedidoState();
}

class _NovoPedidoState extends State<_NovoPedido> {
  late final titulo = TextEditingController(text: (widget.origem?.corpo ?? '').length > 200 ? widget.origem!.corpo!.substring(0, 200) : widget.origem?.corpo);
  final desc = TextEditingController();
  String? dono;
  DateTime? prazo;
  bool salvando = false;

  Future<void> _criar() async {
    if (titulo.text.trim().isEmpty || dono == null) {
      avisar(context, 'Preencha o pedido e o dono.');
      return;
    }
    setState(() => salvando = true);
    try {
      await widget.store.api.criarPedido(
          titulo: titulo.text.trim(), descricao: desc.text.trim().isEmpty ? null : desc.text.trim(), responsavel: dono!, prazo: prazo,
          canal: widget.canal, mensagemId: widget.origem?.id);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => salvando = false);
        avisar(context, 'Não foi possível criar o pedido.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        cabecalhoFormulario(context, titulo: 'Novo pedido', acao: salvando ? '…' : 'Criar', aoConfirmar: salvando ? null : _criar),
        rotulo('O que fazer'),
        TextField(controller: titulo, maxLength: 200, decoration: campo('Ex.: emitir guia da abertura').copyWith(counterText: '')),
        const SizedBox(height: 8),
        rotulo('Descrição'),
        TextField(controller: desc, minLines: 2, maxLines: 4, decoration: campo('Detalhes')),
        const SizedBox(height: 8),
        rotulo('Dono'),
        _seletor(dono == null ? 'Escolher' : s.equipe.pessoa(dono).nome, () async {
          final p = await escolherPessoa(context, s, titulo: 'Dono do pedido');
          if (p != null) setState(() => dono = p);
        }),
        const SizedBox(height: 8),
        rotulo('Prazo'),
        _seletor(prazo == null ? 'Sem prazo' : dataCurta(prazo!), () async {
          final d = await showDatePicker(context: context, firstDate: DateTime.now().subtract(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 365)));
          if (d != null) setState(() => prazo = d);
        }),
        if (widget.origem != null) ...[
          const SizedBox(height: 8),
          rotulo('Ligado à mensagem'),
          Text('${s.equipe.pessoa(widget.origem!.autorId).nome} · ${hora(widget.origem!.criadaEm)}', style: const TextStyle(fontSize: 12, color: Cores.cinza)),
        ],
      ]),
    );
  }
}

Widget _seletor(String texto, VoidCallback aoTocar) => GestureDetector(
      onTap: aoTocar,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE6EAEF))),
        child: Row(children: [
          Expanded(child: Text(texto, style: const TextStyle(fontSize: 13))),
          const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFA9B3BF)),
        ]),
      ),
    );

Future<void> abrirNovoAviso(BuildContext context, TeamsStore s) => _folha(context, (ctx) => _NovoAviso(store: s));

class _NovoAviso extends StatefulWidget {
  const _NovoAviso({required this.store});
  final TeamsStore store;
  @override
  State<_NovoAviso> createState() => _NovoAvisoState();
}

class _NovoAvisoState extends State<_NovoAviso> {
  String nivel = 'info';
  String? setor;
  final titulo = TextEditingController();
  final corpo = TextEditingController();
  bool salvando = false;

  Future<void> _enviar() async {
    if (titulo.text.trim().isEmpty) {
      avisar(context, 'Dê um título ao aviso.');
      return;
    }
    setState(() => salvando = true);
    try {
      await widget.store.api.criarAviso(nivel: nivel, titulo: titulo.text.trim(), corpo: corpo.text.trim().isEmpty ? null : corpo.text.trim(), setorId: setor);
      await widget.store.carregarAvisos();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => salvando = false);
        avisar(context, 'Não foi possível enviar o aviso.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        cabecalhoFormulario(context, titulo: 'Novo aviso', acao: salvando ? '…' : 'Enviar', aoConfirmar: salvando ? null : _enviar),
        rotulo('Nível'),
        Segmentos(opcoes: const [('info', 'Informativo'), ('visto', 'Exige visto'), ('urgente', 'Urgente')], valor: nivel, aoMudar: (v) => setState(() => nivel = v)),
        const SizedBox(height: 10),
        rotulo('Para'),
        _seletor(setor == null ? 'Todos' : s.equipe.nomeSetor(setor), () async {
          final r = await showModalBottomSheet<String>(
            context: context,
            builder: (ctx) => SafeArea(
              child: ListView(shrinkWrap: true, children: [
                ListTile(title: const Text('Todos'), onTap: () => Navigator.pop(ctx, '')),
                for (final st in s.equipe.setores) ListTile(title: Text(st.nome), onTap: () => Navigator.pop(ctx, st.id)),
              ]),
            ),
          );
          if (r != null) setState(() => setor = r.isEmpty ? null : r);
        }),
        const SizedBox(height: 8),
        rotulo('Título'),
        TextField(controller: titulo, maxLength: 160, decoration: campo('Ex.: manutenção do ERP hoje 22h').copyWith(counterText: '')),
        const SizedBox(height: 8),
        rotulo('Mensagem'),
        TextField(controller: corpo, minLines: 4, maxLines: 8, decoration: campo('')),
      ]),
    );
  }
}

Future<void> abrirNovaReuniao(BuildContext context, TeamsStore s, {String? canal}) =>
    _folha(context, (ctx) => _NovaReuniao(store: s, canal: canal));

class _NovaReuniao extends StatefulWidget {
  const _NovaReuniao({required this.store, this.canal});
  final TeamsStore store;
  final String? canal;
  @override
  State<_NovaReuniao> createState() => _NovaReuniaoState();
}

class _NovaReuniaoState extends State<_NovaReuniao> {
  final titulo = TextEditingController();
  final pauta = TextEditingController();
  DateTime? inicio;
  DateTime? fim;
  late List<String> convidados = () {
    final c = widget.canal == null ? null : widget.store.canal(widget.canal!);
    return c == null ? <String>[] : widget.store.participantes(c).where((x) => x != widget.store.eu).toList();
  }();
  bool salvando = false;

  Future<DateTime?> _escolherData(DateTime? base) async {
    final d = await showDatePicker(context: context, initialDate: base ?? DateTime.now(), firstDate: DateTime.now().subtract(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 365)));
    if (d == null || !mounted) return null;
    final h = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(base ?? DateTime.now().add(const Duration(hours: 1))));
    if (h == null) return null;
    return DateTime(d.year, d.month, d.day, h.hour, h.minute);
  }

  Future<void> _marcar() async {
    if (titulo.text.trim().isEmpty || inicio == null) {
      avisar(context, 'Preencha o assunto e o horário.');
      return;
    }
    if (fim != null && !fim!.isAfter(inicio!)) {
      avisar(context, 'O fim precisa ser depois do começo.');
      return;
    }
    setState(() => salvando = true);
    try {
      await widget.store.api.criarReuniao(titulo: titulo.text.trim(), pauta: pauta.text.trim().isEmpty ? null : pauta.text.trim(),
          inicio: inicio!, fim: fim, canal: widget.canal, convidados: convidados);
      await widget.store.carregarReunioes();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => salvando = false);
        avisar(context, 'Não foi possível agendar.');
      }
    }
  }

  String _fmt(DateTime? d) => d == null ? 'Escolher' : '${dataCurta(d)} ${hora(d)}';

  @override
  Widget build(BuildContext context) {
    final s = widget.store;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        cabecalhoFormulario(context, titulo: 'Marcar reunião', acao: salvando ? '…' : 'Marcar', aoConfirmar: salvando ? null : _marcar),
        rotulo('Assunto'),
        TextField(controller: titulo, maxLength: 160, decoration: campo('Ex.: semanal Financeiro × Societário').copyWith(counterText: '')),
        const SizedBox(height: 8),
        rotulo('Pauta'),
        TextField(controller: pauta, minLines: 2, maxLines: 4, decoration: campo('')),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            rotulo('Início'),
            _seletor(_fmt(inicio), () async {
              final d = await _escolherData(inicio);
              if (d != null) setState(() => inicio = d);
            }),
          ])),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            rotulo('Fim'),
            _seletor(fim == null ? 'Opcional' : _fmt(fim), () async {
              final d = await _escolherData(fim ?? inicio);
              if (d != null) setState(() => fim = d);
            }),
          ])),
        ]),
        const SizedBox(height: 8),
        rotulo('Convidados'),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final id in convidados)
            Chip(
              label: Text(s.equipe.pessoa(id).nome.split(' ').first, style: const TextStyle(fontSize: 11)),
              onDeleted: () => setState(() => convidados.remove(id)),
              visualDensity: VisualDensity.compact,
            ),
          ActionChip(
            label: const Text('+ adicionar', style: TextStyle(fontSize: 11, color: Cores.douradoTexto)),
            onPressed: () async {
              final r = await escolherPessoas(context, s, titulo: 'Convidar', ja: convidados);
              if (r != null) setState(() => convidados.addAll(r));
            },
          ),
        ]),
      ]),
    );
  }
}

Future<Empresa?> escolherEmpresa(BuildContext context, TeamsStore s) => _folha<Empresa>(context, (ctx) => _BuscarEmpresa(store: s));

class _BuscarEmpresa extends StatefulWidget {
  const _BuscarEmpresa({required this.store});
  final TeamsStore store;
  @override
  State<_BuscarEmpresa> createState() => _BuscarEmpresaState();
}

class _BuscarEmpresaState extends State<_BuscarEmpresa> {
  List<Empresa> lista = [];
  Timer? _espera;

  void _buscar(String t) {
    _espera?.cancel();
    _espera = Timer(const Duration(milliseconds: 350), () async {
      try {
        final r = await widget.store.api.buscarEmpresas(t);
        if (mounted) setState(() => lista = r);
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _espera?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      cabecalhoFormulario(context, titulo: 'Citar cliente', acao: '', aoConfirmar: null),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: TextField(autofocus: true, onChanged: _buscar, decoration: campo('Nome ou CNPJ')),
      ),
      Flexible(
        child: ListView(shrinkWrap: true, children: [
          for (final e in lista)
            ListTile(
              dense: true,
              leading: const Icon(Icons.apartment_rounded, color: Cores.douradoTexto),
              title: Text(e.nome, style: const TextStyle(fontSize: 13)),
              subtitle: Text([e.cnpj, e.regime].whereType<String>().join(' · '), style: const TextStyle(fontSize: 11, color: Cores.cinza)),
              onTap: () => Navigator.pop(context, e),
            ),
        ]),
      ),
    ]);
  }
}

void mostrarEmpresa(BuildContext context, Empresa e) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(e.nome, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          if (e.cnpj != null) Text('CNPJ ${e.cnpj}', style: const TextStyle(fontSize: 13, color: Cores.cinza)),
          if (e.regime != null) Text('Regime: ${e.regime}', style: const TextStyle(fontSize: 13, color: Cores.cinza)),
        ]),
      ),
    ),
  );
}
