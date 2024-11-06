// trivia_game.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:travel_hour/utils/app_colors.dart';

class TriviaGame extends StatefulWidget {
  const TriviaGame({Key? key}) : super(key: key);

  @override
  _TriviaGameState createState() => _TriviaGameState();
}

class _TriviaGameState extends State<TriviaGame> {
  int currentScore = 0;
  int currentQuestionIndex = 0;
  bool hasAnswered = false;
  int? selectedAnswerIndex;
  final int totalQuestions = 10;

  final List<Map<String, dynamic>> questions = [
    {
      'question': easy.tr('question_capital'),
      'options': [
        easy.tr('municipality_montenegro'),
        easy.tr('municipality_armenia'),
        easy.tr('municipality_calarca'),
        easy.tr('municipality_salento')
      ],
      'correctIndex': 1,
      'explanation': easy.tr('explanation_capital'),
    },
    {
      'question': easy.tr('question_ciudad_milagro'),
      'options': [
        easy.tr('municipality_calarca'),
        easy.tr('municipality_montenegro'),
        easy.tr('municipality_armenia'),
        easy.tr('municipality_quimbaya')
      ],
      'correctIndex': 2,
      'explanation': easy.tr('explanation_ciudad_milagro'),
    },
    {
      'question': easy.tr('question_valle_cocora'),
      'options': [
        easy.tr('municipality_salento'),
        easy.tr('municipality_filandia'),
        easy.tr('municipality_circasia'),
        easy.tr('municipality_pijao')
      ],
      'correctIndex': 0,
      'explanation': easy.tr('explanation_valle_cocora'),
    },
    {
      'question': easy.tr('question_smallest'),
      'options': [
        easy.tr('municipality_cordoba'),
        easy.tr('municipality_buenavista'),
        easy.tr('municipality_barcelona'),
        easy.tr('municipality_pijao')
      ],
      'correctIndex': 2,
      'explanation': easy.tr('explanation_smallest'),
    },
    {
      'question': easy.tr('question_balcon'),
      'options': [
        easy.tr('municipality_filandia'),
        easy.tr('municipality_buenavista'),
        easy.tr('municipality_calarca'),
        easy.tr('municipality_circasia')
      ],
      'correctIndex': 1,
      'explanation': easy.tr('explanation_balcon'),
    },
    {
      'question': easy.tr('question_highest'),
      'options': [
        easy.tr('municipality_salento'),
        easy.tr('municipality_genova'),
        easy.tr('municipality_pijao'),
        easy.tr('municipality_filandia')
      ],
      'correctIndex': 0,
      'explanation': easy.tr('explanation_highest'),
    },
    {
      'question': easy.tr('question_bambu'),
      'options': [
        easy.tr('municipality_calarca'),
        easy.tr('municipality_cordoba'),
        easy.tr('municipality_montenegro'),
        easy.tr('municipality_quimbaya')
      ],
      'correctIndex': 0,
      'explanation': easy.tr('explanation_bambu'),
    },
    {
      'question': easy.tr('question_festival'),
      'options': [
        easy.tr('municipality_filandia'),
        easy.tr('municipality_salento'),
        easy.tr('municipality_circasia'),
        easy.tr('municipality_armenia')
      ],
      'correctIndex': 2,
      'explanation': easy.tr('explanation_festival'),
    },
    {
      'question': easy.tr('question_platano'),
      'options': [
        easy.tr('municipality_montenegro'),
        easy.tr('municipality_quimbaya'),
        easy.tr('municipality_pijao'),
        easy.tr('municipality_tebaida')
      ],
      'correctIndex': 0,
      'explanation': easy.tr('explanation_platano'),
    },
    {
      'question': easy.tr('question_ciudad_luz'),
      'options': [
        easy.tr('municipality_calarca'),
        easy.tr('municipality_filandia'),
        easy.tr('municipality_quimbaya'),
        easy.tr('municipality_circasia')
      ],
      'correctIndex': 2,
      'explanation': easy.tr('explanation_ciudad_luz'),
    },
  ];

  void checkAnswer(int selectedIndex) {
    if (hasAnswered) return;

    setState(() {
      hasAnswered = true;
      selectedAnswerIndex = selectedIndex;
      if (selectedIndex == questions[currentQuestionIndex]['correctIndex']) {
        currentScore += 10;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (currentQuestionIndex < totalQuestions - 1) {
        setState(() {
          currentQuestionIndex++;
          hasAnswered = false;
          selectedAnswerIndex = null;
        });
      } else {
        showFinalScore();
      }
    });
  }

  void showFinalScore() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        String messageKey;
        if (currentScore >= 80) {
          messageKey = 'score_excellent';
        } else if (currentScore >= 60) {
          messageKey = 'score_very_good';
        } else if (currentScore >= 40) {
          messageKey = 'score_good';
        } else {
          messageKey = 'score_improve';
        }

        return AlertDialog(
          title: Text(easy.tr('game_over')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('final_score'.tr(args: [currentScore.toString()])),
              const SizedBox(height: 12),
              Text(easy.tr(messageKey)),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(easy.tr('play_again')),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  currentScore = 0;
                  currentQuestionIndex = 0;
                  hasAnswered = false;
                  selectedAnswerIndex = null;
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
    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(easy.tr('trivia_title'), style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF3498DB),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                'points'.tr(args: [currentScore.toString()]),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (currentQuestionIndex + 1) / totalQuestions,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)),
              ),
              const SizedBox(height: 20),
              Text(
                'question_progress'.tr(args: [(currentQuestionIndex + 1).toString(), totalQuestions.toString()]),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    currentQuestion['question'],
                    style: const TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...List.generate(
                currentQuestion['options'].length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getButtonColor(index),
                        padding: const EdgeInsets.all(16),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      onPressed: () => checkAnswer(index),
                      child: Text(
                        currentQuestion['options'][index],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
              if (hasAnswered) ...[
                const SizedBox(height: 20),
                Card(
                  color: const Color(0xFFF0F0F0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      currentQuestion['explanation'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Añadido espacio extra al final
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color getButtonColor(int index) {
    if (!hasAnswered) return const Color.fromARGB(255, 74, 174, 240);
    
    if (index == questions[currentQuestionIndex]['correctIndex']) {
      return CustomColors.primaryColor;
    }
    
    if (index == selectedAnswerIndex && 
        index != questions[currentQuestionIndex]['correctIndex']) {
      return CustomColors.dangerColor;
    }
    
    return const Color.fromARGB(255, 74, 174, 240);
  }
}