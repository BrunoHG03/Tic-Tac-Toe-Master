// lib/screens/difficulty_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/game_constants.dart';
import '../utils/game_arguments.dart';

class DifficultyScreen extends StatelessWidget {
  const DifficultyScreen({super.key});
  static const routeName = '/difficulty';

  void _navigateToGame(BuildContext context, Difficulty difficulty) {
    Navigator.of(context).pushNamed(
      '/game',
      arguments: GamePageArguments(
        mode: GameMode.PvE,
        difficulty: difficulty,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Escolha a Dificuldade', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6A1B9A), Color(0xFF283593)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                _DifficultyButton(
                  label: 'Muito Fácil (20%)',
                  color: Colors.greenAccent,
                  onPressed: () => _navigateToGame(context, Difficulty.muitoFacil),
                ),
                _DifficultyButton(
                  label: 'Fácil (40%)',
                  color: Colors.green,
                  onPressed: () => _navigateToGame(context, Difficulty.facil),
                ),
                _DifficultyButton(
                  label: 'Médio (60%)',
                  color: Colors.yellow,
                  onPressed: () => _navigateToGame(context, Difficulty.medio),
                ),
                _DifficultyButton(
                  label: 'Difícil (80%)',
                  color: Colors.orange,
                  onPressed: () => _navigateToGame(context, Difficulty.dificil),
                ),
                _DifficultyButton(
                  label: 'Muito Difícil (90%)',
                  color: Colors.deepOrange,
                  onPressed: () => _navigateToGame(context, Difficulty.muitoDificil),
                ),
                _DifficultyButton(
                  label: 'Impossível (100%)',
                  color: Colors.red,
                  isImpossivel: true,
                  onPressed: () => _navigateToGame(context, Difficulty.impossivel),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color color;
  final bool isImpossivel;

  const _DifficultyButton({
    required this.label,
    required this.onPressed,
    required this.color,
    this.isImpossivel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: isImpossivel ? const BorderSide(color: Colors.red, width: 2) : BorderSide.none,
          ),
          elevation: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isImpossivel ? Colors.red : Colors.black87,
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color),
          ],
        ),
      ),
    );
  }
}