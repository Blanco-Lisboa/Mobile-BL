# Prova — TEAM's no app (07/10/2026)

- `flutter analyze`: No issues found.
- `flutter test`: 16 testes, todos passaram — inclui: entrar no TEAM's grava "online"; lista conversas com não lidas; abrir conversa e enviar com @menção (grava chat_mencao do mencionado); avisos "Dar visto" grava chat_aviso_visto; pedidos "Para mim"; chamada recebida → Recusar envia sinal "recusar" a quem ligou; segunda ligação durante outra responde "ocupado".
- Banco real do TEAM's (lhqjfdexfexpmnoqhbyv): as consultas do app (mensagens com anexos, reuniões com participantes, pedidos, avisos, vistos, presença) responderam 200 — nomes de colunas e ligações corretos.
- Banco BL central: o CEO logado tem leitura em usuarios_internos, usuario_setores, setores e empresa (políticas is_interno conferidas).
- `flutter build web --release`: OK; servido em http://localhost:8090.
- Protocolo de ligação igual ao do Java do Fiscal (canal privado tm-u-<id>, eventos ligar/entrou/recusar/ocupado/sair, LiveKit via teams-ligacao-token; edge responde, LiveKit configurado).

## Não testado (precisa de login real de CEO e de um segundo aparelho)
- Conversa real ida e volta com alguém do Fiscal; anexos e áudio reais; ligação real entre dois aparelhos.
- O TEAM's do Java CEO ainda usa o banco central: o que o CEO manda pelo Java não aparece no app até o Agent BL repontar.
- Áudio gravado no Fiscal é .ogg: o iPhone (Safari) não toca .ogg. Áudios gravados pelo app no iPhone saem em .m4a.
