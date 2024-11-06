// word_guess_game.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart' as easy;

class WordGuessGame extends StatefulWidget {
  const WordGuessGame({Key? key}) : super(key: key);

  @override
  _WordGuessGameState createState() => _WordGuessGameState();
}

class _WordGuessGameState extends State<WordGuessGame> {
  
  final List<Map<String, String>> municipalityData = [
    {
      "name": easy.tr('municipality_armenia').toUpperCase(),
      "hint": easy.tr('hint_armenia')
    },
    {
      "name": easy.tr('municipality_barcelona').toUpperCase(),
      "hint": easy.tr('hint_barcelona')
    },
    {
      "name": easy.tr('municipality_buenavista').toUpperCase(),
      "hint": easy.tr('hint_buenavista')
    },
    {
      "name": easy.tr('municipality_calarca').toUpperCase(),
      "hint": easy.tr('hint_calarca')
    },
    {
      "name": easy.tr('municipality_circasia').toUpperCase(),
      "hint": easy.tr('hint_circasia')
    },
    {
      "name": easy.tr('municipality_cordoba').toUpperCase(),
      "hint": easy.tr('hint_cordoba')
    },
    {
      "name": easy.tr('municipality_filandia').toUpperCase(),
      "hint": easy.tr('hint_filandia')
    },
    {
      "name": easy.tr('municipality_genova').toUpperCase(),
      "hint": easy.tr('hint_genova')
    },
    {
      "name": easy.tr('municipality_tebaida').toUpperCase(),
      "hint": easy.tr('hint_tebaida')
    },
    {
      "name": easy.tr('municipality_montenegro').toUpperCase(),
      "hint": easy.tr('hint_montenegro')
    },
    {
      "name": easy.tr('municipality_pijao').toUpperCase(),
      "hint": easy.tr('hint_pijao')
    },
    {
      "name": easy.tr('municipality_quimbaya').toUpperCase(),
      "hint": easy.tr('hint_quimbaya')
    },
    {
      "name": easy.tr('municipality_salento').toUpperCase(),
      "hint": easy.tr('hint_salento')
    },
  ];

  late String currentWord;
  late String currentHint;
  late List<bool> letterRevealed;
  Set<String> guessedLetters = {};
  int remainingAttempts = 6;
  bool gameWon = false;
  bool gameLost = false;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    final randomIndex = Random().nextInt(municipalityData.length);
    currentWord = municipalityData[randomIndex]["name"]!;
    currentHint = municipalityData[randomIndex]["hint"]!;
    letterRevealed = List.generate(currentWord.length, (index) => false);
    guessedLetters = {};
    remainingAttempts = 6;
    gameWon = false;
    gameLost = false;
  }

  void checkLetter(String letter) {
    if (gameWon || gameLost || guessedLetters.contains(letter)) return;
    final Map<String, String> accentMap = {
      'A': 'Á',
      'E': 'É',
      'I': 'Í',
      'O': 'Ó',
      'U': 'Ú',
      'N': 'Ñ'
    };

    setState(() {
      guessedLetters.add(letter);
      bool letterFound = currentWord.contains(letter) || 
        (accentMap.containsKey(letter) && currentWord.contains(accentMap[letter]!));
      
      if (!letterFound) {
        remainingAttempts--;
        if (remainingAttempts <= 0) {
          gameLost = true;
          letterRevealed = List.generate(currentWord.length, (index) => true);
          showGameOverDialog(false);
        }
      } else {
        // Actualizar letras reveladas (tanto para la letra normal como para la acentuada)
        for (int i = 0; i < currentWord.length; i++) {
          if (currentWord[i] == letter || 
              (accentMap.containsKey(letter) && currentWord[i] == accentMap[letter]!)) {
            letterRevealed[i] = true;
          }
        }
        
        // Verificar si ganó
        if (letterRevealed.every((revealed) => revealed)) {
          gameWon = true;
          showGameOverDialog(true);
        }
      }
    });
  }

  void showGameOverDialog(bool won) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(won ? easy.tr('congratulations') : easy.tr('game_over')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(won 
                ? easy.tr('word_guessed_correctly')
                : easy.tr('word_not_guessed')),
              const SizedBox(height: 8),
              Text('word_was'.tr(args: [currentWord])),
              const SizedBox(height: 8),
              Text('attempts_remaining'.tr(args: [remainingAttempts.toString()]))
            ],
          ),
          actions: [
            TextButton(
              child: Text(easy.tr('play_again')),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  initializeGame();
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(easy.tr('word_game_title'), style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 248, 158, 80),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Intentos restantes y pista
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'attempts_remaining'.tr(args: [remainingAttempts.toString()]),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.lightbulb_outline),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(easy.tr('hint_prefix') + currentHint),
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Palabra a adivinar
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap( // Cambiamos Row por Wrap
                  alignment: WrapAlignment.center,
                  spacing: 8, // Espacio horizontal entre elementos
                  runSpacing: 8, // Espacio vertical entre filas
                  children: currentWord.split('').map((letter) {
                    final index = currentWord.indexOf(letter);
                    return Container(
                      width: 30,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                        color: letterRevealed[index] 
                          ? const Color.fromARGB(255, 248, 158, 80) 
                          : Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          letterRevealed[index] ? letter : '',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Teclado
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: 26,
                itemBuilder: (context, index) {
                  final letter = String.fromCharCode(65 + index);
                  final isGuessed = guessedLetters.contains(letter);
                  final isCorrect = currentWord.contains(letter) && isGuessed;
                  
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: isGuessed
                          ? (isCorrect ? Colors.green : Colors.red)
                          : const Color.fromARGB(255, 248, 158, 80),
                    ),
                    onPressed: isGuessed ? null : () => checkLetter(letter),
                    child: Text(
                      letter,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            initializeGame();
          });
        },
        child: const Icon(Icons.refresh),
        backgroundColor: const Color.fromARGB(255, 248, 158, 80),
      ),
    );
  }
}