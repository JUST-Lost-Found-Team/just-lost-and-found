import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:just_lost_and_found/Screens/auth_screens/create_account_screen.dart';
import 'package:just_lost_and_found/screens/onboarding_screens/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase is already initialized");
  }

  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
