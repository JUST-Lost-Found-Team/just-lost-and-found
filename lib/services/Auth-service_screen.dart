//import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

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
    String message=await SignUpWithEmail(email, password,);
    showSnackBar(message,context);

  }
  static Future<bool>SignInWithEmail(String email,String password, BuildContext context)async{
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      showSnackBar( 'Error:${e.toString()}',context);
      return false;
    }
  }
  static handleSignIn(String email,String password,BuildContext context)async{
    bool success=await SignInWithEmail(email, password,context);
    if(success){
      showSnackBar("Sign In Successful!", context);
    }
  }
  //هون كود عشان الي ناسي الباس تاعه (دانا)
  static Future<String> resetPassword(String email)async{
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email:email.trim());
      return 'Success : Reset link sent to your email';
    } catch (e) {
      return 'Error: ${e.toString()}';
      
    }

  }
  static Future<bool> userLogin()async{
    final User? user =FirebaseAuth.instance.currentUser;
    if(user!=null){
      return true;
    }
    else{
      return false;
    }
  }
}


void showSnackBar(String message, BuildContext context) {
  final snackBar=SnackBar(content: Text(message,style:TextStyle(color:Colors.white)),
  backgroundColor: Colors.orange,
  behavior: SnackBarBehavior.floating,
  duration: const Duration(seconds:3),);

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
