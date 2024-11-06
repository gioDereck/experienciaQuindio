// Archivo: web_speech_handler.dart

import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:js' as js;

class WebSpeechHandler {
  static WebSpeechHandler? _instance;
  bool _isSpeaking = false;
  js.JsObject? _speech;
  Function(bool)? _onStateChanged;
  
  factory WebSpeechHandler() {
    _instance ??= WebSpeechHandler._internal();
    return _instance!;
  }

  WebSpeechHandler._internal() {
    if (kIsWeb) {
      _initializeSpeechSynthesis();
    }
  }

  void _initializeSpeechSynthesis() {
    try {
      // Verificar si la síntesis de voz está disponible
      if (js.context['speechSynthesis'] == null || 
          js.context['SpeechSynthesisUtterance'] == null) {
        print('Speech synthesis no está disponible en este navegador');
        return;
      }

      // Agregar manejadores de eventos globales para la síntesis de voz
      js.context['document'].callMethod('addEventListener', ['speechSynthesisStart', js.allowInterop((_) {
        _updateSpeakingState(true);
      })]);

      js.context['document'].callMethod('addEventListener', ['speechSynthesisEnd', js.allowInterop((_) {
        _updateSpeakingState(false);
      })]);

      // Inicializar el objeto de síntesis
      _resetSpeechObject();
    } catch (e) {
      print('Error al inicializar síntesis de voz: $e');
    }
  }

  void _resetSpeechObject() {
    _speech = js.JsObject(js.context['SpeechSynthesisUtterance']);
    
    // Configurar los manejadores de eventos para el objeto de síntesis
    _speech!['onstart'] = js.allowInterop((_) {
      js.context['document'].callMethod('dispatchEvent', 
        [js.JsObject(js.context['CustomEvent'], ['speechSynthesisStart'])]);
    });

    _speech!['onend'] = js.allowInterop((_) {
      js.context['document'].callMethod('dispatchEvent', 
        [js.JsObject(js.context['CustomEvent'], ['speechSynthesisEnd'])]);
    });

    _speech!['onerror'] = js.allowInterop((error) {
      print('Error en síntesis de voz: $error');
      _updateSpeakingState(false);
    });
  }

  void _updateSpeakingState(bool speaking) {
    if (_isSpeaking != speaking) {
      _isSpeaking = speaking;
      _notifyStateChange();
    }
  }

  void setOnStateChanged(Function(bool) callback) {
    _onStateChanged = callback;
  }

  void _notifyStateChange() {
    _onStateChanged?.call(_isSpeaking);
  }

  bool get isSpeaking => _isSpeaking;

  Future<void> speak(String text, String lang) async {
    if (!kIsWeb) return;

    try {
      // Detener cualquier síntesis en curso
      await stop();
      
      // Reiniciar el objeto de síntesis para evitar problemas de estado
      _resetSpeechObject();

      // Configurar el nuevo texto y lenguaje
      _speech!['text'] = text;
      _speech!['lang'] = lang;
      _speech!['rate'] = 0.9;
      _speech!['pitch'] = 1.0;
      
      // Iniciar la síntesis
      js.context['speechSynthesis'].callMethod('speak', [_speech]);
      
    } catch (e) {
      print('Error al iniciar síntesis de voz: $e');
      _updateSpeakingState(false);
    }
  }

  Future<void> stop() async {
    if (!kIsWeb) return;

    try {
      // Cancelar la síntesis actual
      js.context['speechSynthesis'].callMethod('cancel');
      
      // Forzar la actualización del estado
      _updateSpeakingState(false);
      
      // Pequeña pausa para asegurar que la síntesis se ha detenido
      await Future.delayed(Duration(milliseconds: 100));
    } catch (e) {
      print('Error al detener síntesis de voz: $e');
      _updateSpeakingState(false);
    }
  }

  void dispose() {
    if (kIsWeb) {
      stop();
    }
  }
}