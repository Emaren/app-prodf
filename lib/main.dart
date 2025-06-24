import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart'; // ✅ add this

/// Flutter-web entry-point with aggressive error surfacing.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Log all framework errors + stop in DevTools while debugging.
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kDebugMode) dev.debugger();
  };

  debugPrint('🚨 Entered main()');

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialised');
  } catch (e, st) {
    debugPrint('🔥 Firebase init failed: $e');
    debugPrintStack(stackTrace: st);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Web Demo',
        theme: ThemeData(
          colorSchemeSeed: Colors.deepPurple,
          useMaterial3: true,
        ),
        home: const LoginScreen(),
        routes: {
          '/home': (context) => const HomeScreen(), // ✅ added route
        },
      );
}

