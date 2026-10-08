import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_bl/core/sessao.dart';
import 'package:mobile_bl/features/login/tela_login.dart';

import '../../core/sessao_test.dart' show RepoFalso;

void main() {
  testWidgets('mostra erro de não CEO', (t) async {
    final s = Sessao(RepoFalso(nivel: 'diretor'));
    await t.pumpWidget(
      MaterialApp(
        home: ListenableBuilder(
          listenable: s,
          builder: (_, _) => TelaLogin(sessao: s),
        ),
      ),
    );
    await t.enterText(find.byKey(const Key('email')), 'a@b.com');
    await t.enterText(find.byKey(const Key('senha')), '12345678');
    await t.tap(find.byKey(const Key('entrar')));
    await t.pumpAndSettle();
    expect(find.text('Acesso exclusivo para CEO'), findsWidgets);
  });
}
