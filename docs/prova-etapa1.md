# Prova — Etapa 1 (07/10/2026)

- `flutter analyze`: No issues found.
- `flutter test`: 10 testes, todos passaram (tema, sessão só CEO x5, login não-CEO, foto 256 px, perfil status/salvar, app login→início).
- `flutter build web --release`: OK; servido em http://localhost:8090 — tela de login renderizada (letra Inter, logo estático, centralizado).
- Banco real:
  - BL login com senha errada → 400 `invalid_credentials` (o app mostra "E-mail ou senha incorretos").
  - TEAM's `teams-entrar` com token falso → 403 "sem acesso ao TEAM's".
- Falta (precisa do William): entrar com o login de CEO real, abrir o perfil, trocar status e WhatsApp e conferir no Java CEO.
