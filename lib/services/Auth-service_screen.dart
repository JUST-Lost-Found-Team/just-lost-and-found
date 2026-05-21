import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';

class AuthServices {
  static Future<void> SignUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);

    if (userCredential.user != null) {
      await userCredential.user!.updateDisplayName(name);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'uid': userCredential.user!.uid,
            'name': name,
            'email': email,
            'profileImage':
                'https://cdn-icons-png.flaticon.com/512/847/847969.png',
            'createdAt': FieldValue.serverTimestamp(),
          });
    }
  }

  static Future<bool> SignInWithEmail(
    String email,
    String password,
    BuildContext context,
  ) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      showSnackBar(
        'auth_services.error_prefix:'.tr() + '${e.toString()}',
        context,
      );
      return false;
    }
  }

  static handleSignIn(
    String email,
    String password,
    BuildContext context,
  ) async {
    bool success = await SignInWithEmail(email, password, context);
    if (success) {
      showSnackBar("auth_services.signin_success".tr(), context);
    }
  }

  //هون كود عشان الي ناسي الباس تاعه (دانا)
  static Future<String> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
      return 'auth_services.reset_success'.tr();
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  static Future<bool> userLogin() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return true;
    } else {
      return false;
    }
  }
}

void showSnackBar(String message, BuildContext context) {
  final snackBar = SnackBar(
    content: Text(message, style: TextStyle(color: Colors.white)),
    backgroundColor: ThemeManager.primaryYellow,
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 3),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
