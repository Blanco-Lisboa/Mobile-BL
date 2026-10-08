# Notificações do WhatsApp (iPhone e Android) — comportamento completo para copiar no app BL CEO

Pesquisa feita em 07/10/2026. Objetivo: descrever como o WhatsApp avisa o usuário (mensagens, grupos,
canais, chamadas, reações) para que o chat interno do BL CEO (conversas diretas, grupos, canais de
departamento, chamadas de voz/vídeo, avisos, pedidos e reuniões) copie o mesmo comportamento.

## Como ler este documento

- Cada regra está em uma linha: **QUANDO** (situação) **ENTÃO** (o que acontece).
- Ao fim de cada regra vem o código da fonte entre colchetes, por exemplo `[W1]`. A lista completa de
  fontes está na seção 0 e repetida, resumida, no fim de cada seção.
- **Grau de certeza**:
  - sem marca = está escrito em fonte oficial (Central de Ajuda do WhatsApp, blog do WhatsApp,
    documentação da Apple, do Android, do WebKit ou do MDN);
  - `(imprensa)` = vem de site de tecnologia que noticiou a função, não do próprio WhatsApp;
  - `NÃO CONFIRMADO` = é o comportamento que se observa no uso, mas não achei fonte confiável que
    confirme. Não tratar como fato; validar num aparelho real antes de copiar.
- Os textos da Central de Ajuda foram lidos na versão em inglês (EUA) em 07/10/2026; as frases entre
  aspas são citação direta, as demais são tradução.

---

## 0. Fontes

### WhatsApp — Central de Ajuda (faq.whatsapp.com), lidas em 07/10/2026
- **[W1]** Como gerenciar suas notificações — https://faq.whatsapp.com/797069521522888 (versões Android, iPhone e Web)
- **[W2]** Como silenciar ou reativar notificações de conversas individuais ou em grupo — https://faq.whatsapp.com/694350718331007
- **[W3]** Não consigo ver ou ouvir notificações — https://faq.whatsapp.com/655426345948308 (Android e iPhone)
- **[W4]** Como gerenciar os tons de conversa — https://faq.whatsapp.com/1790056918005220
- **[W5]** Como mudar o toque do WhatsApp — https://faq.whatsapp.com/452202886800558
- **[W6]** Como reagir a mensagens — https://faq.whatsapp.com/424198503229937
- **[W7]** Como editar mensagens — https://faq.whatsapp.com/6614640168569481
- **[W8]** Como apagar mensagens — https://faq.whatsapp.com/1370476507114859
- **[W9]** Como fazer uma chamada de voz 1:1 — https://faq.whatsapp.com/1153602608602452
- **[W10]** Como fazer uma chamada de vídeo 1:1 — https://faq.whatsapp.com/1862285217468140
- **[W11]** Como fazer uma chamada de voz em grupo — https://faq.whatsapp.com/829612741557179
- **[W12]** Como usar a chamada em espera — https://faq.whatsapp.com/692484435227181
- **[W13]** Sobre o histórico de chamadas — https://faq.whatsapp.com/743219147158705
- **[W14]** Como gerenciar notificações de comunidades — https://faq.whatsapp.com/3554678331374679
- **[W15]** Como gerenciar notificações de canais — https://faq.whatsapp.com/6074154625973804
- **[W16]** Problemas com o contador de notificações (badge) — https://faq.whatsapp.com/651246566555762
- **[W17]** Sobre aparelhos conectados — https://faq.whatsapp.com/378279804439436
- **[W18]** Sobre notificações com links — https://faq.whatsapp.com/1201685718230080

### WhatsApp — Blog oficial
- **[B1]** "Your Group Chats Upgraded: Introducing Better Polls, @all and More" — https://blog.whatsapp.com/your-group-chats-upgraded-introducing-better-polls-all-and-more
- **[B2]** "New Feature Roundup: Updates to group chats, events, calls, channels and more" — https://blog.whatsapp.com/new-feature-roundup-updates-to-group-chats-events-calls-channels-and-more

### Apple (documentação oficial)
- **[A1]** Implementing communication notifications — https://developer.apple.com/documentation/usernotifications/implementing-communication-notifications
- **[A2]** UNMutableNotificationContent.threadIdentifier — https://developer.apple.com/documentation/usernotifications/unmutablenotificationcontent/threadidentifier
- **[A3]** PKPushRegistryDelegate pushRegistry(_:didReceiveIncomingPushWith:for:completion:) — https://developer.apple.com/documentation/pushkit/pkpushregistrydelegate/pushregistry(_:didreceiveincomingpushwith:for:completion:)
- **[A4]** Responding to VoIP notifications from PushKit — https://developer.apple.com/documentation/pushkit/responding-to-voip-notifications-from-pushkit
- **[A5]** CallKit — https://developer.apple.com/documentation/callkit
- **[A6]** removeDeliveredNotifications(withIdentifiers:) — https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/removedeliverednotifications(withidentifiers:)
- **[A7]** setBadgeCount(_:withCompletionHandler:) — https://developer.apple.com/documentation/usernotifications/unusernotificationcenter/setbadgecount(_:withcompletionhandler:)
- **[A8]** UNTextInputNotificationAction — https://developer.apple.com/documentation/usernotifications/untextinputnotificationaction
- **[A9]** Sending notification requests to APNs — https://developer.apple.com/documentation/usernotifications/sending-notification-requests-to-apns
- **[A10]** Suporte Apple: Altere os ajustes de notificação no iPhone — https://support.apple.com/guide/iphone/change-notification-settings-iph7c3d96bab/ios
- **[A11]** Suporte Apple: Permita ou silencie as notificações em um Foco — https://support.apple.com/guide/iphone/allow-or-silence-notifications-for-a-focus-iph21d43af5b/ios
- **[A12]** Suporte Apple: Visualize e responda notificações no iPhone — https://support.apple.com/guide/iphone/view-and-respond-to-notifications-iph6534c01bc/ios

### Android (documentação oficial)
- **[D1]** Conversations — https://developer.android.com/develop/ui/views/notifications/conversations
- **[D2]** Create a group of notifications — https://developer.android.com/develop/ui/views/notifications/group
- **[D3]** Create a notification (respostas diretas, atualizar, remover, tela bloqueada) — https://developer.android.com/develop/ui/views/notifications/build-notification
- **[D4]** Create a call style notification — https://developer.android.com/develop/ui/views/notifications/call-style
- **[D5]** Display time-sensitive notifications (tela cheia) — https://developer.android.com/develop/ui/views/notifications/time-sensitive
- **[D6]** Android 14 — mudanças de comportamento (tela cheia só para chamada e alarme) — https://developer.android.com/about/versions/14/behavior-changes-14
- **[D7]** Modify a notification badge — https://developer.android.com/develop/ui/views/notifications/badges
- **[D8]** Create and manage notification channels — https://developer.android.com/develop/ui/views/notifications/channels

