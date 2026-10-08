import 'package:flutter/material.dart';

import '../../core/sessao.dart';
import '../../core/tema.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key, required this.sessao});
  final Sessao sessao;
  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _enviando = false;

  Future<void> _entrar() async {
    setState(() => _enviando = true);
    await widget.sessao.entrar(_email.text, _senha.text);
    if (mounted) setState(() => _enviando = false);
  }

  InputDecoration _campo(String r) => InputDecoration(
    hintText: r,
    hintStyle: const TextStyle(color: Color(0xFF7F93AA), fontSize: 14),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0x24FFFFFF)),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Cores.dourado),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final erro = widget.sessao.erro;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1.2),
            radius: 1.4,
            colors: [Cores.loginTopo, Cores.loginMeio, Cores.loginFundo],
            stops: [0, .5, 1],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', width: 124),
                    const SizedBox(height: 22),
                    const Text(
                      'Blanco & Lisboa',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'ACESSO EXCLUSIVO CEO',
                      style: TextStyle(
                        color: Color(0xFF8FA3BA),
                        fontSize: 10,
                        letterSpacing: 2.4,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      key: const Key('email'),
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: _campo('E-mail'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      key: const Key('senha'),
                      controller: _senha,
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _entrar(),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: _campo('Senha'),
                    ),
                    if (erro != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        erro,
                        style: const TextStyle(
                          color: Color(0xFFF08A8A),
                          fontSize: 12,
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: TextButton(
                        key: const Key('entrar'),
                        onPressed: _enviando ? null : _entrar,
                        style: TextButton.styleFrom(
                          backgroundColor: const Color(0xFFF2F4F7),
                          foregroundColor: Cores.marinho,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: _enviando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Entrar',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
