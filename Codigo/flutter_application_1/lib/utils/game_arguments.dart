// lib/utils/game_arguments.dart
import 'game_constants.dart';

class GamePageArguments {
  final GameMode mode;
  final Difficulty? difficulty; // Dificuldade é opcional (não precisa para PvP)

  GamePageArguments({
    required this.mode,
    this.difficulty,
  });
}