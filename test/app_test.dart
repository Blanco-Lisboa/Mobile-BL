import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_bl/app.dart';
import 'package:mobile_bl/core/sessao.dart';
import 'core/sessao_test.dart' show RepoFalso;
import 'features/perfil/folha_perfil_test.dart' show PerfilFalso;

void main() {
  testWidgets('sem sessão mostra login; CEO logado vê o card TEAM\'s', (t) async {
    final s = Sessao(RepoFalso());
    await t.pumpWidget(AppBl(sessao: s, perfil: PerfilFalso()));
    await s.iniciar();
    await t.pumpAndSettle();
    expect(find.text('Entrar'), findsOneWidget);
    await s.entrar('a@b.com', '12345678');
    await t.pumpAndSettle();
    expect(find.byKey(const Key('card-teams')), findsOneWidget);
  });
}
