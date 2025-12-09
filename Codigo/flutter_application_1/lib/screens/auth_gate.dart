// lib/screens/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_menu_screen.dart';
import 'auth_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      // "Ouve" o stream de mudanças de login/logout do Firebase
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Se ainda está checando, mostra um loader
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Se o snapshot tem dados (User), o usuário está logado
        if (snapshot.hasData) {
          return const MainMenuScreen();
        }

        // Se não tem dados, o usuário não está logado
        return const AuthScreen();
      },
    );
  }
}