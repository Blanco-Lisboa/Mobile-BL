# App BL CEO — Etapa 1: base, login só CEO, início e Meu perfil — Plano de implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** App Flutter (web instalável) onde só um CEO da BL entra, vê o início com o card TEAM's e edita o Meu perfil nas mesmas funções do Java CEO.

**Architecture:** Flutter com dois clientes Supabase (BL central para login/perfil; TEAM's para a sessão de conversas, obtida pela edge `teams-entrar`). Repositórios por assunto atrás de interfaces (telas só falam com interfaces → testáveis com dublês). Estado simples com `ChangeNotifier`.

**Tech Stack:** Flutter 3.47 (stable), Dart 3, `supabase_flutter` 2.x, `google_fonts`, `image` (redimensionar foto), `flutter_test`.

**Spec:** `docs/superpowers/specs/2026-10-07-app-bl-ceo-design.md`

## Global Constraints
- Repositório PÚBLICO: só chaves públicas (`sb_publishable_…`) no código; nenhum segredo.
- BL central: `https://wfqcoocfastgsfgegpcm.supabase.co`, chave `sb_publishable_88ukR4t1KNTc73DxbF6-Pw_0CKW16Fe`.
- TEAM's: `https://lhqjfdexfexpmnoqhbyv.supabase.co`, chave `sb_publishable_wJLNCeunyVFZz4yUJAaJMQ_x7qPMU_v`.
- Só nível `ceo` (campo `nivel` de `meu_perfil_ler`) entra; os demais: sair e mostrar "Acesso exclusivo para CEO".
- Cores: marinho `#0A1B30`, fundo login `#061527`→`#020A14`, dourado `#EDB449`, fundo app `#F7F8FA`, texto `#0E1A2B`, cinza `#7A8797`, linha `#EEF0F3`, verde `#2E9E5B`, amarelo `#E0A62B`, cinza status `#A9B3BF`, vermelho `#D64545`. Letra Inter. Cantos 10–16 px. Sem degradê/brilho em botão.
- Textos da interface em português do Brasil; sem texto de aviso/explicação na tela; sem comentário narrativo no código.
- Nada de consulta repetida no tempo (sem polling).
- Perfil: mesmas funções do painel — `meu_perfil_ler()`, `meu_perfil_salvar(p_email,p_whatsapp,p_foto_url)`, `presenca_minha_ler()`, `presenca_minha_definir(p_status)` (status: `online`, `reuniao`, `ausente`, `nao_perturbe`), edge `ceo-trocar-senha` com corpo `{access_token, nova_senha}` (mín. 8).
- Foto: igual ao painel — JPEG redimensionado para no máximo 256 px, qualidade ~82, gravado como `data:image/jpeg;base64,…` em `foto_url`.

---

## Estrutura de arquivos
```
pubspec.yaml
lib/main.dart                         inicia clientes e abre o app
lib/app.dart                          MaterialApp + troca login/início pela sessão
lib/config/bancos.dart                URLs e chaves públicas
lib/core/tema.dart                    cores e letras
lib/core/sessao.dart                  Sessao (ChangeNotifier): estado de login
lib/data/auth_repo.dart               interface + implementação Supabase do login
lib/data/perfil_repo.dart             interface + implementação Supabase do perfil
lib/data/foto.dart                    reduzir imagem para data URL
lib/features/login/tela_login.dart
lib/features/inicio/tela_inicio.dart
lib/features/perfil/folha_perfil.dart
web/manifest.json, web/index.html, web/icons/*   PWA
assets/logo.png                       logo estático do login
test/...                              testes espelhando lib/
```

---

### Task 1: Projeto, tema e logo

**Files:**
- Create: projeto Flutter em `C:\Projetos\Mobile-BL` (`flutter create`), `lib/core/tema.dart`, `lib/config/bancos.dart`, `assets/logo.png`
- Test: `test/core/tema_test.dart`

**Interfaces:**
- Produces: `class Cores { static const marinho, dourado, fundoApp, texto, cinza, linha, verde, amarelo, cinzaStatus, vermelho; }`, `ThemeData temaClaro()`, `class Bancos { static const blUrl, blChave, teamsUrl, teamsChave; }`

- [ ] **Step 1:** Criar o projeto
```bash
cd /c/Projetos/Mobile-BL
flutter create --org br.com.blcontabil --project-name mobile_bl --platforms=web,android,ios .
flutter pub add supabase_flutter google_fonts image
mkdir -p assets && cp ".superpowers/brainstorm/1609-1791409893/content/logo-novo.png" assets/logo.png
```
Em `pubspec.yaml`, dentro de `flutter:` acrescentar:
```yaml
  assets:
    - assets/logo.png
```
- [ ] **Step 2: Teste que falha** — `test/core/tema_test.dart`
```dart
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
```
- [ ] **Step 3:** `flutter test test/core/tema_test.dart` → FAIL (arquivo não existe).
- [ ] **Step 4: Implementar** `lib/core/tema.dart`
```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Cores {
  static const marinho = Color(0xFF0A1B30);
  static const loginTopo = Color(0xFF12304F);
  static const loginMeio = Color(0xFF061527);
  static const loginFundo = Color(0xFF020A14);
  static const dourado = Color(0xFFEDB449);
  static const douradoTexto = Color(0xFFB07F1C);
  static const fundoApp = Color(0xFFF7F8FA);
  static const texto = Color(0xFF0E1A2B);
  static const cinza = Color(0xFF7A8797);
  static const linha = Color(0xFFEEF0F3);
  static const verde = Color(0xFF2E9E5B);
  static const amarelo = Color(0xFFE0A62B);
  static const cinzaStatus = Color(0xFFA9B3BF);
  static const vermelho = Color(0xFFD64545);
}

ThemeData temaClaro() {
  final base = ThemeData(useMaterial3: true, brightness: Brightness.light);
  return base.copyWith(
    scaffoldBackgroundColor: Cores.fundoApp,
    colorScheme: base.colorScheme.copyWith(primary: Cores.marinho, secondary: Cores.dourado, surface: Colors.white, error: Cores.vermelho),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(bodyColor: Cores.texto, displayColor: Cores.texto),
    splashFactory: NoSplash.splashFactory,
  );
}
```
`lib/config/bancos.dart`
```dart
class Bancos {
  static const blUrl = 'https://wfqcoocfastgsfgegpcm.supabase.co';
  static const blChave = 'sb_publishable_88ukR4t1KNTc73DxbF6-Pw_0CKW16Fe';
  static const teamsUrl = 'https://lhqjfdexfexpmnoqhbyv.supabase.co';
  static const teamsChave = 'sb_publishable_wJLNCeunyVFZz4yUJAaJMQ_x7qPMU_v';
}
```
- [ ] **Step 5:** `flutter test test/core/tema_test.dart` → PASS. Apagar `test/widget_test.dart` gerado.
- [ ] **Step 6: Commit** `git add -A && git commit -m "Base do app: projeto Flutter, tema da marca e logo"`

---

### Task 2: Login só CEO (repositório + sessão)

**Files:**
- Create: `lib/data/auth_repo.dart`, `lib/core/sessao.dart`
- Test: `test/core/sessao_test.dart`

**Interfaces:**
- Produces:
  - `abstract class AuthRepo { Future<void> entrarBl(String email, String senha); Future<Map<String, dynamic>?> lerPerfil(); Future<void> entrarTeams(); Future<void> sair(); bool get temSessaoBl; }`
  - `class AuthRepoSupabase implements AuthRepo { AuthRepoSupabase(SupabaseClient bl, SupabaseClient teams); }`
  - `enum EstadoSessao { carregando, fora, dentro }`
  - `class Sessao extends ChangeNotifier { Sessao(AuthRepo repo); EstadoSessao estado; String? erro; Map<String,dynamic>? perfil; Future<void> iniciar(); Future<void> entrar(String email, String senha); Future<void> sair(); }`
  - Mensagens de `erro`: `'E-mail ou senha incorretos'`, `'Acesso exclusivo para CEO'`, `'Não foi possível entrar no TEAM\'s'`.

- [ ] **Step 1: Teste que falha** — `test/core/sessao_test.dart`
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_bl/core/sessao.dart';
import 'package:mobile_bl/data/auth_repo.dart';

class RepoFalso implements AuthRepo {
  RepoFalso({this.nivel = 'ceo', this.senhaOk = true, this.teamsOk = true});
  final String nivel; final bool senhaOk; final bool teamsOk;
  bool saiu = false; bool logado = false;
  @override bool get temSessaoBl => logado;
  @override Future<void> entrarBl(String e, String s) async { if (!senhaOk) throw const ErroLogin(); logado = true; }
  @override Future<Map<String, dynamic>?> lerPerfil() async => {'nome': 'William Ramos', 'nivel': nivel};
  @override Future<void> entrarTeams() async { if (!teamsOk) throw Exception('x'); }
  @override Future<void> sair() async { saiu = true; logado = false; }
}

void main() {
  test('CEO entra', () async {
    final s = Sessao(RepoFalso());
    await s.entrar('a@b.com', '12345678');
    expect(s.estado, EstadoSessao.dentro);
    expect(s.perfil!['nome'], 'William Ramos');
  });
  test('quem não é CEO é recusado e desconectado', () async {
    final r = RepoFalso(nivel: 'diretor');
    final s = Sessao(r);
    await s.entrar('a@b.com', '12345678');
    expect(s.estado, EstadoSessao.fora);
    expect(s.erro, 'Acesso exclusivo para CEO');
    expect(r.saiu, isTrue);
  });
  test('senha errada', () async {
    final s = Sessao(RepoFalso(senhaOk: false));
    await s.entrar('a@b.com', 'x');
    expect(s.erro, 'E-mail ou senha incorretos');
    expect(s.estado, EstadoSessao.fora);
  });
  test('falha no TEAM\'s desconecta', () async {
    final r = RepoFalso(teamsOk: false);
    final s = Sessao(r);
    await s.entrar('a@b.com', '12345678');
    expect(s.erro, 'Não foi possível entrar no TEAM\'s');
    expect(r.saiu, isTrue);
  });
  test('iniciar com sessão guardada de CEO entra direto', () async {
    final r = RepoFalso()..logado = true;
    final s = Sessao(r);
    await s.iniciar();
    expect(s.estado, EstadoSessao.dentro);
  });
}
```
- [ ] **Step 2:** `flutter test test/core/sessao_test.dart` → FAIL.
- [ ] **Step 3: Implementar** `lib/data/auth_repo.dart`
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class ErroLogin implements Exception { const ErroLogin(); }

abstract class AuthRepo {
  bool get temSessaoBl;
  Future<void> entrarBl(String email, String senha);
  Future<Map<String, dynamic>?> lerPerfil();
  Future<void> entrarTeams();
  Future<void> sair();
}

class AuthRepoSupabase implements AuthRepo {
  AuthRepoSupabase(this.bl, this.teams);
  final SupabaseClient bl;
  final SupabaseClient teams;

  @override
  bool get temSessaoBl => bl.auth.currentSession != null;

  @override
  Future<void> entrarBl(String email, String senha) async {
    try {
      await bl.auth.signInWithPassword(email: email.trim(), password: senha);
    } on AuthException {
      throw const ErroLogin();
    }
  }

  @override
  Future<Map<String, dynamic>?> lerPerfil() async {
    final r = await bl.rpc('meu_perfil_ler');
    return r == null ? null : Map<String, dynamic>.from(r as Map);
  }

  @override
  Future<void> entrarTeams() async {
    final token = bl.auth.currentSession?.accessToken;
    final r = await teams.functions.invoke('teams-entrar', body: {'bl_token': token});
    final d = r.data as Map;
    if (d['ok'] != true) throw Exception('teams');
    await teams.auth.setSession(d['refresh_token'] as String);
  }

  @override
  Future<void> sair() async {
    try { await teams.auth.signOut(); } catch (_) {}
    try { await bl.auth.signOut(); } catch (_) {}
  }
}
```
`lib/core/sessao.dart`
```dart
import 'package:flutter/foundation.dart';
import '../data/auth_repo.dart';

enum EstadoSessao { carregando, fora, dentro }

class Sessao extends ChangeNotifier {
  Sessao(this.repo);
  final AuthRepo repo;
  EstadoSessao estado = EstadoSessao.carregando;
  String? erro;
  Map<String, dynamic>? perfil;

  Future<void> iniciar() async {
    if (repo.temSessaoBl) {
      await _concluir();
    } else {
      estado = EstadoSessao.fora;
      notifyListeners();
    }
  }

  Future<void> entrar(String email, String senha) async {
    erro = null;
    try {
      await repo.entrarBl(email, senha);
    } on ErroLogin {
      erro = 'E-mail ou senha incorretos';
      estado = EstadoSessao.fora;
      notifyListeners();
      return;
    }
    await _concluir();
  }

  Future<void> _concluir() async {
    try {
      final p = await repo.lerPerfil();
      if (p == null || p['nivel'] != 'ceo') {
        await repo.sair();
        erro = 'Acesso exclusivo para CEO';
        estado = EstadoSessao.fora;
        notifyListeners();
        return;
      }
      perfil = p;
      await repo.entrarTeams();
      estado = EstadoSessao.dentro;
    } catch (_) {
      await repo.sair();
      erro ??= 'Não foi possível entrar no TEAM\'s';
      estado = EstadoSessao.fora;
    }
    notifyListeners();
  }

  Future<void> sair() async {
    await repo.sair();
    perfil = null;
    estado = EstadoSessao.fora;
    notifyListeners();
  }
}
```
- [ ] **Step 4:** `flutter test test/core/sessao_test.dart` → PASS (5 testes).
- [ ] **Step 5: Commit** `git commit -am "Login só CEO: sessão nos dois bancos"`

---

### Task 3: Tela de login

**Files:**
- Create: `lib/features/login/tela_login.dart`
- Test: `test/features/login/tela_login_test.dart`

**Interfaces:**
- Consumes: `Sessao` (Task 2), `Cores` (Task 1)
- Produces: `class TelaLogin extends StatefulWidget { const TelaLogin({required Sessao sessao}); }` com chaves `Key('email')`, `Key('senha')`, `Key('entrar')`.

- [ ] **Step 1: Teste que falha**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_bl/core/sessao.dart';
import 'package:mobile_bl/features/login/tela_login.dart';
import '../../core/sessao_test.dart' show RepoFalso;

void main() {
  testWidgets('mostra erro de não CEO', (t) async {
    final s = Sessao(RepoFalso(nivel: 'diretor'));
    await t.pumpWidget(MaterialApp(home: TelaLogin(sessao: s)));
    await t.enterText(find.byKey(const Key('email')), 'a@b.com');
    await t.enterText(find.byKey(const Key('senha')), '12345678');
    await t.tap(find.byKey(const Key('entrar')));
    await t.pumpAndSettle();
    expect(find.text('Acesso exclusivo para CEO'), findsWidgets);
  });
}
```
- [ ] **Step 2:** rodar → FAIL.
- [ ] **Step 3: Implementar** `lib/features/login/tela_login.dart`
```dart
import 'package:flutter/material.dart';
import '../../core/sessao.dart';
import '../../core/tema.dart';

class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key, required this.sessao});
  final Sessao sessao;
  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

