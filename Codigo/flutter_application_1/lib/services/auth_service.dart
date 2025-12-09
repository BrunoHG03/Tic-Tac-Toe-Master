// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Instância do Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream que "ouve" as mudanças de login/logout
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Getter para pegar o usuário atual (se houver)
  User? get currentUser => _auth.currentUser;

  // --- FUNÇÃO DE LOGIN COM GOOGLE (CORRIGIDA PARA ANDROID) ---
  Future<String> signInWithGoogle() async {
    try {
      // 1. Inicia o fluxo de login
      // Nota: Mantivemos o scopes: ['email'] pois é boa prática
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: ['email'],
      ).signIn(); 
      
      if (googleUser == null) {
        return "Login cancelado";
      }

      // 2. Pega os detalhes de autenticação (tokens)
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Cria a credencial
      // MUDANÇA AQUI: Agora passamos o accessToken também!
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken, // <--- ANTES ESTAVA null
        idToken: googleAuth.idToken,
      );

      // 4. Login no Firebase
      await _auth.signInWithCredential(credential);
      
      return "Sucesso";
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Erro de Firebase";
    } catch (e) {
      return "Erro: ${e.toString()}";
    }
  }

  // --- Funções de E-mail/Senha (Estavam certas, mas vão aqui) ---

  // Função de Login (E-mail/Senha)
  Future<String> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Sucesso"; // Deu certo
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Erro desconhecido";
    }
  }

  // Função de Cadastro (E-mail/Senha)
  Future<String> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return "Sucesso"; // Deu certo
    } on FirebaseAuthException catch (e) {
      return e.message ?? "Erro desconhecido";
    }
  }

  // Função de Logout (CORRIGIDA)
  Future<void> signOut() async {
    await GoogleSignIn().signOut(); // <-- MUDANÇA (Este é o jeito certo)
    await _auth.signOut();
  }
}