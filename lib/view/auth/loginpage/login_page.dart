import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controller/auth_controller.dart';
import 'package:habit_tracker/data/settings_storage.dart';
import 'package:habit_tracker/generated/l10n.dart';
import 'package:habit_tracker/view/auth/loginpage/widget/Login_Page_Icon.dart';
import 'package:habit_tracker/view/auth/SignUpPage/signup_page.dart';
import 'package:habit_tracker/view/auth/forgot_password_page.dart';
import 'package:habit_tracker/view/homepage/HomeScreen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthController _authController = Get.put(AuthController());
  final SettingsStorage _settingsStorage = SettingsStorage();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignIn() async {
    if (_formKey.currentState!.validate()) {
      await _authController.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    await _authController.signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () async {
                          await _settingsStorage.init();
                          await _settingsStorage.setSkippedLogin(true);
                          Get.offAll(() => const HomeScreen());
                        },
                        child: Text(S.current.skipNow),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                 LoginPageIcon(theme: theme,),
                  // Logo or App Name
                  const SizedBox(height: 48),

                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: S.current.email,
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return S.current.emailRequired;
                      }
                      if (!value.contains('@')) {
                        return S.current.emailInvalid;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: S.current.password,
                      prefixIcon: const Icon(Icons.lock_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return S.current.passwordRequired;
                      }
                      if (value.length < 6) {
                        return S.current.passwordTooShort;
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 8),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Get.to(() => const ForgotPasswordPage());
                      },
                      child: Text(S.current.forgotPassword),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sign In Button
                  Obx(
                    () => ElevatedButton(
                      onPressed:
                          _authController.isLoading.value
                              ? null
                              : _handleEmailSignIn,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _authController.isLoading.value
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                S.current.login,
                                style: TextStyle(fontSize: 16),
                              ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          S.current.or,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Google Sign In Button
                  Obx(
                    () => OutlinedButton.icon(

                      onPressed:
                          _authController.isLoading.value
                              ? null
                              : _handleGoogleSignIn,
                      icon: Image.asset(
                        'assets/icon/google_icon.png',
                        height: 44,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.g_mobiledata, size: 44);
                        },
                      ),
                      label: Text(S.current.signInWithGoogle),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          

                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(S.current.dontHaveAccount),
                      TextButton(
                        onPressed: () {
                          Get.to(() => const SignUpPage());
                        },
                        child: Text(S.current.createAccount),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Skip Now Link
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text(S.current.skipNow),
                  //     TextButton(
                  //       onPressed: () async {
                  //         await _settingsStorage.init();
                  //         await _settingsStorage.setSkippedLogin(true);
                  //         Get.offAll(() => const HomeScreen());
                  //       },
                  //       child: Text(S.current.skipNow),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
