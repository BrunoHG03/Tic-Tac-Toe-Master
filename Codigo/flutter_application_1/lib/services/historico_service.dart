// lib/services/historico_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/game_constants.dart';
import '../models/partida.dart';

class HistoricoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;
  String? get _userEmail => _auth.currentUser?.email;

  DocumentReference _getUserDoc() {
    if (_userId == null) throw Exception("Usuário não logado");
    return _firestore.collection('users').doc(_userId);
  }

  // 1. REGISTRAR PARTIDA (Com lógica de Combo)
  Future<int> registrarPartida({
    required GameMode mode,
    required GameResult result,
    Difficulty? difficulty,
  }) async {
    if (_userId == null || mode == GameMode.PvP) return 0;

    final userDocRef = _getUserDoc();

    return _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userDocRef);
      int currentScore = 0;
      int currentCombo = 0;
      String displayName = _userEmail?.split('@')[0] ?? 'Jogador';

      if (userSnapshot.exists) {
        final data = userSnapshot.data() as Map<String, dynamic>;
        currentScore = data['score'] ?? 0;
        currentCombo = data['combo'] ?? 0;
        if (data.containsKey('name')) displayName = data['name'];
      }

      int pointsEarned = 0;
      int newCombo = currentCombo;

      if (result == GameResult.VITORIA) {
        int base = difficulty?.basePoints ?? 10;
        int bonus = currentCombo * 2;
        pointsEarned = base + bonus;
        newCombo++;
      } else if (result == GameResult.DERROTA) {
        pointsEarned = -30;
        newCombo = 0; 
      } else {
        // Empate: 0 pontos, mantem combo
        pointsEarned = 0;
      }

      int newScore = currentScore + pointsEarned;
      
      // Atualiza Ranking
      transaction.set(userDocRef, {
        'score': newScore,
        'combo': newCombo,
        'name': displayName,
        'last_active': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Salva no histórico detalhado
      final novaPartida = Partida(
        mode: mode,
        result: result,
        difficulty: difficulty,
        pontosGanhos: pointsEarned,
        data: DateTime.now(),
      );
      
      final historicoRef = userDocRef.collection('historico').doc();
      transaction.set(historicoRef, novaPartida.toMap());

      return pointsEarned;
    });
  }

  // 2. PEGAR DADOS DO USUÁRIO (Score e Combo)
  Future<Map<String, dynamic>> getUserStats() async {
    if (_userId == null) return {'score': 0, 'combo': 0};
    final doc = await _getUserDoc().get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    }
    return {'score': 0, 'combo': 0};
  }

  // 3. PEGAR LISTA DE PARTIDAS (Recuperado!)
  Future<List<Partida>> getHistorico() async {
    if (_userId == null) return [];
    try {
      final snapshot = await _getUserDoc()
          .collection('historico')
          .orderBy('data', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => Partida.fromMap(doc.data())).toList();
    } catch (e) {
      print("Erro ao buscar histórico: $e");
      return [];
    }
  }

  // 4. LIMPAR HISTÓRICO (Recuperado e atualizado!)
  Future<void> limparHistorico() async {
    if (_userId == null) return;
    try {
      // Zera o score e combo no perfil
      await _getUserDoc().update({'score': 0, 'combo': 0});

      // Apaga a coleção de histórico
      final snapshot = await _getUserDoc().collection('historico').get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print("Erro ao limpar: $e");
    }
  }

  // 5. RANKING GLOBAL
  Future<List<Map<String, dynamic>>> getGlobalRanking() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('score', descending: true)
          .limit(20)
          .get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      return [];
    }
  }
}