### Web (WebKit / MDN)
- **[K1]** WebKit: Web Push for Web Apps on iOS and iPadOS — https://webkit.org/blog/13878/web-push-for-web-apps-on-ios-and-ipados/
- **[K2]** WebKit: WebKit Features in Safari 16.4 — https://webkit.org/blog/13966/webkit-features-in-safari-16-4/
- **[K3]** WebKit: Meet Declarative Web Push — https://webkit.org/blog/16535/meet-declarative-web-push/
- **[K4]** WebKit Bug 258922 (tag de notificação não substitui no iOS) — https://bugs.webkit.org/show_bug.cgi?id=258922
- **[K5]** MDN Browser Compat Data, versão 8.1.4 (01/10/2026), pacote `@mdn/browser-compat-data` — https://github.com/mdn/browser-compat-data (páginas MDN: https://developer.mozilla.org/docs/Web/API/ServiceWorkerRegistration/showNotification e https://developer.mozilla.org/docs/Web/API/Navigator/setAppBadge)
- **[K6]** Apple Developer Forums: "Does Web Push Notification Actions work on iOS 16.4?" — https://developer.apple.com/forums/thread/726793

### Imprensa e relatos técnicos (peso menor)
- **[T1]** GSMArena, 13/11/2024: "WhatsApp clarifies how muting group chats works" — https://www.gsmarena.com/whatsapp_clarifies_how_muting_group_chats_works-news-65308.php
- **[T2]** TechTimes, 05/08/2026: "@all mention bypasses group mute" — https://www.techtimes.com/articles/323151/20260805/whatsapp-all-mention-bypasses-group-mute-sweeping-coordination-upgrade.htm
- **[T3]** MacRumors, 06/01/2022: foto de perfil nas notificações do iOS — https://www.macrumors.com/2022/01/06/whatsapp-profile-pictures-ios-notifications/
- **[T4]** iPhone in Canada, 29/10/2019: conversas silenciadas deixam de somar no contador (iOS 2.19.110) — https://www.iphoneincanada.ca/2019/10/29/fix-whatsapp-muted-chats-badge/
- **[T5]** Android Police, 21/02/2025: opção "Show count until viewed" — https://www.androidpolice.com/whatsapps-home-screen-notifications-easier-to-manage/
- **[T6]** MacRumors (via machash), 19/02/2025: opção "Clear Badge" no iOS — https://machash.com/macrumors/385412/whatsapp-testing-clear-badge-feature-unread-messages/
- **[T7]** GitHub ldicarlo/whatsapp-notification-problem: canais `individual_chat_defaults_XX` — https://github.com/ldicarlo/whatsapp-notification-problem
- **[T8]** Android Authority / WABetaInfo, 2018: botão "Marcar como lida" na notificação do Android — https://www.androidauthority.com/whatsapp-mark-as-read-885558/ (página bloqueou leitura direta; conteúdo conferido só pelo resumo de busca)
- **[T9]** WABetaInfo / Digital Trends, 2022: notificações de reação ligadas por padrão — https://wabetainfo.com/whatsapp-is-rolling-out-message-reactions-to-everyone/ e https://digitaltrends.com/mobile/whatsapp-ios-beta-unveils-notifications-for-message-reactions
- **[T10]** ITGeared: "How Long Does WhatsApp Ring For?" (não cita fonte) — https://www.itgeared.com/how-long-does-whatsapp-ring-for/
- **[T11]** Apple Developer Forums 726015: CallKit encerra o toque após 60 s — https://developer.apple.com/forums/thread/726015
- **[T12]** MacRumors 2019 / iMore: conversas silenciadas sem badge — https://www.imore.com/whatsapp-will-no-longer-show-badges-muted-chats-finally

---

## 1. Mensagem nova: o que aparece em cada situação

### 1.1 Estados do app

- QUANDO chega mensagem com o app **fechado ou em segundo plano** ENTÃO aparece a notificação do sistema (push), na tela bloqueada ou como banner. "Push notifications are the alerts you get when WhatsApp is closed or running in the background." [W3]
- QUANDO chega mensagem com o app **aberto em outra conversa** ENTÃO aparece a notificação interna (in-app): um banner dentro do app, além de subir o contador ao lado da conversa e o contador no ícone. "In-app notifications include the banner that appears when a message arrives in another chat, the unread count next to a chat, and the badge on the WhatsApp icon." [W3]
- QUANDO o usuário está no iPhone com o app aberto ENTÃO o estilo do aviso interno é escolhido em Configurações > Notificações > Notificações no app: Estilo do alerta **Nenhum / Banners / Alertas**, com **Sons** e **Vibrar** ligáveis separadamente. [W1 iPhone]
- QUANDO chega mensagem com o app **aberto na mesma conversa** ENTÃO toca só o "tom de conversa" (som curto de envio/recebimento), sem banner. "Conversation tones are the sounds played when you send and receive a message." [W4] — que não aparece banner nesse caso é `NÃO CONFIRMADO` por fonte escrita (é o comportamento observado).
- QUANDO o celular está no modo silencioso ou só vibrar ENTÃO o tom de conversa não toca; o volume dele é o volume de notificação do aparelho. [W4]
- QUANDO o usuário desliga "Tons de conversa" (Android) ou escolhe som "Nenhum" (iPhone) ENTÃO os sons de envio e recebimento dentro do app param. [W4]

### 1.2 Conteúdo do banner

- QUANDO a mensagem é de conversa individual ENTÃO a notificação mostra o nome do contato e a prévia do texto (se a prévia estiver ligada). [W1, W3]
- QUANDO a mensagem é de grupo ENTÃO a notificação mostra o grupo e quem mandou. No iPhone, a notificação de comunicação mostra "avatares e nomes de grupo em destaque" ("prominent avatars and group names"). [A1] O formato exato do título no Android ("Fulano @ Grupo") é `NÃO CONFIRMADO`.
- QUANDO chega mensagem no iPhone com iOS 15 ou mais novo ENTÃO a foto de perfil do remetente aparece no banner do topo e na Central de Notificações, em conversas e grupos (WhatsApp adotou a API do iOS 15 em jan/2022; no Android isso já existia antes). [T3 (imprensa)] Mecanismo: o app cria um `INSendMessageIntent` com o remetente (`INPerson` com imagem), um `conversationIdentifier` fixo por conversa e, em grupo, o nome do grupo (`speakableGroupName`) com imagem própria; a foto do remetente vira o avatar da notificação. [A1]
- QUANDO a mensagem é mídia ENTÃO a prévia usa um ícone + texto (ex.: "📷 Foto", "🎤 Mensagem de voz (0:12)", "📄 Documento", figurinha, localização). `NÃO CONFIRMADO` — nenhuma fonte oficial lista esses textos; validar em aparelho real e copiar exatamente o que aparecer.
- QUANDO a mensagem tem link suspeito e a prévia está ligada ENTÃO o link não pode ser aberto pela prévia da notificação; só depois de abrir a mensagem no app. Isso é automático e não pode ser desligado. [W18] No iPhone, "previews for messages with suspicious links might still be hidden" mesmo com a prévia ligada. [W1 iPhone]
- QUANDO a conversa está **trancada** (chat com senha/biometria) ENTÃO a notificação mostra só "WhatsApp", sem nome e sem conteúdo — vale para mensagens e chamadas, na tela bloqueada, na central e nos banners. [W1]

