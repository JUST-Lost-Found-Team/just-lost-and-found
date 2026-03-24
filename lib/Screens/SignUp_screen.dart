import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailCTRL = TextEditingController();
  TextEditingController passwordCTRL = TextEditingController();
  TextEditingController confirmPasswordCTRL = TextEditingController();
  bool loader = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
    
      setState(() {
        loader = true;
      });

      try {
        
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailCTRL.text.trim(),
          password: passwordCTRL.text.trim(),
        );

        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Success! Account Created.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? 'Registration Failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('An error occurred'), backgroundColor: Colors.red),
          );
        }
      } finally {
        
        if (mounted) {
          setState(() {
            loader = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Color.fromARGB(255, 68, 118, 164),
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: emailCTRL,
                    decoration: InputDecoration(
                      hintText: 'Email (@just.edu.jo)',
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.24),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter email';
                      if (!value.endsWith('just.edu.jo')) {
                        return 'Use your JUST university email only';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordCTRL,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.24),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Enter password';
                      if (value.length < 6) return 'Password too short';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: confirmPasswordCTRL,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.24),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please confirm your password';
                      if (value != passwordCTRL.text) return 'Passwords do not match!';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: loader ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE4973F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: loader
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Sign Up',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}