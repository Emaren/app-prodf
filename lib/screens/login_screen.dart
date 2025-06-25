import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_prodf/utils/web_link.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
      }
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (_remember) {
      await prefs.setString('email', _emailCtrl.text);
    } else {
      await prefs.remove('email');
    }
    await prefs.setBool('remember', _remember);
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pw = _pwCtrl.text.trim();

    if (email.isEmpty || pw.isEmpty) {
      setState(() => _error = 'Email and password required');
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    await _savePrefs();

    try {
      final userCred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pw,
      );
      final token = await userCred.user?.getIdToken();
      print('🔥 Firebase Token: $token');
      if (context.mounted) Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        try {
          final userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: pw,
          );
          final token = await userCred.user?.getIdToken();
          print('🔥 Firebase Token (new user): $token');
          if (context.mounted) Navigator.pushReplacementNamed(context, '/setup');
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
              GestureDetector(
                onTap: () => openInBrowser('https://explorer.aoe2hdbets.com'),
                child: Image.asset('assets/wolo_emblem.png', width: 120),
              ),
              const Text('AoE2HD p2p Betting', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 24),
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
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/register'),
                child: const Text(
                  'No account? Register here',
                  style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => openInBrowser('https://discord.gg/EfghKZY7U9'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset('assets/discord_white.svg', width: 32, colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn)),
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

