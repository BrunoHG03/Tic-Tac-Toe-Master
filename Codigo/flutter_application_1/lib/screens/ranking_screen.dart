// lib/screens/ranking_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Fonte bonita
import '../services/historico_service.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});
  static const routeName = '/ranking';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Ranking Global', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple, Colors.black87],
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: HistoricoService().getGlobalRanking(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Ninguém jogou ainda!", style: TextStyle(color: Colors.white)));
            }

            final players = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                final score = player['score'] ?? 0;
                final name = player['name'] ?? 'Desconhecido';
                final combo = player['combo'] ?? 0;

                // Destaque para os top 3
                Color cardColor = Colors.white.withOpacity(0.1);
                IconData trophyIcon = Icons.person;
                Color iconColor = Colors.white70;

                if (index == 0) {
                  trophyIcon = Icons.emoji_events;
                  iconColor = Colors.amber; // Ouro
                  cardColor = Colors.amber.withOpacity(0.2);
                } else if (index == 1) {
                  trophyIcon = Icons.emoji_events;
                  iconColor = Colors.grey.shade300; // Prata
                } else if (index == 2) {
                  trophyIcon = Icons.emoji_events;
                  iconColor = Colors.brown.shade300; // Bronze
                }

                return Card(
                  color: cardColor,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: Icon(trophyIcon, color: iconColor),
                    ),
                    title: Text(
                      '#${index + 1} $name',
                      style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Combo Atual: ${combo}x',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    trailing: Text(
                      '$score pts',
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}