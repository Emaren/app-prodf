import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  String _error = '';
  bool _loading = false;

  Future<void> _register() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pw = _pwCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || pw.isEmpty) {
      setState(() => _error = 'All fields are required');
      return;
    }

    setState(() {
      _error = '';
      _loading = true;
    });

    try {
      final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: pw,
      );

      final token = await userCred.user?.getIdToken();
      print('🔥 Firebase Token: $token');

      final res = await http.post(
        Uri.parse('$apiBase/api/user/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'in_game_name': name}),
      );

      if (res.statusCode != 200) {
        print('❌ API failed: ${res.statusCode} - ${res.body}');
        try {
          final err = jsonDecode(res.body);
          throw Exception('${err["field"] ?? "Error"}: ${err["error"] ?? "Unknown error"}');
        } catch (_) {
          throw Exception('Backend registration failed');
        }
      }

      if (context.mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Firebase error');
    } catch (e) {
      setState(() => _error = 'Error: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            children: [
              Image.asset('assets/wolo_emblem.png', width: 120),
              const SizedBox(height: 24),
              const Text('Create Account', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 24),
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('In-Game Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pwCtrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Password'),
              ),
              const SizedBox(height: 12),
              if (_error.isNotEmpty)
                Text(_error, style: const TextStyle(color: Colors.red)),
              _loading
                  ? const CircularProgressIndicator(color: Colors.amber)
                  : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      ),
                      child: const Text('Register'),
                    ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Text(
                  'Back to login',
                  style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white12,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }
}

