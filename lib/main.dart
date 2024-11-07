import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pets_app/admin%20section/admin_page.dart';
import 'package:pets_app/login%20screens/login_page.dart';
import 'package:pets_app/home_page.dart';
import 'package:pets_app/login%20screens/signUp_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(PetWalkerApp());
}

class PetWalkerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Walker App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(), // Determine which page to show
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(), // HomePage route
        '/signup': (context) => SignUpPage(), // SignUpPage route
        '/adminHomePage': (context) => AdminHomePage(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  Future<Widget> _getRedirectPage(User user) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final isAdmin = userDoc.data()?['admin'] ?? false;

    if (isAdmin) {
      return AdminHomePage(); // Redirect to AdminHomePage if the user is an admin
    } else {
      return HomePage(); // Redirect to HomePage for regular users
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for Firebase to initialize
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // If the user is logged in, check their role and navigate accordingly
          return FutureBuilder<Widget>(
            future: _getRedirectPage(snapshot.data!),
            builder: (context, AsyncSnapshot<Widget> roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              } else if (roleSnapshot.hasData) {
                return roleSnapshot.data!;
              } else {
                return HomePage(); // Fallback to HomePage if role check fails
              }
            },
          );
        } else {
          // If the user is not logged in, navigate to the LoginPage
          return LoginPage();
        }
      },
    );
  }
}
