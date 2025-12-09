// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);
  static const routeName = '/auth';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  String _errorMessage = '';

  void _submitAuthForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _isLoading = true; _errorMessage = ''; });

    String result;
    if (_isLogin) {
      result = await _auth.signIn(_emailController.text.trim(), _passwordController.text.trim());
    } else {
      result = await _auth.register(_emailController.text.trim(), _passwordController.text.trim());
    }

    if (result == "Sucesso") {
      if (!mounted) return;
      Navigator.of(context).pop();
    } else {
      setState(() { _errorMessage = result; _isLoading = false; });
    }
  }

  void _googleSignIn() async {
    setState(() { _isLoading = true; _errorMessage = ''; });
    final result = await _auth.signInWithGoogle();

    if (result == "Sucesso") {
      if (!mounted) return;
      Navigator.of(context).pop();
    } else {
      setState(() { 
        if (result != "Login cancelado") _errorMessage = result; 
        _isLoading = false; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6A1B9A), Color(0xFF283593)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isLogin ? 'Bem-vindo!' : 'Criar Conta',
                        style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                      const SizedBox(height: 30),
                      
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) => (val == null || !val.contains('@')) ? 'E-mail inválido' : null,
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          prefixIcon: const Icon(Icons.lock_outline),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) => (val == null || val.length < 6) ? 'Mínimo 6 caracteres' : null,
                      ),
                      
                      const SizedBox(height: 15),
                      if (_errorMessage.isNotEmpty)
                        Text(_errorMessage, style: const TextStyle(color: Colors.red, fontSize: 13)),
                      const SizedBox(height: 15),

                      if (_isLoading)
                        const CircularProgressIndicator()
                      else
                        Column(
                          children: [
                            ElevatedButton(
                              onPressed: _submitAuthForm,
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(_isLogin ? 'ENTRAR' : 'CADASTRAR', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                            ),
                            
                            const SizedBox(height: 20),
                            Row(children: const [Expanded(child: Divider()), Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("OU")), Expanded(child: Divider())]),
                            const SizedBox(height: 20),

                            OutlinedButton.icon(
                              onPressed: _googleSignIn,
                              icon: Image.asset(
                                'assets/images/google_logo.png', 
                                height: 24,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.login, color: Colors.red),
                              ),
                              label: const Text("Entrar com Google"),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),

                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                  _errorMessage = '';
                                });
                              },
                              child: Text(_isLogin ? 'Criar nova conta' : 'Já tenho conta'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}