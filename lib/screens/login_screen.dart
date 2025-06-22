import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

const String apiBase = 'https://api-prodf.aoe2hdbets.com';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _loading = false;
  String _error = '';

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pw = _pwCtrl.text;

    // Require at least 2 fields including password
    final filled = [name.isNotEmpty, email.isNotEmpty, pw.isNotEmpty].where((b) => b).length;
    if (pw.isEmpty || filled < 2) {
      setState(() {
        _error = 'Password and at least one of Email or Name required.';
        _loading = false;
      });
      return;
    }

    String loginEmail = email;

    try {
      // Fallback: look up email by in-game name
      if (loginEmail.isEmpty && name.isNotEmpty) {
        final res = await http.get(Uri.parse('$apiBase/api/user/get_email_from_ingame?in_game_name=$name'));
        if (res.statusCode != 200 || res.body.isEmpty) throw Exception('No account found for "$name"');
        loginEmail = jsonDecode(res.body)['email'] ?? '';
      }

      // Try login
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: loginEmail,
        password: pw,
      );
      if (context.mounted) Navigator.pushReplacementNamed(context, '/home');

    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' && name.isNotEmpty && email.isNotEmpty && pw.isNotEmpty) {
        try {
          // Auto-create
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: pw,
          );
          await http.post(
            Uri.parse('$apiBase/api/user/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'in_game_name': name}),
          );
          if (context.mounted) Navigator.pushReplacementNamed(context, '/home');
        } catch (err) {
          setState(() => _error = 'Registration failed: $err');
        }
      } else {
        setState(() => _error = e.message ?? 'Login failed');
      }
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'In-Game Name')),
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _pwCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            if (_error.isNotEmpty) Text(_error, style: const TextStyle(color: Colors.red)),
            if (_loading) const CircularProgressIndicator()
            else ElevatedButton(onPressed: _login, child: const Text('Login')),
          ],
        ),
      ),
    );
  }
}
