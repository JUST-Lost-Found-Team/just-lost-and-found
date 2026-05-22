import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:just_lost_and_found/features/auth/login_screen.dart';
import 'package:just_lost_and_found/layout/main_layout_screen.dart';
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
            SnackBar(
              content: Text('create_account.success_msg'.tr()),
              backgroundColor: ThemeManager.successGreen,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.message ?? 'create_account.registration_failed'.tr(),
              ),
              backgroundColor: ThemeManager.errorRed,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('create_account.error_default'.tr()),
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark
          ? theme.scaffoldBackgroundColor
          : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: 24),
                Image.asset(
                  'assets/images/logo.png',
                  height: 180,
                  fit: BoxFit.cover,
                ),

                Text(
                  'create_account.title'.tr(),
                  style: TextStyle(
                    color: ThemeManager.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),
                SizedBox(height: 8),

                Text(
                  textAlign: TextAlign.center,
                  'create_account.subtitle'.tr(),
                  style: TextStyle(
                    // color: Color.fromARGB(159, 23, 20, 20),
                    fontSize: 16,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameCTRL,
                        decoration: InputDecoration(
                          hint: Text("create_account.full_name_hint".tr()),
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

                          prefixIcon: Icon(Icons.person),
                        ),
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) => (value == null || value.isEmpty)
                            ? "create_account.full_name_error".tr()
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailCTRL,
                        decoration: InputDecoration(
                          hint: Text('create_account.email_hint'.tr()),
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
                            return 'create_account.email_empty_error'.tr();
                          if (!value.endsWith('just.edu.jo'))
                            return 'create_account.email_domain_error'.tr();
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passwordCTRL,
                        decoration: InputDecoration(
                          hint: Text('create_account.password_hint'.tr()),
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
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _isObsure = !_isObsure;
                              });
                            },
                            child: Icon(
                              _isObsure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: _isObsure,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'create_account.password_empty_error'.tr();
                          if (value.length < 6)
                            return 'create_account.password_length_error'.tr();
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: confirmPasswordCTRL,
                        decoration: InputDecoration(
                          hint: Text(
                            'create_account.confirm_password_hint'.tr(),
                          ),
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
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                _ObscureConfirm = !_ObscureConfirm;
                              });
                            },
                            child: Icon(
                              _ObscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: _ObscureConfirm,
                        validator: (value) {
                          if (value == null || value.isEmpty)
                            return 'create_account.confirm_password_empty_error'
                                .tr();
                          if (value != passwordCTRL.text)
                            return 'create_account.password_match_error'.tr();
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
                          : Text(
                              'create_account.create_btn'.tr(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "create_account.already_have_account".tr(),
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: Text(
                        'create_account.log_in'.tr(),
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
    );
  }
}