### 1.3 Prévia desligada

- QUANDO o usuário desliga "Mostrar prévia" no WhatsApp do iPhone ENTÃO a notificação deixa de mostrar o texto da mensagem. [W1 iPhone]
- QUANDO, no iPhone, o ajuste do sistema "Mostrar Pré-visualizações" está em **Ao Desbloquear** ENTÃO o conteúdo só aparece com o aparelho desbloqueado; em **Sempre** aparece também na tela bloqueada. [W3 iPhone, A10]
- QUANDO, no Android, o ajuste do sistema "Notificações na tela de bloqueio" está em "Mostrar conversas, padrão e silenciosas" / "Ocultar conversas e notificações silenciosas" / "Não mostrar notificações" ENTÃO o WhatsApp segue essa escolha. [W1 Android] Mecanismo do Android: `VISIBILITY_PRIVATE` mostra só ícone e título na tela bloqueada e permite uma "versão pública" alternativa (`setPublicVersion`). [D3]
- QUANDO as notificações do WhatsApp estão desligadas no ajuste do aparelho ENTÃO nenhuma configuração dentro do WhatsApp tem efeito ("Your device settings override WhatsApp settings"). [W1, W3]

**Fontes da seção 1:** W1, W3, W4, W18, A1, A10, D3, T3.

---

## 2. Agrupamento

