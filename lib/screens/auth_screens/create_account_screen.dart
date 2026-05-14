import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_lost_and_found/screens/auth_screens/login_screen.dart';
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
  bool _isObsure = true;
  bool _ObscureConfirm = true;

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
            padding: const EdgeInsets.only(top: 0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      color:ThemeManager.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
                    ),
                  ),
                  const Text(
                    'Join to find your belongings,\nor help return someone else\'s.',
                    style: TextStyle(
                      color: Color.fromARGB(159, 23, 20, 20),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
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
                          validator: (value) => (value == null || value.isEmpty) ? "Please Enter Your Name" : null,
                        ),
                        const SizedBox(height: 10),
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
                            if (!value.endsWith('just.edu.jo')) return 'Use your JUST university email only';
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: passwordCTRL,
                          decoration: InputDecoration(
                            hintText: 'Password',
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.24),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() { _isObsure = !_isObsure; });
                              },
                              child: Icon(_isObsure ? Icons.visibility_off : Icons.visibility),
                            ),
                          ),
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: _isObsure,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Enter password';
                            if (value.length < 6) return 'Password too short';
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: confirmPasswordCTRL,
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            filled: true,
                            fillColor: Colors.grey.withOpacity(0.24),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() { _ObscureConfirm = !_ObscureConfirm; });
                              },
                              child: Icon(_ObscureConfirm ? Icons.visibility_off : Icons.visibility),
                            ),
                          ),
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: _ObscureConfirm,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Please confirm your password';
                            if (value != passwordCTRL.text) return 'Passwords do not match!';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: SizedBox(
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
                                'Create Account',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.black, fontSize: 15),
                      ),
                      const SizedBox(width: 5),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                        child: Text(
                          'log in',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 17,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                            decorationColor: ThemeManager.primaryYellow,
                            decorationThickness: 2,
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