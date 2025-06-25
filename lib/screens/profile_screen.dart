import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  Map<String, dynamic>? _backendData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initUserAndData();
  }

  Future<void> _initUserAndData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      final rawToken = await user.getIdToken(true);
      if (rawToken == null || rawToken.trim().isEmpty) {
        throw Exception('Failed to retrieve ID token');
      }

      final resp = await http.get(
        
Uri.parse('$apiBase/user/me'),
        headers: {
          'Authorization': 'Bearer $rawToken',
          'Content-Type': 'application/json',
        },
      );

      if (resp.statusCode != 200) throw Exception('Backend error');

      setState(() {
        _user = user;
        _backendData = jsonDecode(resp.body);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(child: Text(_error!)),
      );
    }

    if (_user == null || _backendData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final inGameName = _backendData!['in_game_name'];

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
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
            Text('In-Game Name: $inGameName'),
            Text('UID: ${_backendData!["uid"]}'),
            Text('Email: ${_backendData!["email"]}'),
            Text('Admin: ${_backendData!["is_admin"] ?? false}'),
            Text('Verified: ${_backendData!["verified"] ?? false}'),
          ],
        ),
      ),
    );
  }
}

