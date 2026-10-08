import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_bl/core/sessao.dart';
import 'package:mobile_bl/data/perfil_repo.dart';
import 'package:mobile_bl/features/perfil/folha_perfil.dart';

import '../../core/sessao_test.dart' show RepoFalso;

class PerfilFalso implements PerfilRepo {
  String status = 'online';
  Map<String, dynamic>? salvo;
  @override
  Future<Map<String, dynamic>> ler() async => {
    'nome': 'William Ramos',
    'nivel': 'ceo',
    'email': 'w@bl.com',
    'whatsapp': '11999990000',
  };
  @override
  Future<String> lerStatus() async => status;
  @override
  Future<void> salvar({
    required String email,
    required String whatsapp,
    String? fotoDataUrl,
  }) async {
    salvo = {'email': email, 'whatsapp': whatsapp};
  }

  @override
  Future<void> definirStatus(String s) async => status = s;
  @override
  Future<String?> trocarSenha(String n) async => null;
}

void main() {
  testWidgets('mostra dados, troca status e salva', (t) async {
    final repo = PerfilFalso();
    final s = Sessao(RepoFalso());
    await t.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (c) => TextButton(
            onPressed: () => abrirPerfil(c, sessao: s, repo: repo),
            child: const Text('abrir'),
          ),
        ),
      ),
    );
    await t.tap(find.text('abrir'));
    await t.pumpAndSettle();
    expect(find.text('William Ramos'), findsOneWidget);
    expect(find.text('CEO'), findsOneWidget);
    await t.tap(find.text('Reunião'));
    await t.pumpAndSettle();
    expect(repo.status, 'reuniao');
    await t.tap(find.text('Salvar'));
    await t.pumpAndSettle();
    expect(repo.salvo!['email'], 'w@bl.com');
  });
}
