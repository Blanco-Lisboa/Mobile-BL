# O que precisa para gerar o instalador (07/10/2026)

Antes do instalador: programar o app (hoje só existem os desenhos aprovados).

## Android
- Falta instalar o kit de ferramentas do Android (Android SDK) neste computador — `flutter doctor`: "Unable to locate Android SDK". Grátis; eu instalo.
- Distribuir: arquivo .apk direto para os CEOs (sem custo) ou Google Play (conta de US$ 25, paga uma vez).

## iPhone
- Conta Apple Developer em nome da empresa: US$ 99 por ano. Sem ela o iPhone não instala.
- Um Mac para gerar o app, ou um serviço na nuvem que gera o app de iPhone (ex.: Codemagic).
- Entrega aos CEOs pelo TestFlight, sem precisar estar na App Store.

## Aviso no celular quando chega mensagem
- Conta grátis no Firebase (Google) + chave de notificação da conta Apple (APNs).

## iPhone sem pagar a licença (pesquisado 07/10/2026)
1. **App de verdade, só no celular do William (teste):** gerar o app sem assinatura num Mac na nuvem (ex.: plano grátis do Codemagic, `flutter build ios --no-codesign` → .ipa) e instalar pelo **Sideloadly** no Windows com o Apple ID comum dele (grátis). Limites: o app vence a cada 7 dias (o Sideloadly/AltStore renova sozinho com o iPhone ligado ao PC); conta grátis não tem aviso no celular (push); máximo de 3 apps assim. Fonte: https://www.xda-developers.com/how-to-sideload-apps-on-iphone/ , https://github.com/qnblackcat/uYouPlus/wiki/Sideloadly-(macOS-&-Windows)
2. **Para todos os CEOs, de graça e sem vencer:** versão web instalável (o mesmo Flutter gera para web). Abre no Safari → "Adicionar à Tela de Início" → vira ícone igual app. Aviso no celular funciona desde o iOS 16.4 depois de instalado. Precisa de endereço com HTTPS. Limite: o aviso no iPhone ainda é menos estável que no Android. Fonte: https://www.magicbell.com/blog/pwa-ios-limitations-safari-support-complete-guide , https://pushpad.xyz/blog/ios-special-requirements-for-web-push-notifications
