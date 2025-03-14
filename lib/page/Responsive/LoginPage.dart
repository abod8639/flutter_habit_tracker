// import 'package:flutter/material.dart';
// import 'package:get/get.dart';


// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final SupabaseService _supabaseService = SupabaseService.to;
//   bool _isLoading = false;
//   bool _isLogin = true; // للتبديل بين تسجيل الدخول والتسجيل الجديد

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   void _toggleAuthMode() {
//     setState(() {
//       _isLogin = !_isLogin;
//     });
//   }

//   Future<void> _authenticate() async {
//     if (_emailController.text.trim().isEmpty ||
//         _passwordController.text.isEmpty) {
//       Get.snackbar(
//         'خطأ',
//         'الرجاء إدخال البريد الإلكتروني وكلمة المرور',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.red.withOpacity(0.7),
//         colorText: Colors.white,
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       if (_isLogin) {
//         // تسجيل الدخول
//         await _supabaseService.signIn(
//           email: _emailController.text.trim(),
//           password: _passwordController.text,
//           onSuccess: (response) {
//             Get.offAllNamed('/home');
//           },
//           onError: (error) {
//             Get.snackbar(
//               'خطأ في تسجيل الدخول',
//               error,
//               snackPosition: SnackPosition.BOTTOM,
//               backgroundColor: Colors.red.withOpacity(0.7),
//               colorText: Colors.white,
//             );
//           },
//         );
//       } else {
//         // إنشاء حساب جديد
//         await _supabaseService.signUp(
//           email: _emailController.text.trim(),
//           password: _passwordController.text,
//           onSuccess: (response) {
//             Get.snackbar(
//               'تم إنشاء الحساب',
//               'تم إنشاء حسابك بنجاح. يمكنك الآن تسجيل الدخول.',
//               snackPosition: SnackPosition.BOTTOM,
//               backgroundColor: Colors.green.withOpacity(0.7),
//               colorText: Colors.white,
//             );
//             setState(() {
//               _isLogin = true;
//             });
//           },
//           onError: (error) {
//             Get.snackbar(
//               'خطأ في إنشاء الحساب',
//               error,
//               snackPosition: SnackPosition.BOTTOM,
//               backgroundColor: Colors.red.withOpacity(0.7),
//               colorText: Colors.white,
//             );
//           },
//         );
//       }
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_isLogin ? 'تسجيل الدخول' : 'إنشاء حساب'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             TextField(
//               controller: _emailController,
//               decoration: const InputDecoration(
//                 labelText: 'البريد الإلكتروني',
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _passwordController,
//               decoration: const InputDecoration(
//                 labelText: 'كلمة المرور',
//                 border: OutlineInputBorder(),
//               ),
//               obscureText: true,
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: _isLoading ? null : _authenticate,
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 12),
//               ),
//               child: _isLoading
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : Text(_isLogin ? 'تسجيل الدخول' : 'إنشاء حساب'),
//             ),
//             TextButton(
//               onPressed: _toggleAuthMode,
//               child: Text(_isLogin
//                   ? 'إنشاء حساب جديد'
//                   : 'لديك حساب بالفعل؟ تسجيل الدخول'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }