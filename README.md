# travel_hour

# Comando para actualizar icono de la app

- flutter pub run flutter_launcher_icons:main

# Comando para habilitar Web en app Movil

- flutter config --enable-web
- flutter create -t .

# Comando para correr PWA en servidor local

- flutter run -d chrome --web-renderer html --release
- flutter run -d chrome --web-browser-flag "--disable-web-security"

# Comando para construir PWA

- flutter clean
- flutter pub get
- flutter build web --web-renderer html --no-tree-shake-icons --release

# Comando para correr App en dispositivo

- flutter clean
- flutter pub get
- flutter run

# Para generar estas huellas digitales, usa el siguiente comando en la terminal (asegúrate de tener Java instalado):

keytool -list -v -keystore "C:\Users\<tu_usuario>\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
Alias name: androiddebugkey
Creation date: Oct 19, 2023
Entry type: PrivateKeyEntry
Certificate chain length: 1
Certificate[1]:
Owner: C=US, O=Android, CN=Android Debug
Issuer: C=US, O=Android, CN=Android Debug
Serial number: 1
Valid from: Thu Oct 19 12:39:01 COT 2023 until: Sat Oct 11 12:39:01 COT 2053
Certificate fingerprints:
SHA1: 94:B7:EA:00:41:58:60:AA:81:88:31:FC:D4:13:E7:E2:C5:08:D1:19
SHA256: D6:29:90:F3:41:30:06:14:8B:DB:AB:20:C5:9E:71:F4:3C:DC:30:56:CA:C2:E6:6B:AE:E9:35:16:B7:52:B2:A4
Signature algorithm name: SHA1withRSA (weak)
Subject Public Key Algorithm: 2048-bit RSA key
Version: 1

Warning:
The certificate uses the SHA1withRSA signature algorithm which is considered a security risk. This algorithm will be disabled in a future update.

# Claves SHA1 de keystore debug.keystore

keytool -list -v -alias connetquin -keystore "F:\AplicacionesMobiles\travel_hour\android\app\debug.keystore"
Enter keystore password: conectaQuindio2024

Alias name: connetquin
Creation date: Sep 26, 2024
Entry type: PrivateKeyEntry
Certificate chain length: 1
Certificate[1]:
Owner: CN=connect, OU=quindio, O=connectQuindio, L=Armenia, ST=Quindio, C=CO
Issuer: CN=connect, OU=quindio, O=connectQuindio, L=Armenia, ST=Quindio, C=CO
Serial number: 2fd9788d36889b98
Valid from: Thu Sep 26 18:04:11 COT 2024 until: Mon Feb 12 18:04:11 COT 2052
Certificate fingerprints:
SHA1: 54:24:C2:C3:4E:E7:C2:D3:87:BA:11:C4:D2:C4:8A:A6:F2:EA:BF:46
SHA256: 4E:85:09:2A:F3:9D:4C:48:97:D7:58:89:54:AA:39:EF:BA:89:C4:AC:42:CB:E4:CC:E3:B5:71:6A:04:F8:86:72
Signature algorithm name: SHA256withRSA
Subject Public Key Algorithm: 2048-bit RSA key
Version: 3

A new Flutter application.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# travel_hour
