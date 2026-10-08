import 'dart:js_interop';

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

class AreaSegura extends StatefulWidget {
  const AreaSegura({super.key, required this.child});
  final Widget child;
  @override
  State<AreaSegura> createState() => _AreaSeguraState();
}

class _AreaSeguraState extends State<AreaSegura> {
  EdgeInsets _area = EdgeInsets.zero;
  web.HTMLDivElement? _medidor;
  JSFunction? _aoMudar;

  @override
  void initState() {
    super.initState();
    final d = web.document.createElement('div') as web.HTMLDivElement;
    d.style.cssText =
        'position:fixed;left:0;top:0;width:0;height:0;visibility:hidden;pointer-events:none;'
        'padding-top:env(safe-area-inset-top);padding-bottom:env(safe-area-inset-bottom);'
        'padding-left:env(safe-area-inset-left);padding-right:env(safe-area-inset-right);';
    web.document.body?.append(d);
    _medidor = d;
    _aoMudar = ((web.Event _) => _medir()).toJS;
    web.window.addEventListener('resize', _aoMudar);
    web.window.addEventListener('orientationchange', _aoMudar);
    _medir();
  }

  double _px(String v) => double.tryParse(v.replaceAll('px', '').trim()) ?? 0;

  void _medir() {
    final d = _medidor;
    if (d == null) return;
    final c = web.window.getComputedStyle(d);
    final novo = EdgeInsets.fromLTRB(
      _px(c.paddingLeft),
      _px(c.paddingTop),
      _px(c.paddingRight),
      _px(c.paddingBottom),
    );
    if (novo != _area && mounted) setState(() => _area = novo);
  }

  @override
  void dispose() {
    web.window.removeEventListener('resize', _aoMudar);
    web.window.removeEventListener('orientationchange', _aoMudar);
    _medidor?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final area = EdgeInsets.fromLTRB(
      mq.padding.left > _area.left ? mq.padding.left : _area.left,
      mq.padding.top > _area.top ? mq.padding.top : _area.top,
      mq.padding.right > _area.right ? mq.padding.right : _area.right,
      mq.padding.bottom > _area.bottom ? mq.padding.bottom : _area.bottom,
    );
    final semTeclado = mq.viewInsets.bottom > 0
        ? area.copyWith(bottom: 0)
        : area;
    return MediaQuery(
      data: mq.copyWith(padding: semTeclado, viewPadding: area),
      child: widget.child,
    );
  }
}
