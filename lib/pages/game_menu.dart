import 'package:flutter/material.dart';
import 'package:travel_hour/pages/memory_game.dart';
import 'package:travel_hour/pages/sorting_game.dart';
import 'package:travel_hour/pages/trivia_game.dart';
import 'package:travel_hour/pages/word_guess_game.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:travel_hour/widgets/contact_buttons.dart';

class GamesMenuScreen extends StatelessWidget {
  const GamesMenuScreen({Key? key}) : super(key: key);

  final List<GameOption> games = const [
    GameOption(
      title: 'game_memory_title',
      description: 'game_memory_desc',
      icon: Icons.grid_on,
      color: Color(0xFF2ECC71),
      game: MemoryGame(),
    ),
    GameOption(
      title: 'game_trivia_title',
      description: 'game_trivia_desc',
      icon: Icons.quiz,
      color: Color(0xFF3498DB),
      game: TriviaGame(),
    ),
    GameOption(
      title: 'game_sorting_title',
      description: 'game_sorting_desc',
      icon: Icons.sort,
      color: Color(0xFF9B59B6),
      game: SortingGame(),
    ),
    GameOption(
      title: 'game_word_title',
      description: 'game_word_desc',
      icon: Icons.help_outline,
      color: Color(0xFFE67E22),
      game: WordGuessGame(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(easy.tr('games_menu_title')),
        backgroundColor: Colors.white,
      ),
      floatingActionButton: ContactButtons(
        withoutAssistant: false,
        uniqueId: 'gamePage',
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              childAspectRatio: constraints.maxWidth > 600 ? 1.5 : 1.0,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: games.length,
            itemBuilder: (context, index) => GameCard(gameOption: games[index]),
          );
        },
      ),
    );
  }
}

class GameOption {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget game;

  const GameOption({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.game,
  });
}

class GameCard extends StatelessWidget {
  final GameOption gameOption;

  const GameCard({Key? key, required this.gameOption}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => gameOption.game),
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    gameOption.icon,
                    size: constraints.maxWidth * 0.2,
                    color: gameOption.color,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    easy.tr(gameOption.title),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      easy.tr(gameOption.description),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
