// lib/screens/game_page.dart
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart'; // Fonte
import '../utils/game_constants.dart';
import '../utils/game_arguments.dart';
import '../services/historico_service.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  static const routeName = '/game';

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<String> board = List.filled(9, ' ');
  final String player = 'X'; 
  final String computer = 'O'; 
  bool gameEnded = false;
  String gameMessage = '';
  late GameMode _mode;
  Difficulty? _difficulty;
  String _currentPlayer = 'X'; 
  bool _isComputerTurn = false;
  
  // Variáveis para mostrar info na tela (Combo/Pontos)
  int _currentScore = 0;
  int _currentCombo = 0;

  final HistoricoService _historicoService = HistoricoService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as GamePageArguments;
    _mode = args.mode;
    _difficulty = args.difficulty;
    _loadUserStats(); // Carrega pontos iniciais
    _resetGame(); 
  }

  // Carrega os dados do jogador para mostrar na tela
  Future<void> _loadUserStats() async {
    final stats = await _historicoService.getUserStats();
    if (mounted) {
      setState(() {
        _currentScore = stats['score'] ?? 0;
        _currentCombo = stats['combo'] ?? 0;
      });
    }
  }

  // ... (AS FUNÇÕES MINIMAX E FIND BEST MOVE CONTINUAM IGUAIS AQUI) ...
  // Vou omitir para economizar espaço, mas mantenha elas no seu código!
  // Se você copiou o arquivo inteiro, cole as funções minimax/findBestMove/checkWinner/getAvailableMoves do seu backup AQUI dentro.
  
  // -- COLE AQUI AS FUNÇÕES DE IA DO SEU BACKUP (checkWinner, minimax, etc) --
  // ...
  int checkWinner() {
    // ... (Use a lógica do seu backup) ...
     for (int i = 0; i <= 6; i += 3) {
      if (board[i] == board[i + 1] &&
          board[i + 1] == board[i + 2] &&
          board[i] != ' ') {
        return board[i] == player ? 1 : -1;
      }
    }
    for (int i = 0; i < 3; i++) {
      if (board[i] == board[i + 3] &&
          board[i + 3] == board[i + 6] &&
          board[i] != ' ') {
        return board[i] == player ? 1 : -1;
      }
    }
    if (board[0] == board[4] && board[4] == board[8] && board[0] != ' ') {
      return board[0] == player ? 1 : -1;
    }
    if (board[2] == board[4] && board[4] == board[6] && board[2] != ' ') {
      return board[2] == player ? 1 : -1;
    }
    if (!board.contains(' ')) {
      return 0;
    }
    return 2;
  }

  List<int> getAvailableMoves() {
    List<int> moves = [];
    for (int i = 0; i < board.length; i++) {
      if (board[i] == ' ') moves.add(i);
    }
    return moves;
  }

  int minimax(bool isMaximizing, String aiPlayer, String humanPlayer) {
    int score = checkWinner();
    if (score == 1) return -10; 
    if (score == -1) return 10; 
    if (score == 0) return 0;
    List<int> availableMoves = getAvailableMoves();
    if (isMaximizing) {
      int bestScore = -1000;
      for (int move in availableMoves) {
        board[move] = aiPlayer;
        bestScore = max(bestScore, minimax(false, aiPlayer, humanPlayer));
        board[move] = ' ';
      }
      return bestScore;
    } else {
      int bestScore = 1000;
      for (int move in availableMoves) {
        board[move] = humanPlayer;
        bestScore = min(bestScore, minimax(true, aiPlayer, humanPlayer));
        board[move] = ' ';
      }
      return bestScore;
    }
  }

  int findBestMove() {
    int bestScore = -1000;
    int bestMove = -1;
    for (int move in getAvailableMoves()) {
      board[move] = computer;
      int moveScore = minimax(false, computer, player);
      board[move] = ' ';
      if (moveScore > bestScore) {
        bestScore = moveScore;
        bestMove = move;
      }
    }
    return bestMove;
  }
  // -----------------------------------------------------------------------

  void _playerMove(int index) {
    if (gameEnded || board[index] != ' ' || _isComputerTurn) return;

    setState(() {
      board[index] = _currentPlayer;
    });

    int gameState = checkWinner();
    if (_checkEndGame(gameState)) return;

    if (_mode == GameMode.PvP) {
      _currentPlayer = (_currentPlayer == player) ? computer : player;
      setState(() {
        gameMessage = "Vez do Jogador '$_currentPlayer'";
      });
    } else {
      setState(() {
        gameMessage = 'IA pensando...';
        _isComputerTurn = true;
      });
      _computerMove();
    }
  }

  void _computerMove() {
    bool useOptimalMove = _difficulty?.deveJogarCerto() ?? true;
    int move;

    if (useOptimalMove) {
      move = findBestMove();
    } else {
      List<int> availableMoves = getAvailableMoves();
      if (availableMoves.isNotEmpty) {
        move = availableMoves[Random().nextInt(availableMoves.length)];
      } else {
        move = -1; 
      }
    }

    Future.delayed(const Duration(milliseconds: 600), () {
      if (move != -1) {
        setState(() {
          board[move] = computer;
        });
      }

      int gameState = checkWinner();
      if (_checkEndGame(gameState)) return;

      setState(() {
        gameMessage = "Sua vez (X)";
        _isComputerTurn = false;
      });
    });
  }

  // --- NOVA LÓGICA DE FIM DE JOGO ---
  bool _checkEndGame(int gameState) {
    if (gameState == 2) return false; 

    GameResult? resultado;
    String finalTitle = "";
    int pontosGanhosNaPartida = 0;

    if (gameState == 1) {
      // X Ganhou (Humano)
      resultado = GameResult.VITORIA;
      finalTitle = _mode == GameMode.PvP ? "X Venceu!" : "Vitória!";
    } else if (gameState == -1) {
      // O Ganhou (IA ou P2)
      resultado = GameResult.DERROTA; // Para o P1
      finalTitle = _mode == GameMode.PvP ? "O Venceu!" : "Derrota!";
    } else {
      resultado = GameResult.EMPATE;
      finalTitle = "Empate!";
    }

    setState(() {
      gameEnded = true;
      gameMessage = finalTitle;
    });

    // Salvar e atualizar Combo
    _processarResultado(resultado, finalTitle);
    
    return true;
  }

  Future<void> _processarResultado(GameResult resultado, String title) async {
    int pontos = 0;
    
    // Chama o serviço atualizado
    if (_mode == GameMode.PvE) {
      pontos = await _historicoService.registrarPartida(
        mode: _mode,
        result: resultado,
        difficulty: _difficulty,
      );
      // Atualiza a tela com os dados novos
      _loadUserStats(); 
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_mode == GameMode.PvE) ...[
                Text(
                  pontos >= 0 ? "+$pontos Pontos" : "$pontos Pontos",
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold,
                    color: pontos >= 0 ? Colors.green : Colors.red
                  ),
                ),
                if (resultado == GameResult.VITORIA)
                  const Text("Combo subiu!", style: TextStyle(color: Colors.orange)),
                if (resultado == GameResult.DERROTA)
                   const Text("Combo quebrou!", style: TextStyle(color: Colors.grey)),
              ] else
                 const Text("PvP não conta pontos."),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Menu'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Jogar Novamente'),
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      board = List.filled(9, ' ');
      gameEnded = false;
      _isComputerTurn = false;
      _currentPlayer = player; 
      gameMessage = _mode == GameMode.PvP ? "Vez do X" : "Sua vez (X)";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(_mode == GameMode.PvP ? 'PvP' : 'PvE (${_difficulty.toString().split('.').last})'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF283593), Color(0xFF1A237E)], // Azul Escuro
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placar
            if (_mode == GameMode.PvE)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatCard("Pontos", "$_currentScore"),
                    _StatCard("Combo", "${_currentCombo}x", color: Colors.orange),
                  ],
                ),
              ),

            Text(
              gameMessage,
              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 20),
            
            // Tabuleiro Bonito
            Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: 9,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _playerMove(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
                      ),
                      child: Center(
                        child: Text(
                          board[index],
                          style: GoogleFonts.fredoka(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: board[index] == 'X' ? Colors.blue[800] : (board[index] == 'O' ? Colors.red[800] : Colors.transparent),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard(this.label, this.value, {this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(value, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}