# Notificações implementadas (07/10/2026) — base: docs/notificacoes-whatsapp.md

## No servidor (banco do TEAM's)
- Gatilhos AFTER INSERT (pg_net, assíncrono, nunca travam a gravação): chat_mensagem (menos tipo 'sistema'), chat_chamada (início e perdida = encerrada sem atendimento), chat_aviso, chat_pedido (fora de conversa), chat_reuniao_participante.
- Edge `teams-push` (trava: segredo do Vault no cabeçalho x-gatilho; chave VAPID gerada e guardada no Vault).
- Quem recebe: membros da conversa (direta/grupo) ou inscritos do setor; nunca o autor; silenciado só recebe se for mencionado (@) ou se responderam a mensagem dele (igual WhatsApp).
- Edição não notifica (só INSERT). Mensagem apagada antes do envio (1,5 s) não notifica.
- Textos: direta = título nome da pessoa, corpo a mensagem; grupo/setor = título nome do grupo, corpo "Fulano: mensagem"; mídia "🎤 Mensagem de voz", "📷 Foto", "📄 nome"; chamada "📞 Chamada de voz recebida"/"📹 Chamada de vídeo recebida"; perdida "📞 Chamada de voz perdida"; grupo "Fulano está chamando para uma chamada de voz em grupo".
- Contador no ícone = mensagens não lidas das conversas não silenciadas (mesmo número do app), enviado em cada aviso.
- Inscrição morta (410/404) é apagada.

## No app (iPhone, app web instalado)
- Pede permissão no primeiro toque (exigência da Apple). Guarda inscrição por aparelho com os setores da pessoa.
- Banner do sistema com app fechado/segundo plano; toque abre a conversa certa (ou a aba de avisos/pedidos/reuniões).
- Ao abrir a conversa: fecha os avisos daquela conversa e atualiza o contador do ícone.
- Com o app aberto: toque de ligação contínuo + vibração (Android), som curto de mensagem.

## Limites do iPhone sem app nativo (Apple)
- Sem toque contínuo de ligação nem tela de chamada com o app fechado (só o aviso com som padrão).
- Sem vibração personalizada, sem botões no aviso (responder/atender), sem foto de quem mandou.
- Não dá para apagar aviso à distância (ler em outro aparelho) sem mostrar outro aviso.
