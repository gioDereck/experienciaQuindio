import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:easy_localization/easy_localization.dart' as easy;

class MemoryGame extends StatefulWidget {
  const MemoryGame({Key? key}) : super(key: key);

  @override
  _MemoryGameState createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  final List<String> municipalities = [
    'municipality_armenia'.tr(),
    'municipality_barcelona'.tr(),
    'municipality_buenavista'.tr(),
    'municipality_calarca'.tr(),
    'municipality_circasia'.tr(),
    'municipality_cordoba'.tr(),
    'municipality_filandia'.tr(),
    'municipality_genova'.tr(),
    'municipality_tebaida'.tr(),
    'municipality_montenegro'.tr(),
    'municipality_pijao'.tr(),
    'municipality_quimbaya'.tr(),
    'municipality_salento'.tr()
  ];
  
  late List<String> gameCards;
  List<bool> cardFlips = [];
  List<int> selectedCards = [];
  int pairs = 0;
  bool canFlip = true;
  int moves = 0;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    List<String> selectedMunicipalities = [];
    List<String> tempMunicipalities = List.from(municipalities);
    Random random = Random();
    
    for (int i = 0; i < 6; i++) {
      int index = random.nextInt(tempMunicipalities.length);
      selectedMunicipalities.add(tempMunicipalities[index]);
      tempMunicipalities.removeAt(index);
    }
    
    setState(() {
      gameCards = [...selectedMunicipalities, ...selectedMunicipalities];
      gameCards.shuffle();
      cardFlips = List.generate(12, (index) => false);
      selectedCards = [];
      pairs = 0;
      moves = 0;
    });
  }

  void onCardTap(int index) {
    if (!canFlip || cardFlips[index] || selectedCards.contains(index)) return;

    setState(() {
      cardFlips[index] = true;
      selectedCards.add(index);
      moves++;

      if (selectedCards.length == 2) {
        canFlip = false;
        if (gameCards[selectedCards[0]] == gameCards[selectedCards[1]]) {
          pairs++;
          selectedCards.clear();
          canFlip = true;
          
          if (pairs == 6) {
            showWinDialog();
          }
        } else {
          Timer(const Duration(milliseconds: 1000), () {
            if (mounted) {
              setState(() {
                cardFlips[selectedCards[0]] = false;
                cardFlips[selectedCards[1]] = false;
                selectedCards.clear();
                canFlip = true;
              });
            }
          });
        }
      }
    });
  }

  void showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('congratulations'.tr()),
          content: Text('game_completed'.tr(args: [moves.toString()])),
          actions: <Widget>[
            TextButton(
              child: Text('play_again'.tr()),
              onPressed: () {
                Navigator.of(context).pop();
                initializeGame();
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
        title: Text('memory_game_title'.tr(), style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF2ECC71),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'moves_count'.tr(args: [moves.toString()]),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: gameCards.length,
              itemBuilder: (context, index) {
                return Card(
                  elevation: 4,
                  child: InkWell(
                    onTap: () => onCardTap(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      decoration: BoxDecoration(
                        color: cardFlips[index] ? const Color(0xFF2ECC71) : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: cardFlips[index]
                            ? Text(
                                gameCards[index],
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : const Icon(Icons.help_outline),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: initializeGame,
        child: const Icon(Icons.refresh),
        backgroundColor: const Color(0xFF2ECC71),
      ),
    );
  }
}