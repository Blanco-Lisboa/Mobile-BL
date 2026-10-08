import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/sessao.dart';
import '../../core/tema.dart';
import '../../data/foto.dart';
import '../../data/perfil_repo.dart';

const _statusOpcoes = [
  ['online', 'Online'],
  ['reuniao', 'Reunião'],
  ['ausente', 'Ausente'],
  ['nao_perturbe', 'Não perturbe'],
];

Widget avatar(Map<String, dynamic>? p, double tam) {
  final foto = p?['foto_url'] as String?;
  final ini = ((p?['nome'] as String?) ?? 'BL')
      .trim()
      .split(RegExp(r'\s+'))
      .take(2)
      .map((e) => e[0])
      .join()
      .toUpperCase();
  ImageProvider? img;
  if (foto != null && foto.startsWith('data:')) {
    img = MemoryImage(UriData.parse(foto).contentAsBytes());
  }
  if (foto != null && foto.startsWith('http')) img = NetworkImage(foto);
  final letras = Text(
    ini,
    style: TextStyle(
      color: Cores.dourado,
      fontSize: tam * .32,
      fontWeight: FontWeight.w500,
    ),
  );
  return Container(
    width: tam,
    height: tam,
    clipBehavior: Clip.antiAlias,
    decoration: const BoxDecoration(
      color: Cores.marinho,
      shape: BoxShape.circle,
    ),
    alignment: Alignment.center,
    child: img == null
        ? letras
        : Image(
            image: img,
            width: tam,
            height: tam,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => letras,
          ),
  );
}

Future<void> abrirPerfil(
  BuildContext context, {
  required Sessao sessao,
  required PerfilRepo repo,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) => _FolhaPerfil(sessao: sessao, repo: repo),
  );
}

class _FolhaPerfil extends StatefulWidget {
  const _FolhaPerfil({required this.sessao, required this.repo});
  final Sessao sessao;
  final PerfilRepo repo;
  @override
  State<_FolhaPerfil> createState() => _FolhaPerfilState();
}

class _FolhaPerfilState extends State<_FolhaPerfil> {
  Map<String, dynamic>? p;
  String status = 'online';
  String? novaFoto;
  String? msg;
  final email = TextEditingController();
  final whats = TextEditingController();
  final senha = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.wait([widget.repo.ler(), widget.repo.lerStatus()]).then((r) {
      if (!mounted) return;
      setState(() {
        p = r[0] as Map<String, dynamic>;
        status = r[1] as String;
        email.text = (p!['email'] ?? '') as String;
        whats.text = (p!['whatsapp'] ?? '') as String;
      });
    });
  }

  Future<void> _foto() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (x == null) return;
    final Uint8List b = await x.readAsBytes();
    setState(() => novaFoto = reduzirParaDataUrl(b));
  }

  Future<void> _mudarStatus(String s) async {
    try {
      await widget.repo.definirStatus(s);
      setState(() => status = s);
    } catch (_) {
      setState(() => msg = 'Status não salvou');
    }
  }

  Future<void> _salvar() async {
    try {
      await widget.repo.salvar(
        email: email.text,
        whatsapp: whats.text,
        fotoDataUrl: novaFoto,
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      setState(() => msg = 'Não salvou');
    }
  }

  Future<void> _senha() async {
    final e = await widget.repo.trocarSenha(senha.text);
    setState(() {
      msg = e ?? 'Senha trocada';
      senha.clear();
    });
  }

  Widget _linha(String k, Widget v) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Cores.linha)),
    ),
    child: Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            k,
            style: const TextStyle(color: Cores.cinza, fontSize: 12),
          ),
        ),
        Expanded(child: v),
      ],
    ),
  );

  Widget _fixo(String v) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Text(
      v,
      textAlign: TextAlign.right,
      style: const TextStyle(color: Cores.cinzaStatus, fontSize: 12),
    ),
  );

  Widget _edit(
    TextEditingController c, {
    bool oculto = false,
    String dica = '',
  }) => TextField(
    controller: c,
    obscureText: oculto,
    textAlign: TextAlign.right,
    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
    decoration: InputDecoration(
      border: InputBorder.none,
      isDense: true,
      hintText: dica,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final vis = p == null
        ? null
        : {...p!, if (novaFoto != null) 'foto_url': novaFoto};
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        10,
        18,
        18 +
            MediaQuery.of(context).viewInsets.bottom +
            MediaQuery.of(context).padding.bottom,
      ),
      child: p == null
          ? const SizedBox(
              height: 240,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9DEE5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Meu perfil',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _salvar,
                        child: const Text(
                          'Salvar',
                          style: TextStyle(
                            color: Cores.douradoTexto,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  avatar(vis, 64),
                  TextButton(
                    onPressed: _foto,
                    child: const Text(
                      'Trocar foto',
                      style: TextStyle(color: Cores.douradoTexto, fontSize: 12),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Cores.fundoApp,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _linha('Nome', _fixo((p!['nome'] ?? '') as String)),
                        _linha(
                          'Nível',
                          _fixo(((p!['nivel'] ?? '') as String).toUpperCase()),
                        ),
                        _linha('E-mail', _edit(email)),
                        _linha('WhatsApp', _edit(whats)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'STATUS',
                      style: TextStyle(
                        fontSize: 10,
                        letterSpacing: 1.4,
                        color: Color(0xFF8B97A6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF1F4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        for (final s in _statusOpcoes)
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _mudarStatus(s[0]),
                              child: Container(
                                height: 30,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: status == s[0]
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: status == s[0]
                                      ? const [
                                          BoxShadow(
                                            color: Color(0x1F0E1A2B),
                                            blurRadius: 3,
                                            offset: Offset(0, 1),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: FittedBox(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Text(
                                      s[1],
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w500,
                                        color: status == s[0]
                                            ? Cores.texto
                                            : const Color(0xFF5C6878),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    decoration: BoxDecoration(
                      color: Cores.fundoApp,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _linha(
                      'Nova senha',
                      Row(
                        children: [
                          Expanded(
                            child: _edit(senha, oculto: true, dica: 'mín. 8'),
                          ),
                          TextButton(
                            onPressed: _senha,
                            child: const Text(
                              'Trocar',
                              style: TextStyle(
                                fontSize: 12,
                                color: Cores.douradoTexto,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (msg != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        msg!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Cores.cinza,
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.sessao.sair();
                    },
                    child: const Text(
                      'Sair',
                      style: TextStyle(
                        color: Cores.vermelho,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
