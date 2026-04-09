import 'package:flutter/material.dart';
import 'package:just_lost_and_found/Screens/auth_screens/forget_password_screen.dart';
import 'package:just_lost_and_found/Screens/auth_screens/create_account_screen.dart';
import 'package:just_lost_and_found/screens/main_layout_screen.dart';
import 'package:just_lost_and_found/services/theme_manager.dart';
import 'package:just_lost_and_found/services/Auth-service_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailCTRL = TextEditingController();
  TextEditingController passwordCTRL = TextEditingController();
  bool _isObsure = true;
  bool loader = false;
  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        loader = true;
      });
      bool isSuccess = await AuthServices.SignInWithEmail(
        emailCTRL.text.trim(),
        passwordCTRL.text.trim(),
        context,
      );

      if (mounted) {
        setState(() {
          loader = false;
        });
        if (isSuccess == true) {
          // إذا نجح (true)، دخله عالتطبيق
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
          );
        } else {
          // إذا فشل (false)، ما تعمل إشي!
          // هو أصلاً رح يطلع الـ SnackBar البرتقالي اللي بالصورة ويضل مكانه
          print("Login failed, staying on login screen.");
        }
        //     Navigator.pushReplacement(
        //       context,
        //       MaterialPageRoute(builder: (context)=>const MainLayoutScreen()));
        //   }
        // }catch(e){
        //   if(mounted){
        //     setState(() {
        //       loader=false;
        //     });
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(content:Text("Login Failed:${e.toString()}")));
        //   }
        // }
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
                  Image.asset(
                    'assets/images/logo.png',
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const Text(
                    'Sign In',
                    style: TextStyle(
                      color: ThemeManager.primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
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
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isObsure = !_isObsure;
                          });
                        },
                        child: Icon(
                          _isObsure ? Icons.visibility_off : Icons.visibility,
                        ),
                      ),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                    obscureText: _isObsure,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) =>
                                  const ForgetPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Forget your password?',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _submit,

                      child: Text(
                        'Sign In',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeManager.primaryYellow,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                        ), //fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (context) => const CreateAccountScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 17,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.w600,
                            decorationColor: Colors.orange,
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
