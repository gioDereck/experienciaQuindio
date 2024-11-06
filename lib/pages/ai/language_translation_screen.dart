import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:translator/translator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:travel_hour/controllers/font_size_controller.dart';
import 'package:get/get.dart';
import 'package:easy_localization/easy_localization.dart' as easy;


class LanguageModel {
  final String countryName;
  final String languageCode;
  final String flag;

  LanguageModel({
    required this.countryName,
    required this.languageCode,
    required this.flag,
  });
}

// Lista de idiomas de ejemplo
List<LanguageModel> dummyLanguages = [
  LanguageModel(countryName: easy.tr('english'), languageCode: 'en', flag: '🇺🇸'),
  LanguageModel(countryName: easy.tr('spanish'), languageCode: 'es', flag: '🇪🇸'),
  LanguageModel(countryName: easy.tr('french'), languageCode: 'fr', flag: '🇫🇷'),
  LanguageModel(countryName: easy.tr('german'), languageCode: 'de', flag: '🇩🇪'),
  LanguageModel(countryName: easy.tr('italian'), languageCode: 'it', flag: '🇮🇹'),
  LanguageModel(countryName: easy.tr('portuguese'), languageCode: 'pt', flag: '🇵🇹'),
];

class LanguageTranslationScreen extends StatefulWidget {
  const LanguageTranslationScreen({Key? key}) : super(key: key);

  @override
  State<LanguageTranslationScreen> createState() =>
      _LanguageTranslationScreenState();
}

