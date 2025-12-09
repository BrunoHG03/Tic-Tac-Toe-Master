// lib/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/historico_service.dart';
import '../models/partida.dart';
import '../utils/game_constants.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  static const routeName = '/history';
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoricoService _historicoService = HistoricoService();
  
  int _pontuacaoTotal = 0;
  int _comboAtual = 0;
  bool _isLoading = true;
  List<Partida> _partidas = [];
  
  final DateFormat _formatter = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() { _isLoading = true; });
    final userStats = await _historicoService.getUserStats();
    final listaPartidas = await _historicoService.getHistorico();
    
    if (mounted) {
      setState(() {
        _pontuacaoTotal = userStats['score'] ?? 0;
        _comboAtual = userStats['combo'] ?? 0;
        _partidas = listaPartidas;
        _isLoading = false;
      });
    }
  }

  Future<void> _limparHistorico() async {
    final bool confirmar = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar'),
        content: const Text('Isso vai zerar sua pontuação no Ranking e apagar todo o histórico.'),
        actions: [
          TextButton(child: const Text('Cancelar'), onPressed: () => Navigator.pop(ctx, false)),
          TextButton(child: const Text('Zerar', style: TextStyle(color: Colors.red)), onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    ) ?? false;

    if (confirmar) {
      await _historicoService.limparHistorico();
      _carregarDados();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Meu Histórico', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white70),
            onPressed: _limparHistorico,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF283593), Color(0xFF1A237E)],
          ),
        ),
        child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                const SizedBox(height: 100),
                // Painel de Status
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat("Pontuação", "$_pontuacaoTotal", Colors.cyanAccent),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _buildStat("Combo Atual", "${_comboAtual}x", Colors.orangeAccent),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: _partidas.isEmpty
                    ? Center(child: Text('Sem partidas ainda.', style: GoogleFonts.poppins(color: Colors.white54)))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _partidas.length,
                        itemBuilder: (ctx, index) => _buildItemPartida(_partidas[index]),
                      ),
                ),
              ],
            ),
      ),
    );
  }

  Widget _buildStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
        Text(value, style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildItemPartida(Partida partida) {
    String titulo;
    IconData icone;
    Color cor;

    switch (partida.result) {
      case GameResult.VITORIA:
        titulo = 'Vitória';
        icone = Icons.emoji_events;
        cor = Colors.greenAccent;
        break;
      case GameResult.DERROTA:
        titulo = 'Derrota';
        icone = Icons.cancel;
        cor = Colors.redAccent;
        break;
      case GameResult.EMPATE:
        titulo = 'Empate';
        icone = Icons.handshake;
        cor = Colors.grey;
        break;
    }

    String subtitulo = _formatter.format(partida.data);
    if (partida.difficulty != null) {
      subtitulo += ' • ${partida.difficulty.toString().split('.').last}';
    }

    String pontosStr = '${partida.pontosGanhos}';
    if(partida.pontosGanhos > 0) pontosStr = '+$pontosStr';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.1),
          child: Icon(icone, color: cor),
        ),
        title: Text(titulo, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Text(subtitulo, style: const TextStyle(color: Colors.white54)),
        trailing: Text(
          "$pontosStr pts",
          style: GoogleFonts.poppins(color: cor, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}