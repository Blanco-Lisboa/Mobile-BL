import 'package:flutter/material.dart';

class Cores {
  static const marinho = Color(0xFF0A1B30);
  static const loginTopo = Color(0xFF12304F);
  static const loginMeio = Color(0xFF061527);
  static const loginFundo = Color(0xFF020A14);
  static const dourado = Color(0xFFEDB449);
  static const douradoTexto = Color(0xFFB07F1C);
  static const fundoApp = Color(0xFFF7F8FA);
  static const fundoChat = Color(0xFFE9F0F7);
  static const marinhoClaro = Color(0xFF16395F);
  static const texto = Color(0xFF0E1A2B);
  static const cinza = Color(0xFF7A8797);
  static const linha = Color(0xFFEEF0F3);
  static const verde = Color(0xFF2E9E5B);
  static const amarelo = Color(0xFFE0A62B);
  static const cinzaStatus = Color(0xFFA9B3BF);
  static const vermelho = Color(0xFFD64545);
}

ThemeData temaClaro() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Inter',
  );
  return base.copyWith(
    scaffoldBackgroundColor: Cores.fundoApp,
    colorScheme: base.colorScheme.copyWith(
      primary: Cores.marinho,
      secondary: Cores.dourado,
      surface: Colors.white,
      error: Cores.vermelho,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: Cores.texto,
      displayColor: Cores.texto,
    ),
    splashFactory: NoSplash.splashFactory,
  );
}
