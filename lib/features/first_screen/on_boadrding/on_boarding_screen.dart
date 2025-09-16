// import 'package:flutter/material.dart';
// import '../../../controller/cache/shared_preferences_utils.dart';
// import '../../../core/utils/app_routes.dart';
//
// class OnBoardingScreen extends StatelessWidget {
//   const OnBoardingScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // عرض الصورة
//                     Container(
//                       width: 200,
//                       height: 200,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(20),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 10,
//                             offset: const Offset(0, 5),
//                           ),
//                         ],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(20),
//                         child: Image.asset(
//                           'assets/images/Frist Screen.png',
//                           width: 200,
//                           height: 200,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Container(
//                               width: 200,
//                               height: 200,
//                               color: Colors.grey[300],
//                               child: Icon(
//                                 Icons.image_not_supported,
//                                 size: 50,
//                                 color: Colors.grey[600],
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     const Text(
//                       'Welcome!',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 15),
//                     const Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 20),
//                       child: Text(
//                         'Choose your role to get started with the app',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey,
//                           height: 1.5,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             // الأزرار
//             Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 children: [
//                   // زرار الكابتن
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () async {
//                         // Save that user has seen OnBoarding
//                         await SharedPreferenceUtils.saveData(
//                             key: 'isFirstTime',
//                             value: false
//                         );
//                         // Save user role as Captain
//                         await SharedPreferenceUtils.saveData(
//                             key: 'userRole',
//                             value: 'captain'
//                         );
//
//                         if (context.mounted) {
//                           Navigator.pushReplacementNamed(
//                               context,
//                               AppRoutes.loginRoute
//                           );
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.orange,
//                         foregroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 15),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         elevation: 3,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(Icons.sailing, size: 24),
//                           const SizedBox(width: 10),
//                           const Text(
//                             'Continue as Captain',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 15),
//                   // زرار الويتر
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () async {
//                         // Save that user has seen OnBoarding
//                         await SharedPreferenceUtils.saveData(
//                             key: 'isFirstTime',
//                             value: false
//                         );
//                         // Save user role as Waiter
//                         await SharedPreferenceUtils.saveData(
//                             key: 'userRole',
//                             value: 'waiter'
//                         );
//
//                         if (context.mounted) {
//                           Navigator.pushReplacementNamed(
//                               context,
//                               AppRoutes.loginRoute
//                           );
//                         }
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         foregroundColor: Colors.orange,
//                         padding: const EdgeInsets.symmetric(vertical: 15),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           side: const BorderSide(color: Colors.orange, width: 2),
//                         ),
//                         elevation: 3,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(Icons.room_service, size: 24),
//                           const SizedBox(width: 10),
//                           const Text(
//                             'Continue as Waiter',
//                             style: TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }