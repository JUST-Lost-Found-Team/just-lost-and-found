import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:just_lost_and_found/features/auth/forget_password_screen.dart';
import 'package:just_lost_and_found/features/auth/create_account_screen.dart';
import 'package:just_lost_and_found/layout/main_layout_screen.dart';
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
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
          );
        } else {
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? theme.scaffoldBackgroundColor
          : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 0),

            child: Form(
              key: _formKey,

              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Image.asset(
                      'assets/images/logo.png',
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                    Text(
                      'login_screen.welcome_back'.tr(),
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                      ),
                    ),
                    // SizedBox(height: 10,),
                    SizedBox(height: 8),
                    Text(
                      'login_screen.login_to_continue'.tr(),
                      style: TextStyle(
                        // color: Color.fromARGB(159, 23, 20, 20),
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailCTRL,
                      decoration: InputDecoration(
                        hint: Text('login_screen.email_hint'.tr()),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.24),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: ThemeManager.primaryYellow,
                            width: 1.5,
                          ),
                        ),
                        prefixIcon: const Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'login_screen.email_empty_error'.tr();

                        if (!value.endsWith('just.edu.jo')) {
                          return 'login_screen.email_invalid_error'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: passwordCTRL,
                      decoration: InputDecoration(
                        hint: Text('login_screen.password_hint'.tr()),
                        filled: true,
                        fillColor: Colors.grey.withOpacity(0.24),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: ThemeManager.primaryYellow,
                            width: 1.5,
                          ),
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
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'login_screen.password_empty_error'.tr();
                        if (value.length < 6)
                          return 'login_screen.password_short_error'.tr();

                        return null;
                      },
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
                            'login_screen.forget_password'.tr(),
                            style: TextStyle(
                              color: ThemeManager.primaryYellow,
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
                        onPressed: loader ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ThemeManager.primaryYellow,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),

                        child: loader
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'login_screen.login_btn'.tr(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "login_screen.no_account".tr(),
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (context) =>
                                    const CreateAccountScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'login_screen.create_account'.tr(),
                            style: TextStyle(
                              color: ThemeManager.primaryYellow,
                              fontSize: 16,
                              // decoration: TextDecoration.underline,
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
      ),
    );
  }
}
