import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:js' as js; // Importar solo si estamos en la web

void speakText(String text, String lang) {
  if (kIsWeb) {
    js.context.callMethod('speakText', [text, lang]);
  } else {
    print('La función speakText no está disponible en móviles.');
  }
}

void stopSpeech() {
  if (kIsWeb) {
    js.context.callMethod('stopSpeech');
  } else {
    print('La función stopSpeech no está disponible en móviles.');
  }
}
