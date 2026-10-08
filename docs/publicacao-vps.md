# Publicação do app na VPS (só rede privada) — 07/10/2026

- VPS: 179.197.228.102 (srv1837708), a mesma do LiveKit. Acesso por chave SSH do computador do William.
- Tailscale instalado na VPS (serviço tailscaled, inicia sozinho), nome **bl-ceo**, rede `it-ia.tec.br` (conta admin@it-ia.tec.br).
- App (versão web) em `/opt/bl-ceo-app/web`, publicado com `tailscale serve --bg --https=10443 /opt/bl-ceo-app/web`.
- Endereço (só dentro da rede): **https://bl-ceo.tail679df5.ts.net:10443/** — cadeado válido.
- Portas 443 e 8443 da VPS já são usadas por outros sistemas (acesso.youcontabilidade.com e um serviço node), por isso 10443.
- Prova: de dentro da rede → 200 com cadeado ok; de fora pela internet (IP público:10443) → conexão recusada.

## Atualizar o app
```
flutter build web --release
tar czf blceo-web.tgz -C build/web .
scp -i ~/.ssh/neko_vps_key blceo-web.tgz root@179.197.228.102:/tmp/
ssh -i ~/.ssh/neko_vps_key root@179.197.228.102 'rm -rf /opt/bl-ceo-app/web/* && tar xzf /tmp/blceo-web.tgz -C /opt/bl-ceo-app/web'
```

## Cada CEO (uma vez)
1. Receber convite do Tailscale (console → Usuários → Convidar) e instalar o app Tailscale no celular, entrando com o e-mail convidado.
2. Com o Tailscale ligado, abrir o endereço acima no Safari → Compartilhar → Adicionar à Tela de Início.
3. Entrar com o login da BL (só CEO passa).
