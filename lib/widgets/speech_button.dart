import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:travel_hour/utils/web_speech_handler.dart';
import 'package:easy_localization/easy_localization.dart';

class SpeechButton extends StatefulWidget {
  final String? text;
  final String defaultLanguage;
  final double speechRate;
  final double pitch;
  
  const SpeechButton({
    Key? key,
    required this.text,
    this.defaultLanguage = 'es-ES',
    this.speechRate = 0.5,
    this.pitch = 1.0,
  }) : super(key: key);

  @override
  State<SpeechButton> createState() => _SpeechButtonState();
}

class _SpeechButtonState extends State<SpeechButton> {
  late FlutterTts flutterTts;
  late WebSpeechHandler _speechHandler;
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _speechHandler = WebSpeechHandler();
    _initializeTts();
    
    _speechHandler.setOnStateChanged((bool speaking) {
      setState(() {
        isSpeaking = speaking;
      });
    });
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage(widget.defaultLanguage);
    await flutterTts.setSpeechRate(widget.speechRate);
    await flutterTts.setPitch(widget.pitch);

    flutterTts.setStartHandler(() {
      setState(() => isSpeaking = true);
    });

    flutterTts.setCompletionHandler(() {
      setState(() => isSpeaking = false);
    });

    flutterTts.setCancelHandler(() {
      setState(() => isSpeaking = false);
    });

    flutterTts.setErrorHandler((msg) {
      debugPrint('Error en TTS: $msg');
      setState(() => isSpeaking = false);
    });
  }

  Future<void> speakDescription() async {
    if (widget.text != null && widget.text!.isNotEmpty) {
      if (kIsWeb) {
        _speechHandler.speak(widget.text!, widget.defaultLanguage);
      } else {
        await flutterTts.setLanguage(widget.defaultLanguage);
        await flutterTts.setSpeechRate(widget.speechRate);
        await flutterTts.setPitch(widget.pitch);
        await flutterTts.speak(widget.text!);
      }

      setState(() => isSpeaking = true);
    }
  }

  Future<void> stopSpeaking() async {
    if (kIsWeb) {
      _speechHandler.stop();
    } else {
      await flutterTts.stop();
    }
    setState(() => isSpeaking = false);
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              if (isSpeaking) {
                stopSpeaking();
              } else {
                speakDescription();
              }
            },
            icon: Icon(isSpeaking ? Icons.stop : Icons.play_arrow),
            label: Text(isSpeaking ? 'stop' : 'listen', style: _textStyleMedium.copyWith(color: Colors.white)).tr(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}