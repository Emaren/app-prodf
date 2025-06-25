import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:app_prodf/utils/web_keplr.dart';
import 'package:app_prodf/utils/web_link.dart';

import 'login_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? walletAddress;

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Future<void> waitForKeplr() async {
    int retries = 0;
    while (keplr == null && retries++ < 30) {
      debugPrint('⏳ Waiting for Keplr...');
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  Future<void> _connectWallet() async {
    try {
      const chainId = 'wolochain';
      debugPrint('📡 Connect Wallet pressed');

      await waitForKeplr();

      if (keplr == null) {
        debugPrint('❌ Keplr not found in browser');
        return;
      }

      await suggestWolo(); // ✅ Inject WoloChain config into Keplr

      keplr!.enable(chainId);

      final signer = keplr!.getOfflineSignerAuto(chainId);
      final accounts = signer.getAccounts();

      if (accounts.isEmpty) {
        debugPrint('❌ No accounts returned from Keplr');
        return;
      }

      final address = accounts[0].address;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        debugPrint('❌ No Firebase user found');
        return;
      }

      final token = await user.getIdToken();

      final res = await http.post(
        Uri.parse('https://api-prodf.aoe2hdbets.com/api/user/link_wallet'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'wallet_address': address}),
      );

      if (res.statusCode == 200) {
        setState(() {
          walletAddress = address;
        });
        debugPrint('✅ Wallet linked: $address');
      } else {
        debugPrint('❌ Failed to link wallet: ${res.body}');
      }
    } catch (e) {
      debugPrint('❌ Wallet error: $e');
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
                  onPressed: _connectWallet,
                  child: Text(
                    walletAddress != null
                        ? 'Wallet: ${walletAddress!.substring(0, 6)}…'
                        : 'Connect Wallet',
                    style: const TextStyle(color: Colors.white),
                  ),
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
