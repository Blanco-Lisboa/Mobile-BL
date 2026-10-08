# App BL CEO × TEAMS-GUIA-PARA-O-APP-CEO.md (07/10/2026)

| Item do guia | No app |
|---|---|
| 1. Banco lhqjfdexfexpmnoqhbyv + chave pública | Igual (`lib/config/bancos.dart`) |
| 1. Login só da BL; pessoas/setores/clientes da BL, Team's guarda só ID | Igual (equipe lida da BL na hora; cliente = `meta.cliente_id`) |
| 1. LiveKit na VPS `wss://meet.it-ia.tec.br` | Igual — conferido hoje: servidor responde e sem passe = 401 |
| 1. Anexos no bucket `chat-anexo`, pasta = id da conversa | Igual |
| 2. `teams-entrar` com `bl_token`; sessão do Team's não guardada; refaz a cada abertura | Igual (cliente do Team's só em memória; entrada refeita no `iniciar`) |
| 3. Regras de segurança | Respeitadas (autor = eu; editar/apagar só meus; pedido só solicitante/dono) |
| 4. RPCs `chat_resumo`, `chat_abrir_direta/setor`, `chat_criar_grupo`, `chat_marcar_lido`, `chat_pendencias`, `chat_marcar_visto` | Todas usadas |
| 4. Tempo real nas 7 tabelas | Ligado (mais `chat_canal`, `chat_anexo`, `chat_recibo`) — sem consulta repetida |
| 5. Topo com status (Online, Em reunião, Ausente, Não me interrompam) em `chat_presenca` | Feito (toque no seu nome) |
| 5. Abas Conversas/Avisos/Pedidos/Reuniões com não vistos | Feito (barra de baixo, padrão de celular) |
| 5. Sub-abas Caixa de entrada / Anteriores / Grupos (departamentos + grupos) | Feito |
| 5. Nova conversa com busca, filtros de departamento e nível, Novo grupo | Feito |
| 5. Ferramentas Pedido, Aviso, Reunião, Anexo, Áudio, Chamar, Vídeo, Cliente, Menção | Feito (botão + e cabeçalho; @ abre lista) |
| 5. Áudio em OGG/Opus | **Diferente:** no Android/Chrome grava WebM/Opus; no iPhone o Safari só grava M4A. Java (Chromium) toca os dois. iPhone não toca o OGG do Fiscal. |
| 5. Bolinha flutuante | Não se aplica ao celular |
| 6.1 Canal `tm-u-<id>`, eventos ligar/entrou/recusar/ocupado/sair, 45 s, `chat_chamada` + mensagem de sistema | Igual |
| 6.2 Passe `teams-ligacao-token`, sala = id da conversa, quadro por pessoa, vídeo próprio no canto, tempo, Mudo/Câmera/Tela/Encerrar, encerra quando todos saem | Igual (`livekit_client` do pub.dev) |
| 7. Não fingir Senha/Decisão do CEO | Não existem no app |
| 8. Checklist (mensagem e ligação reais com o Fiscal, grupo com 3, pessoa de fora barrada) | **Falta:** precisa do login real de um CEO e de um aparelho com o app |

## Onde o app fica na VPS (sem aparecer na internet)
- A VPS já roda o LiveKit (público, porque o Java do Fiscal precisa alcançar).
- O app do celular fica na mesma VPS, mas publicado só dentro da rede do Tailscale (`tailscale serve`), com endereço https próprio da rede (`*.ts.net`). Fora da rede o endereço não existe.
- Os celulares dos CEOs entram na rede pelo app do Tailscale; o LiveKit continua no endereço de sempre.
