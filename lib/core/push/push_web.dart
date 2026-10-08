import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

JSObject? get _bl => globalContext.getProperty<JSObject?>('blPush'.toJS);

class Push {
  static bool get suportado {
    final b = _bl;
    if (b == null) return false;
    return (b.callMethod<JSBoolean>('suportado'.toJS)).toDart;
  }

  static String get permissao {
    final b = _bl;
    if (b == null) return 'denied';
    return (b.callMethod<JSString>('permissao'.toJS)).toDart;
  }

  static Future<String> pedir() async {
    final b = _bl;
    if (b == null) return 'denied';
    final r = await (b.callMethod<JSPromise<JSString>>('pedir'.toJS)).toDart;
    return r.toDart;
  }

  static Future<Map<String, dynamic>?> inscrever(String chave) async {
    final b = _bl;
    if (b == null) return null;
    final r = (await (b.callMethod<JSPromise<JSString>>(
      'inscrever'.toJS,
      chave.toJS,
    )).toDart).toDart;
    if (r.isEmpty) return null;
    return Map<String, dynamic>.from(jsonDecode(r) as Map);
  }

  static void _avisar(Map<String, Object> m) {
    final b = _bl;
    if (b == null) return;
    b.callMethod<JSAny?>('avisarSw'.toJS, m.jsify());
  }

  static void fecharTag(String tag) => _avisar({'fecharTag': tag});
  static void contador(int n) => _avisar({'contador': n});

  static void aoAbrir(void Function(String url) f) {
    final b = _bl;
    if (b == null) return;
    b.callMethod<JSAny?>('aoAbrir'.toJS, ((JSString u) => f(u.toDart)).toJS);
  }
}
