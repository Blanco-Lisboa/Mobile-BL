import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

String reduzirParaDataUrl(Uint8List bytes) {
  final o = img.decodeImage(bytes)!;
  final escala = [
    256 / o.width,
    256 / o.height,
    1.0,
  ].reduce((a, b) => a < b ? a : b);
  final r = img.copyResize(
    o,
    width: (o.width * escala).round(),
    height: (o.height * escala).round(),
  );
  return 'data:image/jpeg;base64,${base64Encode(img.encodeJpg(r, quality: 82))}';
}
