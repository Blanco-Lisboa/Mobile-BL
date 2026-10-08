class Push {
  static bool get suportado => false;
  static String get permissao => 'denied';
  static Future<String> pedir() async => 'denied';
  static Future<Map<String, dynamic>?> inscrever(String chave) async => null;
  static void fecharTag(String tag) {}
  static void contador(int n) {}
  static void aoAbrir(void Function(String url) f) {}
}
