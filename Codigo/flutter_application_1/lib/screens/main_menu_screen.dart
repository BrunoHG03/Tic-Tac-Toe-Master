// lib/screens/main_menu_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/game_constants.dart';
import '../utils/game_arguments.dart';
import '../services/auth_service.dart';
import '../services/audio_service.dart';
import '../services/historico_service.dart'; // Import para pegar o combo
import 'auth_screen.dart';
import 'difficulty_screen.dart';
import 'game_page.dart';
import 'ranking_screen.dart';
import 'history_screen.dart'; // Import da tela de histórico

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});
  static const routeName = '/';

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _userCombo = 0; // Para mostrar no menu

  @override
  void initState() {
    super.initState();
    AudioService().playMusic();
    _loadUserCombo();
  }

  // Busca o combo para mostrar na tela inicial
  Future<void> _loadUserCombo() async {
    final stats = await HistoricoService().getUserStats();
    if (mounted) {
      setState(() {
        _userCombo = stats['combo'] ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Recarrega o combo toda vez que a tela for reconstruída (ex: voltando do jogo)
    _loadUserCombo();

    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        final bool isLoggedIn = snapshot.hasData && snapshot.data != null;
        final user = snapshot.data;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.music_note, color: Colors.white),
                onPressed: () => AudioService().toggleMusic(),
              ),
              if (isLoggedIn)
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  tooltip: 'Sair',
                  onPressed: () {
                    AuthService().signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Você saiu da conta.')),
                    );
                  },
                )
              else
                TextButton.icon(
                  onPressed: () => Navigator.of(context).pushNamed(AuthScreen.routeName),
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: const Text('Entrar', style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
          body: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6A1B9A), Color(0xFF283593)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'TIC-TAC-TOE',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 28,
                    color: Colors.white,
                    shadows: [const Shadow(color: Colors.black, blurRadius: 10)],
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'MASTER',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    color: Colors.cyanAccent,
                    letterSpacing: 5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),

                if (isLoggedIn)
                  Column(
                    children: [
                      Text(
                        'Olá, ${user?.email?.split('@')[0]}',
                        style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
                      ),
                      // MOSTRAR O COMBO AQUI
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Text(
                          "Combo Atual: ${_userCombo}x 🔥",
                          style: GoogleFonts.poppins(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 20),

                _MenuButton(
                  label: 'CONTRA A MÁQUINA',
                  icon: Icons.computer,
                  color: Colors.cyan,
                  onPressed: () => Navigator.of(context).pushNamed(DifficultyScreen.routeName),
                ),
                
                _MenuButton(
                  label: '2 JOGADORES',
                  icon: Icons.people,
                  color: Colors.purpleAccent,
                  onPressed: () => Navigator.of(context).pushNamed(
                    GamePage.routeName,
                    arguments: GamePageArguments(mode: GameMode.PvP),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botão Menor para Ranking
                    _MiniMenuButton(
                      label: 'Ranking',
                      icon: Icons.emoji_events,
                      color: Colors.amber,
                      onPressed: () => _navigateIfLogged(context, isLoggedIn, const RankingScreen()),
                    ),
                    const SizedBox(width: 15),
                    // Botão Menor para Histórico
                    _MiniMenuButton(
                      label: 'Histórico',
                      icon: Icons.history,
                      color: Colors.greenAccent,
                      onPressed: () => _navigateIfLogged(context, isLoggedIn, const HistoryScreen()),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateIfLogged(BuildContext context, bool logged, Widget page) {
    if (logged) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Login Necessário'),
          content: const Text('Para acessar este recurso, faça login.'),
          actions: [
            TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.pop(ctx)),
            TextButton(child: const Text('Login'), onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pushNamed(AuthScreen.routeName);
            }),
          ],
        ),
      );
    }
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _MenuButton({required this.label, required this.icon, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 40),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 5,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _MiniMenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _MiniMenuButton({required this.label, required this.icon, required this.color, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white.withOpacity(0.1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), 
          side: BorderSide(color: Colors.white.withOpacity(0.3))
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 5),
          Text(label, style: GoogleFonts.poppins(fontSize: 12)),
        ],
      ),
    );
  }
}