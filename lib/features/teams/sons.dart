import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';

class Sons {
  Sons._();
  static final Sons i = Sons._();

  AudioPlayer? _toque;
  AudioPlayer? _msg;
  bool _tocando = false;

  bool _destravado = false;

  Future<void> destravar() async {
    if (_destravado) return;
    _destravado = true;
    try {
      _toque ??= AudioPlayer();
      _msg ??= AudioPlayer();
      for (final p in [_toque!, _msg!]) {
        await p.setVolume(0);
        await p.setAsset('assets/sons/mensagem.wav');
        await p.play();
        await p.stop();
        await p.setVolume(1);
      }
    } catch (_) {}
  }

  Future<void> tocarChamada() async {
    if (_tocando) return;
    _tocando = true;
    try {
      _toque ??= AudioPlayer();
      await _toque!.setAsset('assets/sons/toque.wav');
      await _toque!.setLoopMode(LoopMode.one);
      _toque!.play();
    } catch (_) {}
    _vibrarEnquantoToca();
  }

  Future<void> _vibrarEnquantoToca() async {
    while (_tocando) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 1200));
    }
  }

  Future<void> pararChamada() async {
    _tocando = false;
    try {
      await _toque?.stop();
    } catch (_) {}
  }

  Future<void> mensagem() async {
    try {
      _msg ??= AudioPlayer();
      await _msg!.setAsset('assets/sons/mensagem.wav');
      _msg!.play();
    } catch (_) {}
    HapticFeedback.mediumImpact();
  }
}
