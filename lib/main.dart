import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyC_7CGvSRBY2t3Riy5IMtrfTXcd2BZbdA8",
      authDomain: "aoe2hd.firebaseapp.com",
      projectId: "aoe2hd",
      storageBucket: "aoe2hd.firebasestorage.app",
      messagingSenderId: "640514020315",
      appId: "1:640514020315:web:223fa4c08cd8c85e080dfe",
      measurementId: "G-VZ61RDYLK9",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