class _TelaLoginState extends State<TelaLogin> {
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _enviando = false;

  Future<void> _entrar() async {
    setState(() => _enviando = true);
    await widget.sessao.entrar(_email.text, _senha.text);
    if (mounted) setState(() => _enviando = false);
  }

  InputDecoration _campo(String r) => InputDecoration(
        hintText: r,
        hintStyle: const TextStyle(color: Color(0xFF7F93AA), fontSize: 14),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0x24FFFFFF))),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Cores.dourado)),
      );

  @override
  Widget build(BuildContext context) {
    final erro = widget.sessao.erro;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment(0, -1.2), radius: 1.4,
              colors: [Cores.loginTopo, Cores.loginMeio, Cores.loginFundo], stops: [0, .5, 1]),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Column(children: [
                  Image.asset('assets/logo.png', width: 124),
                  const SizedBox(height: 22),
                  const Text('Blanco & Lisboa', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  const Text('ACESSO EXCLUSIVO CEO', style: TextStyle(color: Color(0xFF8FA3BA), fontSize: 10, letterSpacing: 2.4)),
                  const SizedBox(height: 28),
                  TextField(key: const Key('email'), controller: _email, keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      style: const TextStyle(color: Colors.white, fontSize: 14), decoration: _campo('E-mail')),
                  const SizedBox(height: 8),
                  TextField(key: const Key('senha'), controller: _senha, obscureText: true,
                      autofillHints: const [AutofillHints.password], onSubmitted: (_) => _entrar(),
                      style: const TextStyle(color: Colors.white, fontSize: 14), decoration: _campo('Senha')),
                  if (erro != null) ...[
                    const SizedBox(height: 14),
                    Text(erro, style: const TextStyle(color: Color(0xFFF08A8A), fontSize: 12)),
                  ],
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity, height: 44,
                    child: TextButton(
                      key: const Key('entrar'),
                      onPressed: _enviando ? null : _entrar,
                      style: TextButton.styleFrom(backgroundColor: const Color(0xFFF2F4F7), foregroundColor: Cores.marinho,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: _enviando
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Entrar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```
(Face ID fica para a versão nativa; na versão web o preenchimento automático de senha do iPhone já oferece Face ID.)
- [ ] **Step 4:** rodar → PASS.
- [ ] **Step 5: Commit** `git commit -am "Tela de login"`

---

### Task 4: Perfil (repositório + foto)

**Files:**
- Create: `lib/data/perfil_repo.dart`, `lib/data/foto.dart`
- Test: `test/data/foto_test.dart`

**Interfaces:**
- Produces:
  - `abstract class PerfilRepo { Future<Map<String,dynamic>> ler(); Future<String> lerStatus(); Future<void> salvar({required String email, required String whatsapp, String? fotoDataUrl}); Future<void> definirStatus(String status); Future<String?> trocarSenha(String nova); }` (`trocarSenha` devolve `null` se deu certo ou a mensagem de erro)
  - `class PerfilRepoSupabase implements PerfilRepo { PerfilRepoSupabase(SupabaseClient bl); }`
  - `String reduzirParaDataUrl(Uint8List bytes)` — JPEG ≤256 px.

- [ ] **Step 1: Teste que falha** `test/data/foto_test.dart`
```dart
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
```
- [ ] **Step 2:** rodar → FAIL.
- [ ] **Step 3: Implementar** `lib/data/foto.dart`
```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

String reduzirParaDataUrl(Uint8List bytes) {
  final o = img.decodeImage(bytes)!;
  final escala = [256 / o.width, 256 / o.height, 1.0].reduce((a, b) => a < b ? a : b);
  final r = img.copyResize(o, width: (o.width * escala).round(), height: (o.height * escala).round());
  return 'data:image/jpeg;base64,${base64Encode(img.encodeJpg(r, quality: 82))}';
}
```
`lib/data/perfil_repo.dart`
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/bancos.dart';

abstract class PerfilRepo {
  Future<Map<String, dynamic>> ler();
  Future<String> lerStatus();
  Future<void> salvar({required String email, required String whatsapp, String? fotoDataUrl});
  Future<void> definirStatus(String status);
  Future<String?> trocarSenha(String nova);
}

class PerfilRepoSupabase implements PerfilRepo {
  PerfilRepoSupabase(this.bl);
  final SupabaseClient bl;

  @override
  Future<Map<String, dynamic>> ler() async => Map<String, dynamic>.from(await bl.rpc('meu_perfil_ler') as Map);

  @override
  Future<String> lerStatus() async {
    try {
      final r = await bl.rpc('presenca_minha_ler') as Map?;
      return ((r?['presenca'] as Map?)?['status'] as String?) ?? 'online';
    } catch (_) {
      return 'online';
    }
  }

  @override
  Future<void> salvar({required String email, required String whatsapp, String? fotoDataUrl}) async {
    final p = <String, dynamic>{'p_email': email, 'p_whatsapp': whatsapp};
    if (fotoDataUrl != null) p['p_foto_url'] = fotoDataUrl;
    await bl.rpc('meu_perfil_salvar', params: p);
  }

  @override
  Future<void> definirStatus(String status) => bl.rpc('presenca_minha_definir', params: {'p_status': status});

  @override
  Future<String?> trocarSenha(String nova) async {
    if (nova.length < 8) return 'A senha precisa de 8 ou mais caracteres';
    final token = bl.auth.currentSession?.accessToken;
    final r = await bl.functions.invoke('ceo-trocar-senha', body: {'access_token': token, 'nova_senha': nova},
        headers: {'apikey': Bancos.blChave});
    final d = r.data as Map?;
    return d?['ok'] == true ? null : (d?['erro']?.toString() ?? 'Não foi possível trocar a senha');
  }
}
```
- [ ] **Step 4:** rodar → PASS.
- [ ] **Step 5: Commit** `git commit -am "Perfil: funções do banco iguais ao painel e foto reduzida"`

---

### Task 5: Início e folha Meu perfil

**Files:**
- Create: `lib/features/inicio/tela_inicio.dart`, `lib/features/perfil/folha_perfil.dart`
- Test: `test/features/perfil/folha_perfil_test.dart`

**Interfaces:**
- Consumes: `Sessao`, `PerfilRepo`, `reduzirParaDataUrl`, `Cores`
- Produces: `class TelaInicio extends StatelessWidget { const TelaInicio({required Sessao sessao, required PerfilRepo perfil}); }`, `Future<void> abrirPerfil(BuildContext, {required Sessao sessao, required PerfilRepo repo})`, `Widget avatar(Map<String,dynamic>? p, double tamanho)`.

- [ ] **Step 1: Teste que falha** `test/features/perfil/folha_perfil_test.dart`
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_bl/core/sessao.dart';
import 'package:mobile_bl/data/perfil_repo.dart';
import 'package:mobile_bl/features/perfil/folha_perfil.dart';
import '../../core/sessao_test.dart' show RepoFalso;

class PerfilFalso implements PerfilRepo {
  String status = 'online'; Map<String, dynamic>? salvo;
  @override Future<Map<String, dynamic>> ler() async => {'nome': 'William Ramos', 'nivel': 'ceo', 'email': 'w@bl.com', 'whatsapp': '11999990000'};
  @override Future<String> lerStatus() async => status;
  @override Future<void> salvar({required String email, required String whatsapp, String? fotoDataUrl}) async { salvo = {'email': email, 'whatsapp': whatsapp}; }
  @override Future<void> definirStatus(String s) async => status = s;
  @override Future<String?> trocarSenha(String n) async => null;
}

void main() {
  testWidgets('mostra dados, troca status e salva', (t) async {
    final repo = PerfilFalso();
    final s = Sessao(RepoFalso());
    await t.pumpWidget(MaterialApp(home: Builder(builder: (c) => TextButton(
        onPressed: () => abrirPerfil(c, sessao: s, repo: repo), child: const Text('abrir')))));
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
```
- [ ] **Step 2:** rodar → FAIL.
- [ ] **Step 3: Implementar** `lib/features/perfil/folha_perfil.dart`
```dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/sessao.dart';
import '../../core/tema.dart';
import '../../data/foto.dart';
import '../../data/perfil_repo.dart';

const _status = [['online', 'Online'], ['reuniao', 'Reunião'], ['ausente', 'Ausente'], ['nao_perturbe', 'Não perturbe']];

Widget avatar(Map<String, dynamic>? p, double tam) {
  final foto = p?['foto_url'] as String?;
  final ini = ((p?['nome'] as String?) ?? 'BL').trim().split(RegExp(r'\s+')).take(2).map((e) => e[0]).join().toUpperCase();
  return Container(
    width: tam, height: tam,
    decoration: BoxDecoration(color: Cores.marinho, shape: BoxShape.circle,
        image: foto != null && foto.startsWith('data:') ? DecorationImage(image: MemoryImage(UriData.parse(foto).contentAsBytes()), fit: BoxFit.cover) : null),
    alignment: Alignment.center,
    child: foto == null ? Text(ini, style: TextStyle(color: Cores.dourado, fontSize: tam * .32, fontWeight: FontWeight.w500)) : null,
  );
}

Future<void> abrirPerfil(BuildContext context, {required Sessao sessao, required PerfilRepo repo}) {
  return showModalBottomSheet(
    context: context, isScrollControlled: true, backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
    builder: (_) => _FolhaPerfil(sessao: sessao, repo: repo),
  );
}

class _FolhaPerfil extends StatefulWidget {
  const _FolhaPerfil({required this.sessao, required this.repo});
  final Sessao sessao; final PerfilRepo repo;
  @override State<_FolhaPerfil> createState() => _FolhaPerfilState();
}

class _FolhaPerfilState extends State<_FolhaPerfil> {
  Map<String, dynamic>? p; String status = 'online'; String? novaFoto; String? msg;
  final email = TextEditingController(); final whats = TextEditingController(); final senha = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.wait([widget.repo.ler(), widget.repo.lerStatus()]).then((r) {
      if (!mounted) return;
      setState(() {
        p = r[0] as Map<String, dynamic>; status = r[1] as String;
        email.text = (p!['email'] ?? '') as String; whats.text = (p!['whatsapp'] ?? '') as String;
      });
    });
  }

  Future<void> _foto() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (x == null) return;
    final Uint8List b = await x.readAsBytes();
    setState(() => novaFoto = reduzirParaDataUrl(b));
  }

  Future<void> _status(String s) async {
    try { await widget.repo.definirStatus(s); setState(() => status = s); }
    catch (_) { setState(() => msg = 'Status não salvou'); }
  }

  Future<void> _salvar() async {
    try {
      await widget.repo.salvar(email: email.text, whatsapp: whats.text, fotoDataUrl: novaFoto);
      if (mounted) Navigator.pop(context);
    } catch (_) { setState(() => msg = 'Não salvou'); }
  }

  Future<void> _senha() async {
    final e = await widget.repo.trocarSenha(senha.text);
    setState(() { msg = e ?? 'Senha trocada'; senha.clear(); });
  }

  Widget _linha(String k, Widget v) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Cores.linha))),
        child: Row(children: [SizedBox(width: 80, child: Text(k, style: const TextStyle(color: Cores.cinza, fontSize: 12))), Expanded(child: v)]),
      );

  Widget _fixo(String v) => Padding(padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(v, textAlign: TextAlign.right, style: const TextStyle(color: Cores.cinzaStatus, fontSize: 12)));

  Widget _edit(TextEditingController c, {bool oculto = false, String dica = ''}) => TextField(
      controller: c, obscureText: oculto, textAlign: TextAlign.right,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      decoration: InputDecoration(border: InputBorder.none, isDense: true, hintText: dica));

  @override
  Widget build(BuildContext context) {
    final vis = p == null ? null : {...p!, if (novaFoto != null) 'foto_url': novaFoto};
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 10, 18, 18 + MediaQuery.of(context).viewInsets.bottom),
      child: p == null
          ? const SizedBox(height: 240, child: Center(child: CircularProgressIndicator(strokeWidth: 2)))
          : SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 36, height: 4, decoration: BoxDecoration(color: const Color(0xFFD9DEE5), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              Row(children: [
                const Text('Meu perfil', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton(onPressed: _salvar, child: const Text('Salvar', style: TextStyle(color: Cores.douradoTexto, fontWeight: FontWeight.w500))),
              ]),
              const SizedBox(height: 8),
              avatar(vis, 64),
              TextButton(onPressed: _foto, child: const Text('Trocar foto', style: TextStyle(color: Cores.douradoTexto, fontSize: 12))),
              Container(
                decoration: BoxDecoration(color: Cores.fundoApp, borderRadius: BorderRadius.circular(12)),
                child: Column(children: [
                  _linha('Nome', _fixo((p!['nome'] ?? '') as String)),
                  _linha('Nível', _fixo(((p!['nivel'] ?? '') as String).toUpperCase())),
                  _linha('E-mail', _edit(email)),
                  _linha('WhatsApp', _edit(whats)),
                ]),
              ),
              const SizedBox(height: 14),
              const Align(alignment: Alignment.centerLeft, child: Text('STATUS', style: TextStyle(fontSize: 10, letterSpacing: 1.4, color: Color(0xFF8B97A6)))),
              const SizedBox(height: 7),
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(color: const Color(0xFFEEF1F4), borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  for (final s in _status)
                    Expanded(child: GestureDetector(
                      onTap: () => _status(s[0]),
                      child: Container(
                        height: 30, alignment: Alignment.center,
                        decoration: BoxDecoration(color: status == s[0] ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(8),
                            boxShadow: status == s[0] ? const [BoxShadow(color: Color(0x1F0E1A2B), blurRadius: 3, offset: Offset(0, 1))] : null),
                        child: FittedBox(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(s[1], style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: status == s[0] ? Cores.texto : const Color(0xFF5C6878))))),
                      ),
                    )),
                ]),
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(color: Cores.fundoApp, borderRadius: BorderRadius.circular(12)),
                child: _linha('Nova senha', Row(children: [
                  Expanded(child: _edit(senha, oculto: true, dica: 'mín. 8')),
                  TextButton(onPressed: _senha, child: const Text('Trocar', style: TextStyle(fontSize: 12, color: Cores.douradoTexto))),
                ])),
              ),
              if (msg != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(msg!, style: const TextStyle(fontSize: 12, color: Cores.cinza))),
              TextButton(
                onPressed: () { Navigator.pop(context); widget.sessao.sair(); },
                child: const Text('Sair', style: TextStyle(color: Cores.vermelho, fontWeight: FontWeight.w500)),
              ),
            ])),
    );
  }
}
```
Adicionar o pacote: `flutter pub add image_picker`.
`lib/features/inicio/tela_inicio.dart`
```dart
import 'package:flutter/material.dart';
import '../../core/sessao.dart';
import '../../core/tema.dart';
import '../../data/perfil_repo.dart';
import '../perfil/folha_perfil.dart';