class _LanguageTranslationScreenState extends State<LanguageTranslationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController textController = TextEditingController();
  LanguageModel? fromLanguageItem = dummyLanguages[0]; // Inglés
  LanguageModel? toLanguageItem = dummyLanguages[1]; // Español
  String? selectedLanguage = dummyLanguages[0].countryName;
  String? selectedTranslatedLanguage = dummyLanguages[1].countryName;
  String? translatedWords = "";
  late FlutterTts flutterTts;
  late stt.SpeechToText _speech;
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';
  String _instruction = ''; // Instrucción para el usuario

  late AnimationController _animationController;
  late Animation<double> _rippleAnimation;
  Timer? _debounce; // Timer para detectar pausas en la escritura
  int _currentTranslationId = 0; // Identificador de la solicitud de traducción

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _speech = stt.SpeechToText();
    _initializeSpeechToText();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true); // Repite la animación

    _rippleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _debounce?.cancel(); // Cancelar el debounce al eliminar el widget
    super.dispose();
  }

  void _initializeSpeechToText() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening') {
          _stopListening();
        }
      },
      onError: (errorNotification) => print('Error: $errorNotification'),
    );
    if (available) {
      setState(() {
        _speechEnabled = true;
      });
    } else {
      //print('El reconocimiento de voz no está disponible');
    }
  }

  Future<void> _speak(String text, String languageCode) async {
    await flutterTts.setLanguage(languageCode);
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  void swapLanguage() {
    LanguageModel? backupItem = fromLanguageItem;
    fromLanguageItem = toLanguageItem;
    toLanguageItem = backupItem;

    translatedWords = "";
    textController.clear();

    String? backupLanguage = selectedLanguage;
    selectedLanguage = selectedTranslatedLanguage;
    selectedTranslatedLanguage = backupLanguage;
    setState(() {});
  }

  void _startListening() async {
    if (_speechEnabled && !_isListening) {
      setState(() {
        _isListening = true;
        _instruction = easy.tr('speak_now');
        _animationController.forward(); // Iniciar animación ripple
      });

      await _speech.listen(
        onResult: (result) {
          setState(() {
            _lastWords = result.recognizedWords;
            textController.text = _lastWords;
            _translator(_lastWords);
            _instruction = easy.tr('processing');
          });
        },
      );
    }
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
      _instruction = easy.tr('press_the_microphone');
      _animationController.stop(); // Detener animación ripple
    });
  }

  void _translator(String value) {
    if (value.isEmpty) {
      // Cancelar cualquier solicitud de traducción en curso
      _debounce?.cancel();
      setState(() {
        translatedWords = ''; // Limpiar la traducción cuando el texto es vacío
        _instruction = easy.tr('press_the_microphone');
      });
      return;
    }

    // Mostrar el mensaje "Traduciendo..." cuando detectamos una pausa
    setState(() {
      translatedWords = easy.tr('translating');
      _instruction = easy.tr('translating');
    });

    // Configurar un debounce para esperar a que el usuario termine de escribir
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () {
      _currentTranslationId++; // Incrementar el identificador de solicitud
      final int translationId = _currentTranslationId;

      if (fromLanguageItem == null || toLanguageItem == null) {
        //print('Error: Idiomas no seleccionados.');
        setState(() {
          translatedWords = ''; // Limpiar en caso de error
          _instruction = easy.tr('error_translating');
        });
        return;
      }

      final fromLangCode = fromLanguageItem!.languageCode;
      final toLangCode = toLanguageItem!.languageCode;

      if (fromLangCode.isEmpty || toLangCode.isEmpty) {
        print('Error: Códigos de idioma inválidos.');
        setState(() {
          translatedWords = '';
          _instruction = easy.tr('error_translating');
        });
        return;
      }

      final translator = GoogleTranslator();
      translator.translate(value, from: fromLangCode, to: toLangCode).then((s) {
        // Verificar si esta respuesta de traducción es la más reciente
        if (translationId == _currentTranslationId) {
          setState(() {
            translatedWords = s.text;
            _instruction = easy.tr('translation_ready');
          });
        }
      }).catchError((error) {
        // Verificar si esta respuesta de traducción es la más reciente
        if (translationId == _currentTranslationId) {
          setState(() {
            translatedWords = ''; // Limpiar en caso de error
            _instruction = easy.tr('error_translating');
          });
          print('Error en la traducción: $error');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    FontSizeController fontSizeController = Get.find<FontSizeController>();
    TextStyle _textStyleLarge = Theme.of(context).textTheme.bodyLarge!;
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 10,
                  left: 15,
                  child: SafeArea(
                    child: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
                      child: IconButton(
                        icon: Icon(
                          LineIcons.arrowLeft,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'translator',
                    style: _textStyleLarge.copyWith(
                      color: Colors.black,
                      fontWeight: fontSizeController.obtainContrastFromBase(FontWeight.bold),
                    ),
                    textAlign: TextAlign.center,
                  ).tr(),
                ),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedLanguage,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: InputBorder.none,
                          ),
                          icon: Icon(Icons.arrow_drop_down),
                          onChanged: (String? value) {
                            setState(() {
                              selectedLanguage = value;
                              fromLanguageItem = dummyLanguages.firstWhere(
                                  (language) => language.countryName == value);
                              translatedWords =
                                  ''; // Limpiar la traducción al cambiar el idioma
                            });
                          },
                          items: dummyLanguages
                            .map((language) => DropdownMenuItem<String>(
                              value: language.countryName,
                              child: Row(
                                children: [
                                  Text(
                                    language.flag,
                                    style: _textStyleMedium.copyWith(fontFamily: 'NotoColorEmoji'),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    language.countryName,
                                    style: _textStyleMedium,
                                  ),
                                ],
                              ),
                            ))
                            .toList(),
                        ),
                      ),
                    ),
                    SizedBox(width: 1),
                    Container(
                      child: IconButton(
                        onPressed: swapLanguage,
                        icon: Icon(Icons.swap_horiz, size: 24),
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 1),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedTranslatedLanguage,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: InputBorder.none,
                          ),
                          icon: Icon(Icons.arrow_drop_down),
                          onChanged: (String? value) {
                            setState(() {
                              selectedTranslatedLanguage = value;
                              toLanguageItem = dummyLanguages.firstWhere(
                                  (language) => language.countryName == value);
                              translatedWords =
                                  ''; // Limpiar la traducción al cambiar el idioma
                            });
                          },
                          items: dummyLanguages
                            .map((language) => DropdownMenuItem<String>(
                              value: language.countryName,
                              child: Row(
                                children: [
                                  Text(
                                    language.flag,
                                    style: _textStyleMedium.copyWith(fontFamily: 'NotoColorEmoji'),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    language.countryName,
                                    style: _textStyleMedium,
                                  ),
                                ],
                              ),
                            ))
                            .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  height: screenHeight * 0.6,
                  child: Column(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 2,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: TextField(
                                    controller: textController,
                                    onChanged: (text) {
                                      _translator(text);
                                    },
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: easy.tr('enter_text_or_use_microphone'),
                                    ),
                                    maxLines: null,
                                    expands: true,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: IconButton(
                                    icon: Icon(Icons.volume_up),
                                    onPressed: () {
                                      _speak(textController.text,
                                          fromLanguageItem!.languageCode);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Card(
                          elevation: 2,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Stack(
                              children: [
                                Align(
                                  alignment: Alignment.topLeft,
                                  child: SingleChildScrollView(
                                    child: Text(
                                      translatedWords!.isNotEmpty
                                          ? translatedWords!
                                          : "",
                                      style: _textStyleLarge,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: IconButton(
                                    icon: Icon(Icons.volume_up),
                                    onPressed: () {
                                      _speak(translatedWords ?? '',
                                          toLanguageItem!.languageCode);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              _instruction,
              style: _textStyleMedium.copyWith(fontWeight: fontSizeController.obtainContrastFromBase(FontWeight.bold)),
            ),
            SizedBox(height: 10),
            ScaleTransition(
              scale:
                  _isListening ? _rippleAnimation : AlwaysStoppedAnimation(1.0),
              child: FloatingActionButton(
                onPressed: _isListening ? _stopListening : _startListening,
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 36,
                  color: Colors.white,
                ),
                backgroundColor: _isListening ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
