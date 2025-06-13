// import 'package:flutter/material.dart';
// import 'package:habit_tracker/view/homepage/Responsive/Phone.dart';

// class MyAppBar extends StatelessWidget {
//   const MyAppBar({super.key});

//   @override
//   Widget build(BuildContext context) {
//   late final Animation<double> menuRotationAnimation;
//     return SliverAppBar(
//       pinned: true,
//       automaticallyImplyLeading: true,
//       surfaceTintColor: Colors.transparent,
//       shadowColor: Colors.transparent,
//       foregroundColor: Colors.transparent,
//       floating: true,
//       backgroundColor: Colors.transparent,
//       leading: Builder(
//         builder: (context) {
//           final state = context.findAncestorStateOfType<PhoneState>();
//           return AnimatedBuilder(
//             animation: state!.menuRotationAnimation,
//             builder: (context, child) {
//               return Transform.rotate(
//                 angle: state.menuRotationAnimation.value * 0.5,
//                 child: IconButton(
//                   icon: Icon(
//                     color: Theme.of(context).colorScheme.onSurface,
//                     Icons.menu,
//                   ),
//                   onPressed: () {
//                     state.menuAnimationController.forward().then((_) {
//                       state.menuAnimationController.reverse();
//                       Scaffold.of(context).openDrawer();
//                     });
//                   },
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
