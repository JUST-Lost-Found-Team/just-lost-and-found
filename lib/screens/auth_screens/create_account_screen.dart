import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_lost_and_found/Screens/auth_screens/login_screen.dart';
import 'package:just_lost_and_found/services/Auth-service_screen.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameCTRL = TextEditingController();
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
        await AuthServices.SignUpWithEmail(
          nameCTRL.text.trim(),
          emailCTRL.text.trim(),
          passwordCTRL.text.trim(),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Success! Account Created.'),
              backgroundColor: ThemeManager.successGreen,
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? 'Registration Failed'),
              backgroundColor: ThemeManager.errorRed,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An error occurred'),
              backgroundColor: ThemeManager.errorRed,
            ),
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
      backgroundColor: const Color(0xFFFDFBFF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  Image.asset(
                    'assets/images/logo.png',
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Color.fromARGB(255, 68, 118, 164),
                      fontWeight: FontWeight.bold,
                      fontSize: 40,
                    ),
                  ),
                  const Text(
                    'Because losing things is hard,\n finding them should be easy.',
                    style: TextStyle(
                      color: Color(0xFFE4973F),
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Text(
                    'JOIN US NOW !',
                    style: TextStyle(
                      color: Color(0xFFE4973F),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),

                  const SizedBox(height: 30),
                  TextFormField(
                    controller: nameCTRL,
                    decoration: InputDecoration(
                      hintText: 'Full Name',
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.24),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return "Please Enter Your Name";
                      else {
                        return null;
                      }
                    },
                  ),

                  const SizedBox(height: 20),
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
                      if (value == null || value.isEmpty)
                        return 'Enter password';
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
                      if (value == null || value.isEmpty)
                        return 'Please confirm your password';
                      if (value != passwordCTRL.text)
                        return 'Passwords do not match!';
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
                        backgroundColor: ThemeManager.primaryYellow,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an Account?"),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },

                        child: const Text(
                          "Log in",
                          style: TextStyle(
                            color: ThemeManager.primaryYellow,

                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
