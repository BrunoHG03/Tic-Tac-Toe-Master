// lib/utils/game_constants.dart
import 'dart:math';

enum GameMode { PvE, PvP }

enum Difficulty {
  muitoFacil,
  facil,
  medio,
  dificil,
  muitoDificil,
  impossivel
}

enum GameStatus { EM_ANDAMENTO, FINALIZADO }

enum GameResult { VITORIA, DERROTA, EMPATE }

extension DifficultyProps on Difficulty {
  // Chance da IA jogar certo (Sua lógica original)
  int get chance {
    switch (this) {
      case Difficulty.muitoFacil: return 20;
      case Difficulty.facil: return 40;
      case Difficulty.medio: return 60;
      case Difficulty.dificil: return 80;
      case Difficulty.muitoDificil: return 90;
      case Difficulty.impossivel: return 100;
    }
  }

  // NOVO: Pontos base por vitória
  int get basePoints {
    switch (this) {
      case Difficulty.muitoFacil: return 10;
      case Difficulty.facil: return 20;
      case Difficulty.medio: return 30;
      case Difficulty.dificil: return 40;
      case Difficulty.muitoDificil: return 50;
      case Difficulty.impossivel: return 60;
    }
  }

  bool deveJogarCerto() {
    if (this == Difficulty.impossivel) return true;
    int rolagem = Random().nextInt(100); 
    return rolagem < chance;
  }
}