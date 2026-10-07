# Inventário do TEAM's — base para o app Mobile BL (07/10/2026)

## Fato importante
- O TEAM's do **Java CEO** (painel.html) ainda grava no **banco central da BL** (`wfqcoocfastgsfgegpcm`), direto nas tabelas `chat_*`, sem RPC e sem Realtime. Várias funções são DEMO (chamada, anexo, áudio, senha, recibos de leitura).
- O TEAM's **completo e real** está no **Java do Fiscal**, no banco próprio do TEAM's (`lhqjfdexfexpmnoqhbyv`): `YOU-JAVA's\IT.FISC\Fisc\app\src\main\resources\static\index.html`, doc `Fisc\docs\teams-2026-10-07.md`, SQL `Fisc\supabase\teams\`.
- Para o celular e o Java CEO refletirem um no outro, os dois têm que usar o **mesmo banco do TEAM's**. Pendência: repontar o TEAM's do Java CEO para `lhqjfdexfexpmnoqhbyv` (tarefa do Agent BL).

## Funcionalidades (o app segue a versão completa, banco do TEAM's)
1. **Entrada:** login na BL (só CEO) → edge `teams-entrar` dá o selo de interno → `chat_presenca` online/offline.
2. **Abas:** Conversas / Avisos / Pedidos / Reuniões, com contadores (`chat_pendencias`, `chat_marcar_visto`).
3. **Conversas:** sub-abas Caixa de entrada / Anteriores / Grupos; busca; não lidas (`chat_resumo`, `chat_marcar_lido`); "+ Nova conversa" com filtros de departamento e nível (`chat_abrir_direta`, `chat_abrir_setor`, `chat_criar_grupo` + `chat_canal_membro`); silenciar (`chat_canal_membro.silenciado`).
4. **Conversa:** mensagens (`chat_mensagem`), responder, copiar, editar (só autor), apagar para todos, criar pedido a partir da mensagem, menções @ (`chat_mencao`), cliente citado (só ID; nome via API), recibos.
5. **Anexos:** documento e fotos no bucket privado `chat-anexo` + `chat_anexo`; áudio gravado (com transcrição).
6. **Chamadas:** voz e vídeo WebRTC (sinal via Realtime `tm-u-<id>`), registro em `chat_chamada` e `chat_chamada_participante`; atender, recusar, mudo, câmera, compartilhar tela. Sem TURN ainda.
7. **Avisos:** `chat_aviso` com nível Informativo / Exige visto / Urgente do CEO; dar visto (`chat_aviso_visto`).
8. **Pedidos:** `chat_pedido` com status Aberto / Em andamento / Concluído / Cancelado; filtros Para mim / Que eu pedi / Todos.
9. **Reuniões:** `chat_reuniao` com início e fim + `chat_reuniao_participante` (convidar, confirmar).
10. **Status:** Online / Em reunião / Ausente / Não me interrompam / Offline.
11. **Só do CEO (hoje DEMO/parcial no Java):** Registrar decisão do CEO (`chat_decisao_ceo`) e Senha do cofre — precisam de definição antes de virar real.
12. **Realtime:** mensagens, presença, pedidos, avisos, membros e recibos chegam sozinhos (push, sem polling).
