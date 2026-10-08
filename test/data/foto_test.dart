import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mobile_bl/data/foto.dart';

void main() {
  test('reduz para no máximo 256 px em JPEG data URL', () {
    final grande = img.Image(width: 1000, height: 500);
    final url = reduzirParaDataUrl(img.encodePng(grande));
    expect(url.startsWith('data:image/jpeg;base64,'), isTrue);
    final volta = img.decodeJpg(base64Decode(url.split(',')[1]))!;
    expect(volta.width, 256);
    expect(volta.height, 128);
  });
}
