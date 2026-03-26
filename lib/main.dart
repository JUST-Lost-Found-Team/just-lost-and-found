import 'package:flutter/material.dart';
import 'package:just_lost_and_found/Screens/Forget_password_screen.dart';
import 'package:just_lost_and_found/Screens/SignIn_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:just_lost_and_found/Screens/SignUp_screen.dart';
import 'package:just_lost_and_found/Screens/profile_screen.dart';
import 'firebase_options.dart';


void main()async {
   WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
     home: ProfilePage()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
