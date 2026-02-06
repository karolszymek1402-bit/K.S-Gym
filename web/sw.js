// Service Worker dla K.S-Gym - obsługa powiadomień w tle
const CACHE_NAME = 'ks-gym-cache-v1';

// Instalacja Service Worker
self.addEventListener('install', (event) => {
  console.log('🔔 Service Worker installing...');
  self.skipWaiting();
});

// Aktywacja Service Worker
self.addEventListener('activate', (event) => {
  console.log('🔔 Service Worker activated');
  event.waitUntil(clients.claim());
});

// Globalny obiekt do przechowywania zaplanowanych timerów
const scheduledNotifications = new Map();

// Odbieranie wiadomości z aplikacji Flutter
self.addEventListener('message', (event) => {
  console.log('🔔 SW received message:', event.data);
  
  if (event.data && event.data.type === 'SCHEDULE_NOTIFICATION') {
    const { id, title, body, delayMs } = event.data;
    scheduleNotification(id, title, body, delayMs);
  }
  
  if (event.data && event.data.type === 'CANCEL_NOTIFICATION') {
    const { id } = event.data;
    cancelScheduledNotification(id);
  }
  
  if (event.data && event.data.type === 'CANCEL_ALL_NOTIFICATIONS') {
    cancelAllScheduledNotifications();
  }
});

// Planowanie powiadomienia
function scheduleNotification(id, title, body, delayMs) {
  console.log(`🔔 Scheduling notification ${id} in ${delayMs}ms`);
  
  // Anuluj poprzedni timer jeśli istnieje
  if (scheduledNotifications.has(id)) {
    clearTimeout(scheduledNotifications.get(id));
  }
  
  // Ustaw nowy timer
  const timerId = setTimeout(() => {
    showNotification(title, body);
    scheduledNotifications.delete(id);
  }, delayMs);
  
  scheduledNotifications.set(id, timerId);
  console.log(`🔔 Notification ${id} scheduled successfully`);
}

// Anulowanie zaplanowanego powiadomienia
function cancelScheduledNotification(id) {
  console.log(`🔔 Canceling notification ${id}`);
  if (scheduledNotifications.has(id)) {
    clearTimeout(scheduledNotifications.get(id));
    scheduledNotifications.delete(id);
    console.log(`🔔 Notification ${id} canceled`);
  }
}

// Anulowanie wszystkich zaplanowanych powiadomień
function cancelAllScheduledNotifications() {
  console.log('🔔 Canceling all notifications');
  for (const [id, timerId] of scheduledNotifications) {
    clearTimeout(timerId);
  }
  scheduledNotifications.clear();
}

// Pokazanie powiadomienia
function showNotification(title, body) {
  console.log(`🔔 Showing notification: ${title}`);
  
  const options = {
    body: body,
    icon: 'icons/Icon-192.png',
    badge: 'icons/Icon-192.png',
    tag: 'rest-timer-' + Date.now(),
    requireInteraction: true,
    renotify: true,
    silent: false,
    vibrate: [200, 100, 200, 100, 200, 100, 200],
    actions: [
      { action: 'open', title: 'Otwórz' }
    ]
  };
  
  self.registration.showNotification(title, options)
    .then(() => console.log('🔔 Notification shown successfully'))
    .catch(err => console.log('🔔 Notification error:', err));
}

// Obsługa kliknięcia w powiadomienie
self.addEventListener('notificationclick', (event) => {
  console.log('🔔 Notification clicked');
  event.notification.close();
  
  // Otwórz aplikację lub przełącz na nią
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true })
      .then((clientList) => {
        // Jeśli jest otwarte okno, przełącz na nie
        for (const client of clientList) {
          if ('focus' in client) {
            return client.focus();
          }
        }
        // Jeśli nie ma otwartego okna, otwórz nowe
        if (clients.openWindow) {
          return clients.openWindow('/');
        }
      })
  );
});

// Fetch event - cache strategy
self.addEventListener('fetch', (event) => {
  // Nie cachuj requestów - prosta strategia
  event.respondWith(fetch(event.request));
});

console.log('🔔 K.S-Gym Service Worker loaded');
