import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login_screen.dart'; // 🔁 Needed for logout routing

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _user;
  Map<String, dynamic>? _backendData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initUser();
  }

  Future<void> _initUser() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();

      setState(() => _user = user);

      final data = await fetchProtectedUserData(token!);
      setState(() => _backendData = data);
    } catch (e) {
      setState(() => _error = 'Failed to load user data: $e');
    }
  }

  Future<Map<String, dynamic>> fetchProtectedUserData(String idToken) async {
    final uri = Uri.parse('https://api-prodf.aoe2hdbets.com/api/user/me');
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Backend error: ${response.statusCode}');
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: Center(child: Text(_error!)),
      );
    }

    if (_user == null || _backendData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Firebase UID: ${_user!.uid}'),
            Text('Email: ${_user!.email ?? "N/A"}'),
            const SizedBox(height: 20),
            const Text(
              'Private Backend Data:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('In-Game Name: ${_backendData!["in_game_name"] ?? "Unknown"}'),
            Text('UID: ${_backendData!["uid"]}'),
            Text('Email: ${_backendData!["email"]}'),
            Text('Admin: ${_backendData!["is_admin"] ?? false}'),
            Text('Verified: ${_backendData!["verified"] ?? false}'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _logout,
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
