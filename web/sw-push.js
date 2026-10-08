self.addEventListener('install', () => self.skipWaiting());
self.addEventListener('activate', (e) => e.waitUntil(self.clients.claim()));

self.addEventListener('push', (event) => {
  let d = {};
  try { d = event.data ? event.data.json() : {}; } catch (_) { d = { titulo: 'BL CEO', corpo: event.data ? event.data.text() : '' }; }
  const titulo = d.titulo || 'BL CEO';
  const opcoes = {
    body: d.corpo || '',
    tag: d.tag || undefined,
    renotify: true,
    icon: 'icons/Icon-192.png',
    badge: 'icons/Icon-192.png',
    data: { url: d.url || './', tipo: d.tipo || '' },
    requireInteraction: d.tipo === 'chamada',
  };
  event.waitUntil((async () => {
    if (typeof d.contador === 'number' && self.navigator && self.navigator.setAppBadge) {
      try { d.contador > 0 ? await self.navigator.setAppBadge(d.contador) : await self.navigator.clearAppBadge(); } catch (_) {}
    }
    await self.registration.showNotification(titulo, opcoes);
  })());
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const url = new URL((event.notification.data && event.notification.data.url) || './', self.registration.scope).href;
  event.waitUntil((async () => {
    const lista = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
    for (const c of lista) {
      try {
        await c.focus();
        c.postMessage({ blAbrir: url });
        return;
      } catch (_) {}
    }
    await self.clients.openWindow(url);
  })());
});

self.addEventListener('message', (event) => {
  const m = event.data || {};
  event.waitUntil((async () => {
    if (m.fecharTag) {
      const ns = await self.registration.getNotifications({ tag: m.fecharTag });
      ns.forEach((n) => n.close());
    }
    if (m.fecharTudo) {
      const ns = await self.registration.getNotifications();
      ns.forEach((n) => n.close());
    }
    if (typeof m.contador === 'number' && self.navigator && self.navigator.setAppBadge) {
      try { m.contador > 0 ? await self.navigator.setAppBadge(m.contador) : await self.navigator.clearAppBadge(); } catch (_) {}
    }
  })());
});
