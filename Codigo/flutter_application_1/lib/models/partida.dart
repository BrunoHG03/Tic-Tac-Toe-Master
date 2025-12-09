// lib/models/partida.dart
import 'dart:convert';
import '../utils/game_constants.dart';

class Partida {
  final GameMode mode;
  final GameResult result;
  final Difficulty? difficulty;
  final int pontosGanhos;
  final DateTime data; // Para saber QUANDO foi jogada

  Partida({
    required this.mode,
    required this.result,
    this.difficulty,
    required this.pontosGanhos,
    required this.data,
  });

  // --- Métodos de Serialização ---
  // Transforma o objeto Partida em um Map (para virar JSON)
  Map<String, dynamic> toMap() {
    return {
      'mode': mode.name, // Salva "PvE" ou "PvP"
      'result': result.name, // Salva "VITORIA", "DERROTA", "EMPATE"
      'difficulty': difficulty?.name, // Salva a dificuldade ou null
      'pontosGanhos': pontosGanhos,
      'data': data.toIso8601String(), // Salva a data como texto
    };
  }

  // Transforma um Map (vindo do JSON) em um objeto Partida
  factory Partida.fromMap(Map<String, dynamic> map) {
    return Partida(
      mode: GameMode.values.firstWhere((e) => e.name == map['mode']),
      result: GameResult.values.firstWhere((e) => e.name == map['result']),
      difficulty: map['difficulty'] != null
          ? Difficulty.values.firstWhere((e) => e.name == map['difficulty'])
          : null,
      pontosGanhos: map['pontosGanhos'],
      data: DateTime.parse(map['data']),
    );
  }

  // Atalhos para facilitar salvar e ler do SharedPreferences
  String toJson() => json.encode(toMap());
  factory Partida.fromJson(String source) => Partida.fromMap(json.decode(source));
}