import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:just_lost_and_found/Screens/auth_screens/create_account_screen.dart';
import 'package:just_lost_and_found/screens/main_layout_screen.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';
import 'on_boarding_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool seenOnboarding;
  const SplashScreen({super.key, required this.seenOnboarding});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplashAndNavigate();
  }

  void _startSplashAndNavigate() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
        );
      } else if (widget.seenOnboarding) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CreateAccountScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/images/logo.png", height: 200, width: 200),
            const SizedBox(height: 16),
            Text(
              "splash.tagline1".tr(),
              style: TextStyle(
                fontSize: 20,
                color: ThemeManager.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "splash.tagline2".tr(),
              style: TextStyle(
                fontSize: 20,
                color: ThemeManager.primaryBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: ThemeManager.primaryYellow),
          ],
        ),
      ),
    );
  }
}
