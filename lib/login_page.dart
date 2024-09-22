// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'home_page.dart';

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   late Future<bool> _checkAuthFuture;

//   @override
//   void initState() {
//     super.initState();
//     _checkAuthFuture = _checkAuth();
//   }

//   Future<bool> _checkAuth() async {
//     final session = Supabase.instance.client.auth.currentSession;
//     return session != null;
//   }

//   Future<void> _signInWithGitHub() async {
//     try {
//       await Supabase.instance.client.auth.signInWithOAuth(
//         OAuthProvider.github,
//         redirectTo: 'io.supabase.flutterquickstart://login-callback/',
//       );
//       setState(() {
//         _checkAuthFuture = _checkAuth();
//       });
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $error')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Login')),
//       body: FutureBuilder<bool>(
//         future: _checkAuthFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (snapshot.data == true) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               Navigator.of(context).pushReplacement(
//                 MaterialPageRoute(builder: (context) => HomePage()),
//               );
//             });
//             return Container();
//           } else {
//             return Center(
//               child: ElevatedButton(
//                 onPressed: _signInWithGitHub,
//                 child: Text('Sign in with GitHub'),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
