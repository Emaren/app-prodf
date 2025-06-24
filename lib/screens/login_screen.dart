import 'dart:convert';

import 'package:app_prodf/utils/web_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

const String flutterEnv = String.fromEnvironment('FLUTTER_ENV');
const String apiBase = flutterEnv == 'prod'
    ? 'https://api-prodf.aoe2hdbets.com'
    : 'http://localhost:8002';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _loading = false, _remember = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
    _pwCtrl.addListener(() {
      if (!_loading && _pwCtrl.text.endsWith('\n')) {
        _pwCtrl.text = _pwCtrl.text.trim();
        _login();
      }
    });
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _remember = prefs.getBool('remember') ?? false;
      if (_remember) {
        _emailCtrl.text = prefs.getString('email') ?? '';
        _nameCtrl.text = prefs.getString('name') ?? '';
      }
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (_remember) {
      await prefs.setString('email', _emailCtrl.text);
      await prefs.setString('name', _nameCtrl.text);
    } else {
      await prefs.remove('email');
      await prefs.remove('name');
    }
    await prefs.setBool('remember', _remember);
  }

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    await _savePrefs();

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pw = _pwCtrl.text;

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
      if (loginEmail.isEmpty && name.isNotEmpty) {
        final res = await http.get(Uri.parse('$apiBase/api/user/get_email_from_ingame?in_game_name=$name'));
        if (res.statusCode != 200 || res.body.isEmpty) {
          throw Exception('No account found for "$name"');
        }
        loginEmail = jsonDecode(res.body)['email'] ?? '';
      }

      final userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: loginEmail,
        password: pw,
      );

      final token = await userCred.user?.getIdToken();
      print('🔥 Firebase Token: $token');

      if (context.mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (name.isNotEmpty && email.isNotEmpty && pw.isNotEmpty) {
        try {
          final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: pw,
          );

          final token = await userCred.user?.getIdToken();
          print('🔥 Firebase Token (post-registration): $token');

          final res = await http.post(
            Uri.parse('$apiBase/api/user/register'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'in_game_name': name}),
          );

          if (res.statusCode != 200) {
            print('❌ Registration API failed: ${res.statusCode} - ${res.body}');
            throw Exception('Backend registration failed');
          }

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
  Widget build(BuildContext c) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => openInBrowser('https://explorer.aoe2hdbets.com'),
                  child: Image.asset('assets/wolo_emblem.png', width: 120),
                ),
              ),
              const SizedBox(height: 12),
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
                style: const TextStyle(color: Colors.white),
                obscureText: true,
                decoration: _inputDecoration('Password'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _remember,
                    onChanged: (v) => setState(() => _remember = v!),
                  ),
                  const Text('Remember Me', style: TextStyle(color: Colors.white70)),
                ],
              ),
              if (_error.isNotEmpty)
                Text(_error, style: const TextStyle(color: Colors.red)),
              _loading
                  ? const CircularProgressIndicator(color: Colors.amber)
                  : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      ),
                      child: const Text('Enter the Arena'),
                    ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => openInBrowser('https://discord.gg/EfghKZY7U9'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/discord_white.svg',
                        width: 32,
                        colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Join our Discord',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
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