- QUANDO há várias notificações no iPhone ENTÃO o sistema agrupa por app e, se o app informar, por conversa ("agrupadas por recursos organizadores dentro do app, como por tema ou conversa"), em pilha com a mais recente no topo; tocar expande. [A12]
- QUANDO o app quer agrupar por conversa no iPhone ENTÃO usa o mesmo `threadIdentifier` em todas as notificações daquela conversa ("assign the same thread identifier string to all notifications that you want to group together visually"). [A2] Para notificação de comunicação, usa também o mesmo `conversationIdentifier` em todas as mensagens da conversa — "especially important for group conversations where the group name and membership can change". [A1]
- QUANDO o usuário do iPhone quer ver só a contagem na tela bloqueada ENTÃO escolhe em Ajustes > Notificações: Contagem, Conjunto ou Lista. [A10]
- QUANDO chegam várias mensagens no Android ENTÃO o WhatsApp usa o estilo de conversa (`MessagingStyle`), com as últimas mensagens em linhas dentro da mesma notificação. Que o WhatsApp usa `MessagingStyle` e junta várias mensagens numa notificação é relato técnico (ver nota abaixo); regra oficial do Android: notificação de conversa = `MessagingStyle` + atalho de longa duração (`setShortcutId`) [D1], e o histórico é montado com `MessagingStyle.addMessage()` [D1].
  - Nota: o uso de `MessagingStyle` agrupando várias mensagens pelo WhatsApp é citado por desenvolvedores do projeto WhatsDeleted (github.com/jimale/WhatsDeleted, issue #9 e PR #8) — relato técnico, não oficial.
- QUANDO chega mensagem nova numa conversa que já tem notificação no Android ENTÃO o certo é **atualizar a mesma notificação** (mesmo ID) em vez de criar outra: "call NotificationManagerCompat.notify() again, passing it the same ID". Se a anterior foi descartada, nasce uma nova. [D3]
- QUANDO se atualiza a notificação ENTÃO pode-se usar `setOnlyAlertOnce()` para tocar som/vibrar só na primeira vez. [D3] Atenção: o Android pode descartar atualizações se forem muitas em menos de um segundo. [D3]
- QUANDO há notificações de várias conversas no Android ENTÃO elas formam um grupo (`setGroup`) com uma notificação-resumo (`setGroupSummary(true)`); no Android 7+ o sistema mostra o grupo aninhado com trechos de cada notificação. [D2] Se o app mandar 4 ou mais notificações sem grupo, o próprio sistema agrupa. [D2] Quem faz barulho no grupo é definido por `setGroupAlertBehavior` (`GROUP_ALERT_SUMMARY`, `GROUP_ALERT_ALL`, `GROUP_ALERT_CHILDREN`). [D2]
- QUANDO há resumo de várias conversas no Android ENTÃO o texto é "X mensagens de Y conversas". `NÃO CONFIRMADO` — o texto exato não foi achado em fonte.
- QUANDO a notificação é de conversa no Android 11+ ENTÃO ela vai para a seção "Conversas" no topo da aba de notificações, pode virar balão (bubble) e ser marcada como prioritária pelo usuário. Sem atalho associado, perde essas funções. [D1] Avatares devem ter boa qualidade (104dp); sem eles, o sistema mostra iniciais. [D1]

**Fontes da seção 2:** A1, A2, A10, A12, D1, D2, D3.

---

## 3. Quando a notificação some ou muda

- QUANDO o usuário toca na notificação ENTÃO ela some (no Android, com `setAutoCancel`). [D3]
- QUANDO o usuário arrasta/limpa ENTÃO ela some; no iPhone, "passe o dedo para a esquerda ... e toque em Limpar ou Limpar Tudo". [A12, D3]
- QUANDO o usuário abre a conversa no celular ENTÃO as notificações daquela conversa somem. `NÃO CONFIRMADO` por fonte escrita (comportamento observado). Mecanismo disponível: iPhone `removeDeliveredNotifications(withIdentifiers:)` [A6]; Android `cancel(id)` [D3].
- QUANDO o usuário lê a conversa em outro aparelho (WhatsApp Web, computador, iPad) ENTÃO as notificações do celular somem. `NÃO CONFIRMADO` — nenhuma fonte encontrada. O que é confirmado: apagar mensagem "will sync across all online devices where you are logged into WhatsApp" [W8], e cada aparelho conectado recebe push de forma independente [W3].
- QUANDO o remetente apaga a mensagem "para todos" ENTÃO na conversa ela vira "Esta mensagem foi apagada" ("This message was deleted"), ou "This message was deleted by admin [nome]" quando foi um admin. [W8] O próprio WhatsApp avisa: "Recipients might see your message before it's deleted" [W8]. Se a notificação já exibida é retirada ou reescrita: `NÃO CONFIRMADO` (sites de terceiros dizem que a prévia já mostrada não é apagada; sem fonte oficial).
- QUANDO a mensagem é **editada** (até 15 min) ENTÃO **não** gera notificação nova: "Editing a message won't send a new chat notification to people in your chat." A mensagem passa a mostrar "editada" ao lado do horário. [W7] Se a notificação antiga é atualizada com o texto novo: `NÃO CONFIRMADO`.
- QUANDO o usuário toca "Marcar como lida" na notificação (Android) ENTÃO a conversa fica lida sem abrir o app e a notificação some. [T8 (imprensa, 2018)]
- QUANDO uma reação é removida ENTÃO nenhuma notificação é enviada ao autor da mensagem. [W6]

**Fontes da seção 3:** W3, W6, W7, W8, A6, A12, D3, T8.

---

## 4. Contador (badge) no ícone

- QUANDO há mensagens e chamadas não vistas ENTÃO o ícone mostra um contador; o WhatsApp descreve o badge como aviso de "unread messages and missed calls". [W16]
- QUANDO a opção **"Limpar contador ao visualizar" / "Clear badge when viewed"** está ligada ENTÃO o ícone mostra "the total unseen message and call count ... until you view them" (o total de mensagens e chamadas não vistas, até o usuário vê-las). [W1 iPhone e Android] Ou seja: conta **mensagens + chamadas**, não conversas.
- QUANDO a opção acima está desligada ENTÃO o contador zera inteiro toda vez que o app é aberto ("Your home screen badge clears completely after every time you open the app"). [T5, T6 (imprensa, fev/2025)]
- QUANDO a conversa está silenciada ENTÃO, no iPhone, ela **não** soma no contador do ícone (mudança da versão 2.19.110 de out/2019). [T4, T12 (imprensa)] Dentro do app o número de não lidas continua ao lado da conversa: "You'll still have the unread message count next to the chat." [W2]
- QUANDO é Android ENTÃO o número no ícone depende do launcher do fabricante ("The notification count is functionality provided by your launcher and is not a function of WhatsApp"). [W16] Padrão do Android 8+: um ponto aparece no ícone enquanto houver notificação ativa; o número no menu de toque longo pode ser definido com `setNumber()`; um canal pode ter o ponto desligado com `setShowBadge(false)`. [D7]
- QUANDO o contador está errado ENTÃO o WhatsApp recomenda pedir que alguém mande mensagem nova, o que "should automatically refresh the message count". [W16] (indica que o contador é recalculado a cada push).
- Mecanismo no iPhone nativo: `setBadgeCount`. [A7]

**Fontes da seção 4:** W1, W2, W16, A7, D7, T4, T5, T6, T12.

---

## 5. Silenciar conversa, grupo, canal e comunidade

- QUANDO o usuário silencia uma conversa ou grupo ENTÃO escolhe **8 horas, 1 semana ou Sempre**; as mensagens continuam chegando, mas o aparelho não toca nem vibra. [W2]
- QUANDO a conversa está silenciada ENTÃO: o outro lado **não** é avisado; a confirmação de leitura continua indo se estiver ligada; o número de não lidas continua ao lado da conversa. [W2]
- QUANDO o grupo está silenciado e alguém **menciona (@) o usuário** ou **responde a uma mensagem dele** ENTÃO o usuário **é notificado mesmo assim**: "You'll still get notifications for mentions and replies." [W1 Android e iPhone]
- QUANDO alguém usa **@all (@todos)** num grupo ENTÃO todos são notificados, inclusive quem silenciou o grupo; o usuário pode desligar isso em "Silenciar menções @all". [W1, B1, T2] Em grupos com mais de 32 pessoas, só admin pode usar @all. [B1, T2]
- QUANDO o grupo está em **"Notificar sobre: Destaques"** ENTÃO só notifica "mentions, replies, messages from contacts, and other relevant messages"; em **"Todas"** notifica toda mensagem. [W1, B2]
- QUANDO o grupo é grande ENTÃO o padrão já é "Destaques"; em grupos pequenos o padrão é notificar tudo. [T1 (imprensa)]
- QUANDO o usuário silencia o grupo ENTÃO pode silenciar **mensagens** e **chamadas** do grupo separadamente. [W1 iPhone, W2, W11]
- QUANDO o usuário segue um **canal** ENTÃO as notificações começam **desligadas**; ao ligar no sino, funcionam igual às de mensagens pessoais. [W15]
- QUANDO o usuário silencia um grupo dentro de uma **comunidade** ENTÃO os outros grupos continuam notificando; o grupo de **avisos** (announcement) é silenciado à parte, e silenciar é o único jeito de calar os avisos sem sair da comunidade. [W14] Menções (@) continuam notificando mesmo com o grupo silenciado. [W14]
- QUANDO o usuário silencia uma **lista** (Favoritos ou lista própria) ENTÃO todas as conversas da lista ficam silenciadas (8h / 1 semana / Sempre), mas ele ainda é notificado se for mencionado. [W1, W2]

**Fontes da seção 5:** W1, W2, W11, W14, W15, B1, B2, T1, T2.

---

## 6. Ações direto na notificação

- QUANDO chega mensagem no Android ENTÃO a notificação tem os botões **Responder** e **Marcar como lida**. [T8 (imprensa, 2018)]
- QUANDO o usuário responde pela notificação no Android ENTÃO o app deve atualizar a mesma notificação acrescentando a resposta (`MessagingStyle.addMessage()`) e **não** cancelá-la, para permitir várias respostas seguidas; atualizar com o mesmo ID também esconde a caixa de digitação e confirma que a resposta foi enviada. [D3]
- QUANDO o usuário mantém pressionada a notificação no iPhone ENTÃO aparecem as ações rápidas que o app oferece. [A12] Para resposta por texto, o recurso nativo é `UNTextInputNotificationAction`. [A8] Quais ações exatas o WhatsApp oferece no iPhone (responder, reagir) é `NÃO CONFIRMADO`.
- QUANDO o usuário responde pela notificação ENTÃO a conversa é marcada como lida. `NÃO CONFIRMADO`.

**Fontes da seção 6:** A8, A12, D3, T8.

---

## 7. Reações

- QUANDO alguém reage a uma mensagem ENTÃO **só o autor da mensagem** recebe notificação: "only the sender of the message being reacted to will receive a notification." [W6]
- QUANDO alguém remove a reação ENTÃO nenhuma notificação é enviada; quem recebeu pode ter visto antes da remoção. [W6]
- QUANDO o usuário não quer saber de reações ENTÃO desliga "Notificações de reação", separadamente para conversas individuais e para grupos. [W1] Vem ligado por padrão. [T9 (imprensa)]
- QUANDO a reação é em mensagem temporária ENTÃO a reação some junto com a mensagem. [W6]
- Texto exato da notificação ("Fulano reagiu 👍 à sua mensagem"): `NÃO CONFIRMADO`.

**Fontes da seção 7:** W1, W6, T9.

---

## 8. Chamadas de voz e vídeo

### 8.1 Chamada recebida — iPhone

- QUANDO chega chamada com o iPhone bloqueado ENTÃO aparece a tela nativa de chamada com o texto **"WhatsApp Audio..."**, onde o usuário pode: deslizar para atender; tocar **Lembrar-me** (ao sair / em 1 hora); tocar **Mensagem** para recusar com um recado; recusar apertando o botão lateral duas vezes. [W9 iPhone]
- QUANDO o app usa CallKit ENTÃO a tela de chamada é a mesma do app Telefone e respeita o Não Perturbe. [A5] Todo app que recebe push de chamada (PushKit/VoIP) é **obrigado** a avisar o CallKit na hora; se não avisar, o iOS fecha o app e pode parar de entregar pushes de chamada. [A3, A4] O pedido de push de chamada deve ter validade 0 ou poucos segundos (`apns-expiration`), para não tocar atrasado. [A4]
- QUANDO o Não Perturbe está ligado ENTÃO o sistema pode recusar mostrar a chamada (o CallKit devolve erro). [A3]
- QUANDO o iPhone usa integração de chamadas (iOS 12+) ENTÃO o toque da chamada de voz é o toque definido no contato no app Contatos; no iOS 16.2+ pode ser escolhido no WhatsApp em Papel de parede e som > Tom de alerta. [W5]
- QUANDO é chamada em grupo ENTÃO usa um toque padrão que **não** pode ser trocado. [W5]
- QUANDO a chamada é feita ou recebida ENTÃO ela aparece no histórico de chamadas do próprio iPhone; não dá para impedir. [W13]

### 8.2 Chamada recebida — Android

- QUANDO chega chamada de voz com o Android bloqueado ENTÃO aparece a tela de chamada em tela cheia: deslizar para cima para **atender**, para **recusar** ou para **recusar com mensagem rápida**. [W9 Android]
- QUANDO chega chamada com o Android desbloqueado ENTÃO aparece um pop-up **"Chamada de voz recebida"** com **Recusar** e **Atender**; para vídeo, **Recusar** e **Vídeo**. [W9, W10 Android]
- QUANDO chega chamada de vídeo com o aparelho bloqueado ENTÃO aparece a tela de vídeo com aceitar / recusar / responder com mensagem e, se disponível, "Desligar seu vídeo" para atender sem câmera. [W10]
- Mecanismo oficial do Android: notificação `CallStyle` (Android 12+) — `forIncomingCall` (botões Atender/Recusar), `forOngoingCall` (botão Desligar), com prioridade máxima na aba de notificações; os textos e ícones dos botões são postos pelo sistema. [D4] No Android 14+ a notificação de chamada pode ser não descartável (`setOngoing(true)`). [D4] Tela cheia (`fullScreenIntent`): com o aparelho bloqueado abre a tela; com o aparelho em uso vira notificação flutuante (heads-up). [D5] No Android 14+, a permissão de tela cheia só fica para apps de **chamada e alarme**; verificar com `canUseFullScreenIntent()`. [D6]

### 8.3 Chamada perdida, recusada, ocupado

- QUANDO o usuário não atende ENTÃO quem ligou vê a opção **Gravar mensagem de voz** (ou **Gravar recado em vídeo**, em chamada de vídeo); quem perdeu recebe o recado na conversa e uma notificação. [W9, W10]
- QUANDO a chamada é perdida ENTÃO aparece notificação de "Chamada de voz perdida" / "Chamada de vídeo perdida" com botões "Ligar de volta" e "Mensagem". `NÃO CONFIRMADO` (textos e botões sem fonte). Regra oficial do Android: notificação de chamada perdida deve ser formatada como conversa com categoria `CATEGORY_MISSED_CALL`. [D1] No iPhone, a notificação de comunicação de chamada pode levar um registro para "ligar de volta" (`callRecordToCallBack`). [A1]
- QUANDO a chamada perdida entra no histórico ENTÃO aparece na aba Chamadas (recebidas, feitas e perdidas). [W13]
- QUANDO o número é desconhecido e "Silenciar desconhecidos" está ligado ENTÃO o telefone não toca, mas a chamada aparece na aba Chamadas e em Notificações. [W12]
- Tempo de toque até virar chamada perdida: `NÃO CONFIRMADO`. Um site diz 45 a 60 s, sem citar fonte [T10]; desenvolvedores relatam que o CallKit do iPhone encerra sozinho qualquer chamada após 60 s tocando ("Exceeded ringing duration of 60 seconds"), confirmado como "by design" por conversa com a Apple, não por documento. [T11]
- Comportamento quando a pessoa chamada está **ocupada** em ligação normal de operadora: ver 8.5. Mensagem "ocupado" para quem liga: `NÃO CONFIRMADO`.

### 8.4 Chamada em grupo

- QUANDO alguém chama o usuário para uma chamada em grupo ENTÃO ele recebe notificação; a tela de chamada recebida mostra quem está na chamada, e o **primeiro nome listado é quem o adicionou**. [W11]
- QUANDO o usuário toca a notificação ENTÃO abre a tela de detalhes, onde vê participantes e convidados e toca **Participar**; no Android pode tocar **Ignorar**. [W11]
- QUANDO a chamada em grupo foi perdida mas ainda está acontecendo ENTÃO dá para entrar depois pela aba Chamadas ou pela conversa do grupo, tocando **Participar**. [W11]
- QUANDO alguém já na chamada toca **Tocar** ("Ring") ENTÃO os convidados que ainda não entraram recebem nova notificação. [W11]
- Limite: até 32 pessoas. Não dá para trocar voz por vídeo numa chamada em grupo. [W11, W10]

### 8.5 Outra chamada em andamento

- QUANDO chega chamada do WhatsApp com o usuário já numa chamada do WhatsApp ENTÃO aparece uma notificação **sem interromper** a chamada atual; no iPhone: **Encerrar e Aceitar** ou **Recusar**; no Android: **Atender** (encerra a atual) ou **Recusar**. [W12]
- QUANDO chega ligação comum (operadora) durante chamada do WhatsApp no iPhone ENTÃO as opções são **Encerrar e Aceitar**, **Reter e Aceitar** ou **Enviar para caixa postal**. [W12 iPhone]

**Fontes da seção 8:** W5, W9, W10, W11, W12, W13, A1, A3, A4, A5, D1, D4, D5, D6, T10, T11.

---

## 9. Sons, vibração e canais

- QUANDO o usuário configura sons ENTÃO há tons separados para **mensagens**, **mensagens de grupo** e **chamadas**. [W5, W1]
- QUANDO é Android ENTÃO em Configurações > Notificações, separado para Mensagens e Grupos: Tons de conversa, Tom de notificação, Vibração (duração), Notificação pop-up, Luz, **Usar notificações de alta prioridade** ("show previews of notifications at the top of your screen") e Notificações de reação; para Chamadas: Vibração e Toque. [W1 Android]
- QUANDO é iPhone ENTÃO em Ajustes > Notificações: Mostrar notificações e Som (para mensagens e para grupos), Notificações de reação, Notificações no app (Nenhum/Banners/Alertas + Sons + Vibrar), Mostrar prévia. [W1 iPhone] Sons personalizados no iPhone só da lista interna do WhatsApp. [W3 iPhone]
- QUANDO o usuário personaliza uma conversa ou grupo ENTÃO pode trocar tom, vibração, luz, pop-up e alta prioridade daquela conversa; ao ligar notificação personalizada, **uma nova categoria aparece nos ajustes do aparelho**. [W1, W14]
- QUANDO o tom está em "Silencioso"/"Nenhum" ENTÃO não toca som mesmo com o som do sistema ligado. [W3]
- QUANDO é Android ENTÃO cada configuração vira um canal de notificação; o WhatsApp cria canais com nomes como `individual_chat_defaults_XX`, um novo a cada mudança de tipo de notificação. [T7 (relato técnico)] Lista completa dos canais do WhatsApp: `NÃO CONFIRMADO`.
- Regras oficiais dos canais do Android: Urgente (`IMPORTANCE_HIGH`) = "Makes a sound and appears as a heads-up notification"; Alta (`IMPORTANCE_DEFAULT`) = faz som; Média = sem som; Baixa = sem som e fora da barra de status. Depois de criado, o app não muda mais o comportamento do canal; só o usuário. [D8]
- QUANDO o pop-up (heads-up) some no Android 10+ ENTÃO o WhatsApp manda colocar a importância em Urgente/Alta nos ajustes do aparelho. [W3 Android]

**Fontes da seção 9:** W1, W3, W5, W14, D8, T7.

---

## 10. Não Perturbe, Foco, tela bloqueada e vários aparelhos

- QUANDO o iPhone está em Foco (Não Perturbe, Sono etc.) ENTÃO as notificações do WhatsApp são silenciadas, a não ser que o WhatsApp esteja na lista "Permitir Notificações de". [W1, W3 iPhone, A11]
- QUANDO a notificação é de comunicação (mensagem/chamada com intent) ENTÃO ela pode furar o Resumo Agendado por padrão e pode furar um Foco. [A1]
- QUANDO o WhatsApp está no Resumo Agendado ENTÃO as notificações podem atrasar. [W3 iPhone]
- QUANDO o Não Perturbe do iPhone está ligado ENTÃO "WhatsApp notification settings may override Do Not Disturb". [W1 iPhone]
- QUANDO há ligações repetidas (duas da mesma pessoa em até 3 minutos) ENTÃO o Foco pode deixá-las tocar, se o usuário ligar essa opção. [A11]
- QUANDO o usuário fecha o app à força (desliza para cima) no iPhone ENTÃO pode deixar de receber notificações. [W3 iPhone]
- QUANDO há aparelhos conectados (iPad, tablet, segundo celular) ENTÃO cada um recebe push **de forma independente**, sem precisar do celular principal online; desconecta se o principal ficar 14 dias sem uso. [W3, W17]
- QUANDO o WhatsApp Web/computador está fechado ENTÃO não há notificação nele ("You won't receive notifications while WhatsApp remains closed") e não há notificação de tela bloqueada no Web. [W1 Web]
- QUANDO o WhatsApp Web está aberto e ativo ENTÃO o celular para de notificar. `NÃO CONFIRMADO` — só relatos de fórum, sem fonte oficial.

**Fontes da seção 10:** W1, W3, W17, A1, A11.

---

## 11. Comportamento dentro do app

- QUANDO chega mensagem na conversa aberta ENTÃO toca o tom de conversa (som curto); também toca ao **enviar**. [W4] No WhatsApp Web há sons separados para "entrada" e "saída". [W1 Web]
- QUANDO chega mensagem de outra conversa com o app aberto ENTÃO aparece banner interno, sobe o contador ao lado da conversa e o contador do ícone. [W3]
- QUANDO o usuário quer controlar isso no iPhone ENTÃO usa Notificações no app: estilo Nenhum/Banners/Alertas, Sons e Vibrar. [W1 iPhone]
- Vibração ao receber com app aberto no Android: `NÃO CONFIRMADO`.

**Fontes da seção 11:** W1, W3, W4.

---

## 12. Limites do app web instalado no iPhone (PWA, iOS 16.4+)

### 12.1 O que funciona

- QUANDO o site é adicionado à Tela de Início com manifesto `display: standalone` (ou `fullscreen`) ENTÃO pode pedir permissão de notificação — mas **só em resposta a um toque do usuário** (ex.: botão "Ativar avisos"). [K1] Em aba do Safari (sem instalar) a API de notificação nem existe. [K5]
- QUANDO a permissão é dada ENTÃO o push aparece "exatamente como" o de outros apps: tela bloqueada, Central de Notificações e Apple Watch; o usuário controla por Foco e Ajustes. [K1, K2] O Foco do iPhone deixa permitir ou silenciar web apps da Tela de Início individualmente. [A11]
- QUANDO a notificação é dada ENTÃO o **contador no ícone** (Badging API: `navigator.setAppBadge(n)` / `clearAppBadge()`) já vem autorizado, e funciona com o app aberto ou **enquanto trata um push em segundo plano**. [K1, K2] No iOS, `setAppBadge(0)` apaga o contador. [K5]
- QUANDO a mesma web app é instalada mais de uma vez (contas diferentes) ENTÃO o campo `id` do manifesto separa notificações e contador de cada instalação. [K1, K2]
- QUANDO se usa `getNotifications()` no service worker ENTÃO é suportado desde o iOS 16.4 (web app da Tela de Início). [K5] Um engenheiro relatou que funciona no iOS 17.1. [K4]
- QUANDO o iOS é 18.4+ ENTÃO existe o **Declarative Web Push**: o push traz pronto `title`, `body`, `navigate` (link a abrir), `app_badge` e `silent`, e aparece mesmo sem service worker. [K3]
- QUANDO o iOS é 18.4+ ENTÃO a trava de tela acesa (Screen Wake Lock) funciona também em web app da Tela de Início (antes não funcionava). [K5]

### 12.2 O que NÃO funciona (ou não é garantido)

- QUANDO o push chega e o service worker **não mostra** notificação ENTÃO o iOS trata como push silencioso, que é proibido, e **cancela a inscrição**. [K3] Ou seja: não dá para usar push só para "atualizar dados" ou "apagar notificação" sem mostrar algo.
- QUANDO se usa `tag` para substituir a notificação anterior da mesma conversa ENTÃO **não substitui** no iOS: aparecem as duas. Bug aberto desde 2023 ("We don't support tag yet") e ainda aberto em 31/07/2026. [K4] O MDN marca `tag` como não suportado no iOS. [K5]
  - Contorno relatado: no service worker, pegar `getNotifications()`, filtrar pela conversa, chamar `close()` nelas e depois mostrar a nova. [K4] Mas o mesmo bug relata `Notification.close()` **não funcionando** no iOS 17.1 [K4] → apagar notificação antiga pelo service worker é `NÃO CONFIRMADO` (testar no iOS atual).
- QUANDO se definem botões (`actions`: Responder, Marcar como lida, Atender) ENTÃO **não aparecem** no iOS; só o toque padrão para abrir. MDN: `actions` não suportado no iOS [K5]; desenvolvedores relatam só "View" aparecendo [K6]. Resposta digitada na notificação: **impossível**.
- QUANDO se pede vibração (`vibrate`, `navigator.vibrate`) ENTÃO não funciona no iOS. [K5]
- QUANDO se usa `image`, `icon`, `badge` (ícone pequeno), `requireInteraction`, `renotify`, `silent`, `timestamp` em `showNotification` ENTÃO o MDN marca como não suportado no iOS (`icon` "can be set, but has no effect"). [K5] Foto do remetente na notificação (como o WhatsApp faz com a API de comunicação da Apple [A1]): **não disponível** para web app — consequência das linhas acima.
- QUANDO há chamada recebida ENTÃO **não há tela nativa de chamada (CallKit)** nem toque contínuo: PushKit/CallKit são APIs de app nativo [A3, A4, A5], e a web só tem a notificação comum (um aviso, com o som padrão). Toque contínuo, tela cheia de chamada e "Áudio do WhatsApp" na tela bloqueada: **impossíveis** em web app.
- QUANDO se quer agrupar por conversa no iPhone ENTÃO não há como informar `threadIdentifier` pela Web Push. `NÃO CONFIRMADO` se o iOS agrupa sozinho por algum campo; considerar que agrupa só por app.
- QUANDO se quer som próprio por conversa ENTÃO não há opção na API de notificação da web. `NÃO CONFIRMADO` (sem fonte que diga que existe).
- Atenção ao `notificationclick`: o MDN (dados de 01/10/2026) marca `notificationclick` e `NotificationEvent.notification` como não suportados no iOS [K5], mas desenvolvedores usam `notificationclick` com `event.notification.tag` para abrir a URL certa [K6]. Abrir a conversa certa ao tocar: usar `navigate` do Declarative Web Push (iOS 18.4+) [K3] e testar o caminho com service worker no aparelho.

**Fontes da seção 12:** A1, A3, A4, A5, A11, K1, K2, K3, K4, K5, K6.

---

## 13. Matriz para o app BL CEO

Legenda: **Sim** = dá para fazer igual; **Parcial** = dá para fazer algo parecido; **Não** = impossível
nessa plataforma; **Testar** = depende de algo `NÃO CONFIRMADO`, validar no aparelho.
"iPhone (app web instalado)" = PWA da Tela de Início, iOS 16.4+. "Android nativo" = app Flutter
compilado para Android (usa as APIs nativas do Android).

| # | Comportamento (igual ao WhatsApp) | iPhone (app web instalado) possível? | Android nativo possível? | Como implementar |
|---|---|---|---|---|
| 1 | Push com app fechado/segundo plano (banner, tela bloqueada, som padrão) | Sim [K1] | Sim [D8] | iPhone: Web Push (VAPID) + `showNotification` no service worker; pedir permissão só após toque. Android: push de dados + notificação local em canal "Mensagens" com importância Urgente. |
| 2 | Banner interno ao receber de outra conversa com app aberto | Sim (banner desenhado na tela) | Sim | Tempo real (Supabase Realtime) → componente de banner próprio no topo; não usar notificação do sistema com app em primeiro plano. |
| 3 | Som curto ao receber na conversa aberta / ao enviar (tom de conversa) | Parcial (só com app aberto; iOS pode bloquear áudio sem toque prévio — Testar) | Sim [W4] | Tocar arquivo curto local ao receber/enviar; respeitar modo silencioso; opção "Tons de conversa" liga/desliga. |
| 4 | Título com nome do contato / "Grupo: Fulano" e prévia do texto | Sim (title/body) | Sim [D1] | Montar no servidor: direta = nome; grupo/canal = nome do grupo + remetente. Formato exato do WhatsApp `NÃO CONFIRMADO` — definir padrão BL. |
| 5 | Prévia de mídia ("📷 Foto", "🎤 Mensagem de voz (0:12)", "📄 Documento") | Sim (texto) | Sim | Tabela de textos por tipo de anexo no servidor. Textos exatos do WhatsApp `NÃO CONFIRMADO`. |
| 6 | Foto do remetente na notificação | Não [K5, A1] | Sim [D1] | Android: `Person` com ícone (104dp) no `MessagingStyle` + atalho de conversa. iPhone web: sem foto. |
| 7 | "Mostrar prévia" desligado (sem texto) | Sim | Sim [D3] | Preferência do usuário salva no banco; servidor manda "Nova mensagem" sem conteúdo. Android: também `VISIBILITY_PRIVATE` + versão pública. |
| 8 | Conversa trancada mostra só o nome do app | Sim | Sim [W1] | Flag na conversa; servidor omite nome e texto (vale para chamadas também). |
| 9 | Agrupar por conversa (pilha por conversa) | Não / Testar [K4] | Sim [D1, D2] | Android: um ID de notificação por conversa + `setGroup` + resumo. iPhone web: sem `threadIdentifier`; aceitar agrupamento só por app. |
| 10 | Atualizar a mesma notificação em vez de criar outra | Não (tag não substitui) [K4]; contorno Testar | Sim [D3] | Android: `notify` com o mesmo ID + `MessagingStyle.addMessage` + `setOnlyAlertOnce`. iPhone: tentar `getNotifications` + `close` antes de mostrar a nova (bug relatado). |
| 11 | Resumo "X mensagens de Y conversas" | Não | Sim [D2] | Android: notificação-resumo do grupo com `InboxStyle`. Texto exato `NÃO CONFIRMADO`. |
| 12 | Notificação some ao abrir a conversa no celular | Testar [K4, K5] | Sim [D3] | Android: `cancel(id da conversa)` ao abrir. iPhone: `getNotifications()` + `close()` na abertura da conversa (testar). |
| 13 | Notificação some ao ler em outro aparelho (computador) | Não (push silencioso proibido) [K3] | Sim | Android: push de dados "lida" → `cancel`. iPhone web: não dá para apagar sem mostrar outra notificação; só corrigir na próxima abertura/push. Comportamento do WhatsApp `NÃO CONFIRMADO`. |
| 14 | Mensagem apagada para todos | Parcial | Sim | Na conversa: "Esta mensagem foi apagada" [W8]. Notificação já mostrada: Android `cancel`/reescrever; iPhone não garantido. |
| 15 | Mensagem editada não gera notificação nova | Sim [W7] | Sim [W7] | Servidor não envia push em edição; só atualiza a conversa via tempo real. |
| 16 | Contador no ícone = mensagens + chamadas não vistas | Sim [K1] | Parcial (depende do launcher) [W16, D7] | iPhone: `setAppBadge(total)` em cada push e ao abrir; total calculado no servidor e enviado no push (ou `app_badge` no Declarative Web Push). Android: ponto automático + `setNumber(total)`. |
| 17 | Conversa silenciada não soma no contador do ícone, mas mostra não lidas na lista | Sim | Sim | Servidor exclui conversas silenciadas do total do ícone [T4]; lista mostra não lidas sempre [W2]. |
| 18 | Silenciar 8 h / 1 semana / Sempre | Sim | Sim [W2] | Tabela de preferência por usuário+conversa com `silenciado_ate`; servidor decide se manda push. |
| 19 | Silenciado ainda notifica menção (@) e resposta à minha mensagem | Sim | Sim [W1] | Servidor: se silenciado, só envia push quando há menção ao usuário ou resposta a mensagem dele. |
| 20 | @todos fura o silenciar (com opção "Silenciar @todos") | Sim | Sim [B1] | Flag `mencao_todos`; restringir a admin em grupo >32 pessoas (regra do WhatsApp). |
| 21 | Grupo em "Destaques" x "Todas" | Sim | Sim [W1] | Preferência por grupo; padrão "Destaques" para grupos grandes [T1]. |
| 22 | Canal de departamento começa silenciado; liga pelo sino | Sim | Sim [W15] | Ao entrar no canal, preferência padrão = desligado. |
| 23 | Responder pela notificação | Não [K5, K6] | Sim [D3] | Android: ação com `RemoteInput`; após enviar, `addMessage` e manter a notificação. |
| 24 | Marcar como lida pela notificação | Não [K5, K6] | Sim [T8] | Android: ação que chama a API de leitura e cancela a notificação. |
| 25 | Notificação de reação só para o autor da mensagem; desligável | Sim | Sim [W6, W1] | Servidor envia push só ao autor; preferência "Notificações de reação" (diretas e grupos separados). |
| 26 | Chamada recebida com tela nativa e toque contínuo | Não [A3–A5] | Sim [D4, D5, D6] | Android: `CallStyle.forIncomingCall` + `fullScreenIntent` (permissão de app de chamada no Android 14+) + toque contínuo pelo canal "Chamadas". iPhone web: só uma notificação "Chamada de voz de Fulano" com som padrão; ao tocar, abre o app na tela de chamada. |
| 27 | Atender/recusar pela notificação | Não | Sim [D4] | Android: botões do `CallStyle` (texto vem do sistema). |
| 28 | Recusar com mensagem rápida | Não (na notificação) / Sim (dentro do app) | Sim [W9] | Tela de chamada do app com lista de respostas rápidas. |
| 29 | Notificação de chamada em andamento com botão Desligar | Não | Sim [D4] | Android: `CallStyle.forOngoingCall` + serviço em primeiro plano. |
| 30 | Toque até virar chamada perdida | Parcial (servidor encerra) | Sim | Servidor encerra a chamada após tempo fixo (sugestão 60 s, igual ao limite do CallKit [T11]; tempo do WhatsApp `NÃO CONFIRMADO`). |
| 31 | Chamada perdida (notificação + histórico) | Sim (notificação simples) | Sim [D1] | Push "Chamada de voz perdida — Fulano"; Android com categoria `CATEGORY_MISSED_CALL`. Botões "Ligar de volta"/"Mensagem": só Android. |
| 32 | Recado de voz/vídeo quando não atendem | Sim | Sim [W9, W10] | Ao fim sem resposta, oferecer "Gravar mensagem de voz" para quem ligou; o recado vai para a conversa e gera notificação normal. |
| 33 | Chamada em grupo: notificação, Participar/Ignorar, entrar depois, botão "Tocar" de novo | Parcial (sem botões) | Sim [W11] | Push por convidado; tela de detalhes com Participar; "Tocar" reenvia push aos que não entraram. |
| 34 | Outra chamada durante chamada (Encerrar e aceitar / Recusar) sem interromper | Parcial (aviso dentro do app) | Sim [W12] | Sinalização de "ocupado em chamada" no servidor; aviso dentro da tela de chamada. |
| 35 | Sons separados: mensagens, grupos, chamadas; som por conversa | Não (som padrão do sistema) | Sim [W1, D8] | Android: canais separados (Mensagens, Grupos, Chamadas, Reações, Avisos/Pedidos/Reuniões); som por conversa = canal próprio (o WhatsApp cria categoria nova [W1, T7]). |
| 36 | Vibração | Não [K5] | Sim [W1] | Android: padrão de vibração por canal. |
| 37 | Alta prioridade / aparecer no topo (heads-up) | Não controla | Sim [D8, W1] | Canal com `IMPORTANCE_HIGH` (Urgente). |
| 38 | Respeitar Foco/Não Perturbe | Sim (sistema decide) [A11, K1] | Sim (sistema decide) | Nada a fazer além de não tentar furar. Furar Foco como "comunicação": só app nativo iOS [A1]. |
| 39 | Vários aparelhos recebem push independentes | Sim | Sim [W3] | Uma inscrição de push por aparelho, guardada no banco central por usuário. |
| 40 | Celular para de notificar com o computador ativo | Sim (regra no servidor) | Sim (regra no servidor) | Comportamento do WhatsApp `NÃO CONFIRMADO`; se adotar, servidor pula push do celular quando houver sessão ativa recente no computador. |
| 41 | Avisos, pedidos e reuniões (itens próprios do BL) | Sim | Sim | Sem equivalente direto no WhatsApp. Sugestão: tratar como canal de notificação próprio no Android ("Avisos", "Pedidos", "Reuniões") e lembrete de reunião como os eventos/chamadas agendadas do WhatsApp ("get reminded when the call is about to start" — página Sobre chamadas em grupo, faq.whatsapp.com/1148204430154253). |
| 42 | Abrir a conversa certa ao tocar na notificação | Sim / Testar [K3, K5, K6] | Sim | iPhone 18.4+: campo `navigate` (Declarative Web Push); senão `notificationclick` + `clients.openWindow`. Android: `PendingIntent` para a conversa. |

### Resumo da matriz

- O app web instalado no iPhone consegue: push com título e texto, contador no ícone, silenciar/menções/@todos (tudo decidido no servidor), canais começando silenciados, edição sem notificação, filtros do Foco.
- O app web instalado no iPhone **não** consegue: tela nativa de chamada e toque contínuo, vibração, botões na notificação (responder, marcar como lida, atender), foto do remetente, substituir notificação por conversa, apagar notificação por push silencioso.
- O Android nativo consegue copiar praticamente tudo, usando: canais por tipo, `MessagingStyle` com atalho de conversa, uma notificação por conversa atualizada no mesmo ID, resposta direta, `CallStyle` + tela cheia para chamadas.
- Para chegar no nível do WhatsApp no iPhone (CallKit, foto do remetente, furar Foco) é preciso app nativo iOS com PushKit/CallKit e notificações de comunicação [A1, A3–A5].

### Pendências `NÃO CONFIRMADO` para testar em aparelho real antes de copiar

1. Textos exatos de prévia de mídia e de grupo ("📷 Foto", "🎤 Mensagem de voz (0:12)", "Fulano @ Grupo").
2. Texto do resumo "X mensagens de Y conversas" no Android.
3. Se a notificação some ao ler no computador e se é removida/alterada ao apagar para todos.
4. Botões da notificação de chamada perdida e tempo exato de toque do WhatsApp.
5. Ações do WhatsApp no toque longo da notificação no iPhone (responder/reagir).
6. Se o celular deixa de notificar com o WhatsApp Web ativo.
7. No iPhone web: se `close()` e `getNotifications()` funcionam no iOS atual e se o toque na notificação abre a URL certa pelo service worker.
