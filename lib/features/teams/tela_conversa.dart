import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:record/record.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/tema.dart';
import '../../data/teams/modelos.dart';
import 'chamada.dart';
import 'comuns.dart';
import 'formularios.dart';
import 'tela_detalhes.dart';
import 'teams_store.dart';

class TelaConversa extends StatefulWidget {
  const TelaConversa({super.key, required this.store, required this.canalId, required this.chamada});
  final TeamsStore store;
  final String canalId;
  final ChamadaController chamada;
  @override
  State<TelaConversa> createState() => _TelaConversaState();
}

class _TelaConversaState extends State<TelaConversa> {
  final _texto = TextEditingController();
  final _rolagem = ScrollController();
  final _foco = FocusNode();
  Mensagem? _resposta;
  String? _mencaoBusca;
  AudioRecorder? _gravador;
  Timer? _relogio;
  int _segundos = 0;
  bool _enviandoArquivo = false;
  bool _opus = true;

  TeamsStore get s => widget.store;
  Canal? get c => s.canal(widget.canalId);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => s.abrirCanal(widget.canalId));
    _texto.addListener(_verMencao);
  }

  @override
  void dispose() {
    _relogio?.cancel();
    _gravador?.dispose();
    _texto.dispose();
    _rolagem.dispose();
    _foco.dispose();
    super.dispose();
  }

  void _verMencao() {
    final t = _texto.text;
    final pos = _texto.selection.baseOffset < 0 ? t.length : _texto.selection.baseOffset;
    final antes = t.substring(0, pos.clamp(0, t.length));
    final m = RegExp(r'@([^\s@]*)$').firstMatch(antes);
    final novo = m?.group(1);
    if (novo != _mencaoBusca) setState(() => _mencaoBusca = novo);
  }

  void _inserirMencao(Pessoa p) {
    final t = _texto.text;
    final pos = _texto.selection.baseOffset < 0 ? t.length : _texto.selection.baseOffset;
    final antes = t.substring(0, pos);
    final i = antes.lastIndexOf('@');
    final novo = '${t.substring(0, i)}@${p.nome} ${t.substring(pos)}';
    _texto.value = TextEditingValue(text: novo, selection: TextSelection.collapsed(offset: i + p.nome.length + 2));
    setState(() => _mencaoBusca = null);
  }

  Future<void> _enviar() async {
    final t = _texto.text.trim();
    if (t.isEmpty) return;
    final resp = _resposta?.id;
    _texto.clear();
    setState(() => _resposta = null);
    try {
      await s.enviarTexto(widget.canalId, t, respondeA: resp);
    } catch (_) {
      if (mounted) avisar(context, 'Não foi possível enviar.');
    }
  }

  Future<void> _subir(List<int> bytes, String nome, String tipo, String mime) async {
    setState(() => _enviandoArquivo = true);
    try {
      await s.api.enviarArquivo(widget.canalId, Uint8List.fromList(bytes), nome, tipo, mime);
    } catch (_) {
      if (mounted) avisar(context, 'Não foi possível enviar $nome.');
    }
    if (mounted) setState(() => _enviandoArquivo = false);
  }

  String _mime(String nome) {
    final e = nome.split('.').last.toLowerCase();
    return switch (e) {
      'jpg' || 'jpeg' => 'image/jpeg', 'png' => 'image/png', 'gif' => 'image/gif', 'webp' => 'image/webp', 'heic' => 'image/heic',
      'pdf' => 'application/pdf', 'xml' => 'application/xml', 'txt' => 'text/plain', 'csv' => 'text/csv',
      'doc' => 'application/msword', 'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls' => 'application/vnd.ms-excel', 'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'mp4' => 'video/mp4', 'mov' => 'video/quicktime', 'webm' => 'audio/webm', 'm4a' => 'audio/mp4', 'ogg' => 'audio/ogg',
      _ => 'application/octet-stream',
    };
  }

  Future<void> _documento() async {
    final r = await FilePicker.pickFiles();
    for (final f in r) {
      final mime = _mime(f.name);
      await _subir(await f.readAsBytes(), f.name, mime.startsWith('image/') ? 'imagem' : 'documento', mime);
    }
  }

  Future<void> _imagem(ImageSource origem) async {
    final pic = ImagePicker();
    final lista = origem == ImageSource.gallery ? await pic.pickMultiImage() : [?await pic.pickImage(source: origem)];
    for (final x in lista) {
      await _subir(await x.readAsBytes(), x.name, 'imagem', x.mimeType ?? _mime(x.name));
    }
  }

  Future<void> _gravar() async {
    final g = AudioRecorder();
    if (!await g.hasPermission()) {
      if (mounted) avisar(context, 'Sem acesso ao microfone.');
      return;
    }
    _opus = await g.isEncoderSupported(AudioEncoder.opus);
    await g.start(RecordConfig(encoder: _opus ? AudioEncoder.opus : AudioEncoder.aacLc, bitRate: 32000), path: '');
    setState(() {
      _gravador = g;
      _segundos = 0;
    });
    _relogio = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _segundos++);
      if (_segundos >= 900) _pararGravacao(true);
    });
  }

  Future<void> _pararGravacao(bool enviar) async {
    final g = _gravador;
    if (g == null) return;
    _relogio?.cancel();
    final caminho = await g.stop();
    setState(() => _gravador = null);
    await g.dispose();
    if (!enviar || caminho == null || _segundos < 1) return;
    final bytes = await XFile(caminho).readAsBytes();
    await _subir(bytes, _opus ? 'audio.webm' : 'audio.m4a', 'audio', _opus ? 'audio/webm' : 'audio/mp4');
  }

  Future<void> _citarCliente() async {
    final e = await escolherEmpresa(context, s);
    if (e == null) return;
    final coment = _texto.text.trim();
    _texto.clear();
    try {
      await s.citarCliente(widget.canalId, e, coment);
    } catch (_) {
      if (mounted) avisar(context, 'Não foi possível citar o cliente.');
    }
  }

  void _acoes() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: EdgeInsets.fromLTRB(8, 0, 8, 12 + MediaQuery.of(ctx).padding.bottom),
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: GridView.count(
          crossAxisCount: 4, shrinkWrap: true, mainAxisSpacing: 12, childAspectRatio: .9,
          children: [
            _acao(ctx, Icons.description_outlined, 'Documento', const Color(0xFFE8EFFD), const Color(0xFF2F6FED), _documento),
            _acao(ctx, Icons.image_outlined, 'Fotos', const Color(0xFFE6F4EC), Cores.verde, () => _imagem(ImageSource.gallery)),
            _acao(ctx, Icons.photo_camera_outlined, 'Câmera', const Color(0xFFF1F3F6), Cores.texto, () => _imagem(ImageSource.camera)),
            _acao(ctx, Icons.apartment_rounded, 'Cliente', const Color(0xFFFBF1DC), Cores.douradoTexto, _citarCliente),
            _acao(ctx, Icons.assignment_outlined, 'Pedido', const Color(0xFFFBF1DC), Cores.douradoTexto,
                () => abrirNovoPedido(context, s, canal: widget.canalId)),
            _acao(ctx, Icons.notifications_none_rounded, 'Aviso', const Color(0xFFFBE8E8), Cores.vermelho, () => abrirNovoAviso(context, s)),
            _acao(ctx, Icons.event_outlined, 'Reunião', const Color(0xFFE8EFFD), const Color(0xFF2F6FED),
                () => abrirNovaReuniao(context, s, canal: widget.canalId)),
            _acao(ctx, Icons.alternate_email_rounded, 'Menção', const Color(0xFFF1F3F6), Cores.texto, () {
              _texto.text = '${_texto.text}@';
              _texto.selection = TextSelection.collapsed(offset: _texto.text.length);
              _foco.requestFocus();
            }),
          ],
        ),
      ),
    );
  }

  Widget _acao(BuildContext ctx, IconData ic, String nome, Color fundo, Color cor, VoidCallback f) => GestureDetector(
        onTap: () {
          Navigator.pop(ctx);
          f();
        },
        child: Column(children: [
          Container(width: 46, height: 46, decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(14)), child: Icon(ic, color: cor, size: 21)),
          const SizedBox(height: 5),
          Text(nome, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Color(0xFF3D4D60), fontWeight: FontWeight.w500)),
        ]),
      );

  void _menuMensagem(Mensagem m) {
    final minha = m.autorId == s.eu;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        Widget op(String t, IconData ic, VoidCallback f, {Color cor = Cores.texto}) => ListTile(
              dense: true,
              title: Text(t, style: TextStyle(fontSize: 13.5, color: cor)),
              trailing: Icon(ic, size: 18, color: cor),
              onTap: () {
                Navigator.pop(ctx);
                f();
              },
            );
        return folhaFlutuante(
          Column(mainAxisSize: MainAxisSize.min, children: [
            op('Responder', Icons.reply_rounded, () {
              setState(() => _resposta = m);
              _foco.requestFocus();
            }),
            if ((m.corpo ?? '').isNotEmpty)
              op('Copiar', Icons.copy_rounded, () {
                Clipboard.setData(ClipboardData(text: m.corpo!));
                avisar(context, 'Copiado.');
              }),
            op('Criar pedido desta mensagem', Icons.assignment_outlined, () => abrirNovoPedido(context, s, canal: widget.canalId, origem: m)),
            if (minha && m.tipo == 'texto') op('Editar', Icons.edit_outlined, () => _editar(m)),
            if (minha) op('Apagar para todos', Icons.delete_outline_rounded, () => _apagar(m), cor: Cores.vermelho),
          ]),
        );
      },
    );
  }

  Future<void> _editar(Mensagem m) async {
    final ctrl = TextEditingController(text: m.corpo);
    final novo = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar mensagem', style: TextStyle(fontSize: 15)),
        content: TextField(controller: ctrl, maxLines: 4, minLines: 1, autofocus: true, decoration: campo('')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: const Text('Salvar')),
        ],
      ),
    );
    if (novo == null || novo.isEmpty) return;
    try {
      await s.api.editar(m.id, novo);
      setState(() {
        m.corpo = novo;
        m.editadaEm = DateTime.now();
      });
    } catch (_) {
      if (mounted) avisar(context, 'Não foi possível editar.');
    }
  }

  Future<void> _apagar(Mensagem m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text('Apagar esta mensagem para todos?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Apagar', style: TextStyle(color: Cores.vermelho))),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await s.api.apagar(m.id);
      setState(() => s.mensagens[widget.canalId]?.removeWhere((x) => x.id == m.id));
    } catch (_) {
      if (mounted) avisar(context, 'Não foi possível apagar.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        final canal = c;
        if (canal == null) return const Scaffold(body: SizedBox());
        final msgs = s.mensagens[widget.canalId] ?? const <Mensagem>[];
        return Scaffold(
          backgroundColor: Cores.fundoApp,
          body: SafeArea(
            child: Column(children: [
              _cabecalho(canal),
              Expanded(
                child: ListView.builder(
                  controller: _rolagem,
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  itemCount: msgs.length,
                  itemBuilder: (_, i) {
                    final m = msgs[msgs.length - 1 - i];
                    final ant = msgs.length - 2 - i >= 0 ? msgs[msgs.length - 2 - i] : null;
                    final novoDia = ant == null || ant.criadaEm.day != m.criadaEm.day || ant.criadaEm.month != m.criadaEm.month;
                    return Column(children: [
                      if (novoDia) _dia(m.criadaEm),
                      _balao(m, msgs),
                    ]);
                  },
                ),
              ),
              if (_mencaoBusca != null) _sugestoes(),
              if (_resposta != null) _faixaResposta(),
              _compositor(),
            ]),
          ),
        );
      },
    );
  }

  Widget _cabecalho(Canal canal) {
    final nome = s.nomeCanal(canal);
    String sub;
    Widget av;
    if (canal.tipo == 'direta') {
      final p = s.equipe.pessoa(s.outroDaDireta(canal));
      final st = s.presencas[p.id] ?? 'offline';
      sub = '${statusPresenca[st] ?? 'Offline'}${p.nivel != null ? ' · ${p.nivel![0].toUpperCase()}${p.nivel!.substring(1)}' : ''}';
      av = bolinhaPessoa(p, tamanho: 32, status: st);
    } else if (canal.tipo == 'setor') {
      final ps = s.equipe.doSetor(canal.setorId);
      sub = '${ps.length} pessoas · ${ps.where((p) => (s.presencas[p.id] ?? 'offline') != 'offline').length} online';
      av = const Bolinha(texto: '#', tamanho: 32, escuro: true, quadrado: true);
    } else {
      sub = '${canal.membros.length} participantes';
      av = Bolinha(texto: iniciais(nome), tamanho: 32, quadrado: true);
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 12, 8),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Cores.linha))),
      child: Row(children: [
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.chevron_left_rounded, color: Cores.douradoTexto, size: 28)),
        av,
        const SizedBox(width: 9),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaDetalhes(store: s, canalId: canal.id))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(nome, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
              Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10.5, color: Cores.cinza)),
            ]),
          ),
        ),
        BotaoRedondo(chave: const Key('ligar-voz'), icone: Icons.call_outlined, aoTocar: () => widget.chamada.ligar(canal, 'voz')),
        BotaoRedondo(chave: const Key('ligar-video'), icone: Icons.videocam_outlined, aoTocar: () => widget.chamada.ligar(canal, 'video')),
        BotaoRedondo(icone: Icons.more_horiz_rounded,
            aoTocar: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TelaDetalhes(store: s, canalId: canal.id)))),
      ]),
    );
  }

  Widget _dia(DateTime d) {
    final hoje = DateTime.now();
    final t = (d.year == hoje.year && d.month == hoje.month && d.day == hoje.day) ? 'Hoje' : quando(d) == 'Ontem' ? 'Ontem' : dataCurta(d);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: const Color(0xFFEEF1F4), borderRadius: BorderRadius.circular(9)),
      child: Text(t, style: const TextStyle(fontSize: 10, color: Color(0xFF8B97A6), fontWeight: FontWeight.w500)),
    );
  }

  Widget _balao(Mensagem m, List<Mensagem> todas) {
    final minha = m.autorId == s.eu;
    if (m.tipo == 'sistema') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(m.corpo ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Cores.cinza)),
      );
    }
    final canal = c!;
    final mostrarAutor = !minha && canal.tipo != 'direta';
    final corTexto = minha ? const Color(0xFFEEF3F9) : Cores.texto;
    final filhos = <Widget>[];
    if (mostrarAutor) {
      filhos.add(Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(s.equipe.pessoa(m.autorId).nome, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Cores.douradoTexto)),
      ));
    }
    if (m.respondeA != null) {
      final orig = todas.where((x) => x.id == m.respondeA).firstOrNull;
      filhos.add(Container(
        margin: const EdgeInsets.only(bottom: 5),
        padding: const EdgeInsets.fromLTRB(7, 3, 7, 3),
        decoration: BoxDecoration(
          color: Cores.dourado.withValues(alpha: .12),
          border: const Border(left: BorderSide(color: Cores.dourado, width: 2)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          orig == null ? 'Mensagem' : '${s.equipe.pessoa(orig.autorId).nome.split(' ').first}: ${orig.corpo ?? ''}',
          maxLines: 2, overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10.5, color: minha ? const Color(0xFFC9D6E4) : Cores.cinza),
        ),
      ));
    }
    if (m.tipo == 'pedido') {
      filhos.add(_cartaoPedido(m, minha));
    } else {
      for (final a in m.anexos) {
        filhos.add(_anexo(a, minha));
      }
      final cid = m.meta['cliente_id'] as String?;
      if (cid != null) filhos.add(_chipCliente(cid));
      final mostrarCorpo = (m.corpo ?? '').isNotEmpty && !(m.anexos.isNotEmpty && (m.tipo == 'arquivo' || m.tipo == 'audio')) && !(cid != null && m.corpo == 'Cliente citado');
      if (mostrarCorpo) filhos.add(_textoComMencoes(m.corpo!, corTexto));
    }
    filhos.add(Row(mainAxisSize: MainAxisSize.min, children: [
      if (m.editadaEm != null) Text('editada · ', style: TextStyle(fontSize: 9, color: corTexto.withValues(alpha: .6))),
      Text(hora(m.criadaEm), style: TextStyle(fontSize: 9, color: corTexto.withValues(alpha: .6))),
      if (minha) ...[
        const SizedBox(width: 3),
        Icon(m.provisoria ? Icons.schedule_rounded : (m.lidoPor.any((u) => u != s.eu) ? Icons.done_all_rounded : Icons.done_rounded),
            size: 12, color: m.provisoria ? const Color(0xFF9AA5B2) : (m.lidoPor.any((u) => u != s.eu) ? Cores.dourado : const Color(0xFF9AA5B2))),
      ],
    ]));
    return Align(
      alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onLongPress: m.provisoria ? null : () => _menuMensagem(m),
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .78),
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.fromLTRB(10, 7, 10, 6),
          decoration: BoxDecoration(
            color: minha ? Cores.marinho : Colors.white,
            border: minha ? null : Border.all(color: Cores.linha),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(14), topRight: const Radius.circular(14),
              bottomLeft: Radius.circular(minha ? 14 : 4), bottomRight: Radius.circular(minha ? 4 : 14),
            ),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, mainAxisSize: MainAxisSize.min, children: [
            Align(alignment: Alignment.centerLeft, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: filhos.sublist(0, filhos.length - 1))),
            filhos.last,
          ]),
        ),
      ),
    );
  }

  Widget _textoComMencoes(String t, Color cor) {
    final nomes = s.equipe.pessoas.map((p) => RegExp.escape('@${p.nome}')).toList()..sort((a, b) => b.length.compareTo(a.length));
    if (nomes.isEmpty) return Text(t, style: TextStyle(fontSize: 12.5, height: 1.4, color: cor));
    final re = RegExp(nomes.join('|'));
    final partes = <TextSpan>[];
    var i = 0;
    for (final m in re.allMatches(t)) {
      if (m.start > i) partes.add(TextSpan(text: t.substring(i, m.start)));
      partes.add(TextSpan(text: m.group(0), style: const TextStyle(color: Cores.dourado, fontWeight: FontWeight.w600)));
      i = m.end;
    }
    if (i < t.length) partes.add(TextSpan(text: t.substring(i)));
    return Text.rich(TextSpan(children: partes), style: TextStyle(fontSize: 12.5, height: 1.4, color: cor));
  }

  Widget _chipCliente(String id) {
    final e = s.empresas[id];
    return GestureDetector(
      onTap: e == null ? null : () => mostrarEmpresa(context, e),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(color: Cores.dourado.withValues(alpha: .16), borderRadius: BorderRadius.circular(8)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.apartment_rounded, size: 14, color: Color(0xFF8A6418)),
          const SizedBox(width: 5),
          Flexible(child: Text(e?.nome ?? 'Cliente', style: const TextStyle(fontSize: 12, color: Color(0xFF8A6418), fontWeight: FontWeight.w500))),
        ]),
      ),
    );
  }

  Widget _cartaoPedido(Mensagem m, bool minha) {
    final dono = s.equipe.pessoa(m.meta['responsavel_id'] as String?).nome;
    final prazo = DateTime.tryParse((m.meta['prazo'] ?? '').toString());
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('PEDIDO', style: TextStyle(fontSize: 9, letterSpacing: 1, fontWeight: FontWeight.w600, color: Cores.douradoTexto)),
      const SizedBox(height: 3),
      Text(m.corpo ?? '', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: minha ? Colors.white : Cores.texto)),
      const SizedBox(height: 2),
      Text('Dono: $dono${prazo != null ? ' · Prazo ${dataCurta(prazo)}' : ''}',
          style: TextStyle(fontSize: 10.5, color: minha ? const Color(0xFFC9D6E4) : Cores.cinza)),
    ]);
  }

  Widget _anexo(Anexo a, bool minha) {
    if (a.tipo == 'audio') return _Audio(store: s, anexo: a, minha: minha);
    if (a.tipo == 'imagem') {
      return FutureBuilder<String>(
        future: a.url == null ? null : s.api.linkAnexo(a.url!),
        builder: (_, snap) => GestureDetector(
          onTap: snap.data == null ? null : () => launchUrl(Uri.parse(snap.data!)),
          child: Container(
            margin: const EdgeInsets.only(bottom: 4),
            width: 200, height: 150, clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: const Color(0xFFEEF1F4), borderRadius: BorderRadius.circular(10)),
            child: snap.data == null ? null : Image.network(snap.data!, fit: BoxFit.cover),
          ),
        ),
      );
    }
    final kb = (a.tamanho ?? 0) / 1024;
    final ext = (a.nome ?? '').contains('.') ? a.nome!.split('.').last.toUpperCase() : 'ARQ';
    return GestureDetector(
      onTap: () async {
        if (a.url == null) return;
        final u = await s.api.linkAnexo(a.url!);
        launchUrl(Uri.parse(u));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: minha ? const Color(0x22FFFFFF) : const Color(0xFFF4F6F9), borderRadius: BorderRadius.circular(9)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 28, height: 32, alignment: Alignment.center,
            decoration: BoxDecoration(color: ext == 'PDF' ? Cores.vermelho : const Color(0xFF2F6FED), borderRadius: BorderRadius.circular(5)),
            child: Text(ext.length > 4 ? ext.substring(0, 4) : ext, style: const TextStyle(fontSize: 7, color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(a.nome ?? 'Arquivo', maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: minha ? Colors.white : Cores.texto)),
              Text(kb > 1024 ? '${(kb / 1024).toStringAsFixed(1)} MB' : '${kb.toStringAsFixed(0)} KB',
                  style: TextStyle(fontSize: 9.5, color: minha ? const Color(0xFFC9D6E4) : const Color(0xFF8B97A6))),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _sugestoes() {
    final b = (_mencaoBusca ?? '').toLowerCase();
    final lista = s.equipe.pessoas.where((p) => p.id != s.eu && p.nome.toLowerCase().contains(b)).take(5).toList();
    if (lista.isEmpty) return const SizedBox.shrink();
    return Container(
      color: Colors.white,
      child: Column(children: [
        for (final p in lista)
          ListTile(
            dense: true,
            leading: bolinhaPessoa(p, tamanho: 28),
            title: Text(p.nome, style: const TextStyle(fontSize: 13)),
            onTap: () => _inserirMencao(p),
          ),
      ]),
    );
  }

  Widget _faixaResposta() {
    final r = _resposta!;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 8, 4, 0),
      child: Row(children: [
        Container(width: 2, height: 30, color: Cores.dourado),
        const SizedBox(width: 8),
        Expanded(
          child: Text('${s.equipe.pessoa(r.autorId).nome}: ${r.corpo ?? ''}', maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11.5, color: Cores.cinza)),
        ),
        IconButton(onPressed: () => setState(() => _resposta = null), icon: const Icon(Icons.close_rounded, size: 18, color: Cores.cinza)),
      ]),
    );
  }

  Widget _compositor() {
    if (_gravador != null) {
      return Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        color: Colors.white,
        child: Row(children: [
          IconButton(onPressed: () => _pararGravacao(false), icon: const Icon(Icons.delete_outline_rounded, color: Cores.vermelho)),
          const Icon(Icons.fiber_manual_record_rounded, color: Cores.vermelho, size: 12),
          const SizedBox(width: 6),
          Text('Gravando ${_segundos ~/ 60}:${(_segundos % 60).toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 13)),
          const Spacer(),
          GestureDetector(
            onTap: () => _pararGravacao(true),
            child: Container(width: 34, height: 34, decoration: const BoxDecoration(color: Cores.marinho, shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded, color: Cores.dourado, size: 16)),
          ),
        ]),
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Cores.linha))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        GestureDetector(
          key: const Key('mais'),
          onTap: _enviandoArquivo ? null : _acoes,
          child: Container(
            width: 34, height: 34,
            decoration: const BoxDecoration(color: Color(0xFFF1F3F6), shape: BoxShape.circle),
            child: _enviandoArquivo
                ? const Padding(padding: EdgeInsets.all(9), child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.add_rounded, size: 20, color: Cores.texto),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            key: const Key('mensagem'),
            controller: _texto,
            focusNode: _foco,
            minLines: 1, maxLines: 5,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _enviar(),
            onChanged: (_) => setState(() {}),
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Mensagem', hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF8B97A6)),
              filled: true, fillColor: const Color(0xFFF1F3F6), isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          key: const Key('enviar'),
          onTap: _texto.text.trim().isEmpty ? _gravar : _enviar,
          child: Container(
            width: 34, height: 34,
            decoration: const BoxDecoration(color: Cores.marinho, shape: BoxShape.circle),
            child: Icon(_texto.text.trim().isEmpty ? Icons.mic_none_rounded : Icons.send_rounded, color: Cores.dourado, size: 17),
          ),
        ),
      ]),
    );
  }
}

