import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:mobile_bl/core/tema.dart';

void main() {
  test('tema claro usa o fundo e o dourado da marca', () {
    final t = temaClaro();
    expect(t.scaffoldBackgroundColor, const Color(0xFFF7F8FA));
    expect(t.colorScheme.secondary, const Color(0xFFEDB449));
    expect(Cores.marinho, const Color(0xFF0A1B30));
  });
}
