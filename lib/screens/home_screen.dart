import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app_prodf/utils/web_link.dart';

import 'login_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final inGameName = user?.displayName ?? user?.email ?? 'Player';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Stack(
        children: [
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () => openInBrowser('https://explorer.aoe2hdbets.com'),
              child: Image.asset(
                'assets/wolo_emblem.png',
                width: 60,
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Row(
              children: [
                TextButton(
                  onPressed: () {
                    debugPrint('Connect Wallet pressed');
                  },
                  child: const Text('Connect Wallet', style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 8),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    style: const TextStyle(color: Colors.black),
                    value: 'menu',
                    items: [
                      DropdownMenuItem(
                        value: 'menu',
                        enabled: false,
                        child: Text(
                          inGameName,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const DropdownMenuItem(value: 'profile', child: Text('👤 Profile')),
                      const DropdownMenuItem(value: 'logout', child: Text('🚪 Logout')),
                    ],
                    onChanged: (value) {
                      switch (value) {
                        case 'profile':
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          );
                          break;
                        case 'logout':
                          _logout(context);
                          break;
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const Center(
            child: Text(
              'Welcome to the Arena',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => openInBrowser('https://discord.gg/EfghKZY7U9'),
              child: Center(
                child: SvgPicture.asset(
                  'assets/discord_white.svg',
                  width: 32,
                  colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

