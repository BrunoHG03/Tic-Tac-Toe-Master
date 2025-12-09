// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Imports das telas
import 'screens/auth_screen.dart';
import 'screens/auth_gate.dart';
import 'screens/main_menu_screen.dart';
import 'screens/difficulty_screen.dart';
import 'screens/game_page.dart';
import 'screens/history_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jogo da Velha com IA',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,

      // AQUI DEFINIMOS O INÍCIO
      home: const MainMenuScreen(),

      // LISTA DE ROTAS
      routes: {
        AuthScreen.routeName: (ctx) => const AuthScreen(),
        '/auth-gate': (ctx) => const AuthGate(),
        
        // --- REMOVA ESTA LINHA ABAIXO (MainMenuScreen) ---
        // MainMenuScreen.routeName: (ctx) => const MainMenuScreen(), 
        // --------------------------------------------------

        DifficultyScreen.routeName: (ctx) => const DifficultyScreen(),
        GamePage.routeName: (ctx) => const GamePage(),
        HistoryScreen.routeName: (ctx) => const HistoryScreen(),
      },
    );
  }
}