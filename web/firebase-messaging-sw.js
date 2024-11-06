importScripts(
  "https://www.gstatic.com/firebasejs/9.6.10/firebase-app-compat.js"
);
importScripts(
  "https://www.gstatic.com/firebasejs/9.6.10/firebase-messaging-compat.js"
);

const firebaseConfig = {
  apiKey: "AIzaSyBq_XLGUN8g-0gyQtO2GkDzLHvBEioVhwE",
  authDomain: "conectaquindio-80908.firebaseapp.com",
  projectId: "conectaquindio-80908",
  storageBucket: "conectaquindio-80908.appspot.com",
  messagingSenderId: "74569608969",
  appId: "1:74569608969:web:15677b7a6cd62ae8126dd8",
  measurementId: "G-P99GZ3LF3T",
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

messaging.onBackgroundMessage(function (payload) {
  console.log(
    "[firebase-messaging-sw.js] Received background message ",
    payload
  );
  // Personaliza la notificación aquí
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "./icons/Icon-512.png",
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

// Listener para el evento 'notificationclick' (fuera de onBackgroundMessage)
self.addEventListener("notificationclick", function (event) {
  console.log(event);

  event.notification.close(); // Cierra la notificación

  // Obtiene la URL de la notificación (si está definida)
  const url =
    event.notification.data.url || "https://conecta-quindio.igni-soft.com"; // URL por defecto si no está en la data

  // Abre la URL en una nueva ventana/pestaña
  event.waitUntil(clients.openWindow(url));
});
