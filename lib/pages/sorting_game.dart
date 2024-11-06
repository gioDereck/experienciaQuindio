import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart' as easy;

class SortingGame extends StatefulWidget {
  const SortingGame({Key? key}) : super(key: key);

  @override
  _SortingGameState createState() => _SortingGameState();
}

class _SortingGameState extends State<SortingGame> {
  late List<String> municipalities;
  late List<String> sortedMunicipalities;
  int moves = 0;
  bool isComplete = false;
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;
  String elapsedTime = '00:00';

  @override
  void initState() {
    super.initState();
    municipalities = [
      "Armenia", "Barcelona", "Buenavista", "Calarcá",
      "Circasia", "Córdoba", "Filandia", "Génova",
      "La Tebaida", "Montenegro", "Pijao", "Quimbaya", "Salento"
    ];
    sortedMunicipalities = List.from(municipalities)..sort();
    municipalities.shuffle(Random());
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    stopwatch.stop();
    super.dispose();
  }

  void startTimer() {
    stopwatch.reset();
    stopwatch.start();
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          final minutes = stopwatch.elapsed.inMinutes;
          final seconds = stopwatch.elapsed.inSeconds % 60;
          elapsedTime = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
        });
      }
    });
  }

  void initializeGame() {
    setState(() {
      municipalities.shuffle(Random());
      moves = 0;
      isComplete = false;
      stopwatch.reset();
      startTimer();
    });
  }

  void checkOrder() {
    bool isSorted = true;
    for (int i = 0; i < municipalities.length; i++) {
      if (municipalities[i] != sortedMunicipalities[i]) {
        isSorted = false;
        break;
      }
    }
    
    if (isSorted && !isComplete) {
      setState(() {
        isComplete = true;
      });
      timer?.cancel();
      stopwatch.stop();
      showCompletionDialog();
    }
  }

  void showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(easy.tr('congratulations')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(easy.tr('sorted_correctly')),
              const SizedBox(height: 8),
              Text('time_spent'.tr(args: [elapsedTime.toString()])),
              const SizedBox(height: 8),
              Text('moves_count'.tr(args: [moves.toString()]))
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(easy.tr('play_again')),
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
        title: Text(easy.tr('sorting_game_title'), style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF9B59B6),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Row(
                children: [
                  const Icon(Icons.timer),
                  const SizedBox(width: 4),
                  Text(
                    elapsedTime,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.swap_vert),
                const SizedBox(width: 8),
                Text(
                  'moves_count'.tr(args: [moves.toString()]),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              easy.tr('drag_instructions'),
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ReorderableListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = municipalities.removeAt(oldIndex);
                  municipalities.insert(newIndex, item);
                  moves++;
                  checkOrder();
                });
              },
              children: municipalities.asMap().entries.map((entry) {
                final index = entry.key;
                final municipality = entry.value;
                final isCorrectPosition = municipality == sortedMunicipalities[index];

                return Card(
                  key: ValueKey(municipality),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: isComplete
                      ? (isCorrectPosition ? Colors.green.shade100 : Colors.red.shade100)
                      : Colors.white,
                  child: ListTile(
                    leading: ReorderableDragStartListener(
                      index: index,
                      child: Icon(
                        Icons.drag_indicator,
                        color: Colors.grey[600],
                      ),
                    ),
                    title: Text(
                      municipality,
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: isComplete
                        ? Icon(
                            isCorrectPosition ? Icons.check_circle : Icons.cancel,
                            color: isCorrectPosition ? Colors.green : Colors.red,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: initializeGame,
        child: const Icon(Icons.refresh),
        backgroundColor: const Color(0xFF9B59B6),
      ),
    );
  }
}