class TelaInicio extends StatelessWidget {
  const TelaInicio({super.key, required this.sessao, required this.perfil});
  final Sessao sessao; final PerfilRepo perfil;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Text('Módulos', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -.2)),
            const Spacer(),
            GestureDetector(key: const Key('avatar'), onTap: () => abrirPerfil(context, sessao: sessao, repo: perfil), child: avatar(sessao.perfil, 32)),
          ]),
          const SizedBox(height: 18),
          Container(
            key: const Key('card-teams'),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Cores.linha),
                boxShadow: const [BoxShadow(color: Color(0x140E1A2B), blurRadius: 24, offset: Offset(0, 8), spreadRadius: -12)]),
            child: Row(children: [
              Container(width: 34, height: 34, decoration: BoxDecoration(color: Cores.marinho, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.chat_bubble_outline_rounded, color: Cores.dourado, size: 17)),
              const SizedBox(width: 11),
              const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('TEAM\'s', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                SizedBox(height: 1),
                Text('Conversas e chamadas', style: TextStyle(fontSize: 11, color: Cores.cinza)),
              ]),
            ]),
          ),
        ]),
      )),
    );
  }
}
```
(O contador de não lidas e a última mensagem no card entram na Etapa 2, junto com as conversas.)
- [ ] **Step 4:** rodar → PASS.
- [ ] **Step 5: Commit** `git commit -am "Início com card TEAM's e folha Meu perfil"`

---

### Task 6: Ligar tudo, versão web instalável e prova real

**Files:**
- Create/Modify: `lib/main.dart`, `lib/app.dart`, `web/manifest.json`, `web/index.html`, `web/icons/*`
- Test: `test/app_test.dart`

**Interfaces:**
- Consumes: tudo acima.
- Produces: `class AppBl extends StatelessWidget { const AppBl({required Sessao sessao, required PerfilRepo perfil}); }`

- [ ] **Step 1: Teste que falha** `test/app_test.dart`
```dart
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
```
- [ ] **Step 2:** rodar → FAIL.
- [ ] **Step 3: Implementar** `lib/app.dart`
```dart
import 'package:flutter/material.dart';
import 'core/sessao.dart';
import 'core/tema.dart';
import 'data/perfil_repo.dart';
import 'features/inicio/tela_inicio.dart';
import 'features/login/tela_login.dart';

class AppBl extends StatelessWidget {
  const AppBl({super.key, required this.sessao, required this.perfil});
  final Sessao sessao; final PerfilRepo perfil;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BL CEO', debugShowCheckedModeBanner: false, theme: temaClaro(),
      home: ListenableBuilder(
        listenable: sessao,
        builder: (_, __) => switch (sessao.estado) {
          EstadoSessao.carregando => const Scaffold(backgroundColor: Cores.loginFundo),
          EstadoSessao.fora => TelaLogin(sessao: sessao),
          EstadoSessao.dentro => TelaInicio(sessao: sessao, perfil: perfil),
        },
      ),
    );
  }
}
```
`lib/main.dart`
```dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'config/bancos.dart';
import 'core/sessao.dart';
import 'data/auth_repo.dart';
import 'data/perfil_repo.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: Bancos.blUrl, anonKey: Bancos.blChave);
  final bl = Supabase.instance.client;
  final teams = SupabaseClient(Bancos.teamsUrl, Bancos.teamsChave,
      authOptions: const AuthClientOptions(autoRefreshToken: true));
  final sessao = Sessao(AuthRepoSupabase(bl, teams));
  runApp(AppBl(sessao: sessao, perfil: PerfilRepoSupabase(bl)));
  await sessao.iniciar();
}
```
(Ao reabrir, a sessão da BL volta do armazenamento e o `iniciar()` refaz a entrada no TEAM's — mesma regra do Java do Fiscal: quem for desativado perde o acesso.)
`web/manifest.json` — trocar os campos:
```json
{
  "name": "BL CEO", "short_name": "BL CEO", "start_url": ".", "display": "standalone",
  "background_color": "#020A14", "theme_color": "#020A14", "orientation": "portrait",
  "icons": [
    {"src": "icons/Icon-192.png", "sizes": "192x192", "type": "image/png"},
    {"src": "icons/Icon-512.png", "sizes": "512x512", "type": "image/png"},
    {"src": "icons/Icon-maskable-192.png", "sizes": "192x192", "type": "image/png", "purpose": "maskable"},
    {"src": "icons/Icon-maskable-512.png", "sizes": "512x512", "type": "image/png", "purpose": "maskable"}
  ]
}
```
Ícones: gerar a partir do logo sobre fundo `#020A14` (Python/PIL) em 192/512 e `web/favicon.png`; em `web/index.html` trocar `<title>` para `BL CEO`, `apple-mobile-web-app-title` para `BL CEO` e acrescentar `<meta name="theme-color" content="#020A14">`.
- [ ] **Step 4:** `flutter test` → todos PASS.
- [ ] **Step 5: Prova real** — `flutter build web --release` e servir `build/web` localmente (`python -m http.server 8090` dentro de `build/web`); no Chrome:
  1. login com senha errada → "E-mail ou senha incorretos";
  2. login de CEO real (William digita) → início com card; abrir perfil, trocar status → conferir no painel do Java CEO que o status mudou; salvar WhatsApp → conferir no Java.
  3. login de não-CEO (se houver conta de teste) → "Acesso exclusivo para CEO".
  Registrar o resultado real em `docs/prova-etapa1.md`.
- [ ] **Step 6: Commit** `git add -A && git commit -m "Etapa 1 ligada: login CEO, início, perfil e versão web instalável"`

---

## Próximas etapas (planos separados, depois desta)
2. Conversas + conversa (texto, tempo real, lidas, contador no card).
3. Anexos, fotos, câmera, áudio, menção, cliente, responder/editar/apagar/copiar, criar pedido.
4. Avisos, Pedidos, Reuniões, Nova conversa/grupo, Detalhes.
5. Chamadas (LiveKit).
6. Publicar em endereço HTTPS.
