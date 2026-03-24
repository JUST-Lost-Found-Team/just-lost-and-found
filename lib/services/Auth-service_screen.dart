import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthServices{
  static Future<String>SignUpWithEmail(String email,String password) async{
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      return 'Sign Up Successful';
    } catch (e) {
      return 'Error during signup!:${e.toString()}';
    }

  }
  static handleSignUp(String email,String password,BuildContext context)async{
    String message=await SignUpWithEmail(email, password);
    showSnackBar(message,context);

  }
}


void showSnackBar(String message, BuildContext context) {
  final snackBar=SnackBar(content: Text(message,style:TextStyle(color:Colors.white)),
  backgroundColor: Colors.orange,
  behavior: SnackBarBehavior.floating,
  duration: const Duration(seconds:3),);

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