class _Audio extends StatefulWidget {
  const _Audio({required this.store, required this.anexo, required this.minha});
  final TeamsStore store;
  final Anexo anexo;
  final bool minha;
  @override
  State<_Audio> createState() => _AudioState();
}

class _AudioState extends State<_Audio> {
  AudioPlayer? _p;
  bool _tocando = false;

  @override
  void dispose() {
    _p?.dispose();
    super.dispose();
  }

  Future<void> _alternar() async {
    if (_p == null) {
      final url = await widget.store.api.linkAnexo(widget.anexo.url!);
      _p = AudioPlayer();
      await _p!.setUrl(url);
      _p!.playerStateStream.listen((st) {
        if (!mounted) return;
        setState(() => _tocando = st.playing && st.processingState != ProcessingState.completed);
        if (st.processingState == ProcessingState.completed) {
          _p!.pause();
          _p!.seek(Duration.zero);
        }
      });
    }
    _tocando ? await _p!.pause() : await _p!.play();
  }

  @override
  Widget build(BuildContext context) {
    final cor = widget.minha ? const Color(0xB3EEF3F9) : const Color(0xFF9AA5B2);
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          GestureDetector(
            onTap: widget.anexo.url == null ? null : _alternar,
            child: Container(width: 26, height: 26, decoration: const BoxDecoration(color: Cores.dourado, shape: BoxShape.circle),
                child: Icon(_tocando ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 16, color: const Color(0xFF1A1204))),
          ),
          const SizedBox(width: 8),
          for (final h in const [6.0, 12.0, 8.0, 14.0, 5.0, 10.0, 13.0, 7.0, 11.0, 6.0, 9.0, 12.0])
            Container(width: 2, height: h, margin: const EdgeInsets.only(right: 2), decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(1))),
        ]),
        if ((widget.anexo.transcricao ?? '').isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(widget.anexo.transcricao!, style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: cor)),
          ),
      ]),
    );
  }
}
