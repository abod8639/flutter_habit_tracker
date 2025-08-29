// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:habit_tracker/view/homepage/HomeScreen.dart';
// import 'package:supabase_auth_ui/supabase_auth_ui.dart';

// class SupaEmailAuthWidget extends StatefulWidget {
//   const SupaEmailAuthWidget({super.key});

//   @override
//   State<SupaEmailAuthWidget> createState() => _SupaEmailAuthWidgetState();
// }

// class _SupaEmailAuthWidgetState extends State<SupaEmailAuthWidget> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           SizedBox(height: 100),

//           SupaEmailAuth(
//             autofocus: true,
//             localization: SupaEmailAuthLocalization(),
//             // isInitiallySigningIn: false,
//             redirectTo:
//                 kIsWeb ? null : 'https://dydnmakiydczgbrkxxlf.supabase.co',
//             onSignInComplete: (response) {
//               Get.to(() => HomeScreen());
//             },
//             onSignUpComplete: (response) {
//               Get.to(() => HomeScreen());
//             },
//             metadataFields: [
//               MetaDataField(
//                 prefixIcon: const Icon(Icons.person),
//                 label: 'Username',
//                 key: 'username',
//                 validator: (val) {
//                   if (val == null || val.isEmpty) {
//                     return 'Please enter something';
//                   }
//                   return null;
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
