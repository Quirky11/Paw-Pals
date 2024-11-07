import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pets_app/login%20screens/profile_details.dart';
import 'package:pets_app/login%20screens/signUp_page.dart'; // Import the SignUpPage


class EmailLoginPage extends StatefulWidget {
  @override
  _EmailLoginPageState createState() => _EmailLoginPageState();
}

class _EmailLoginPageState extends State<EmailLoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> loginWithEmail() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // Navigate to CompleteProfilePage after successful login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CompleteProfilePage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      print('Error: ${e.message}');
      // Optionally, show an error message to the user here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          double availableHeight = constraints.maxHeight;

          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: availableHeight,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Top Half: Background Image and Logo
                    Container(
                      height: availableHeight * 0.4, // Top half of the screen
                      child: Stack(
                        children: [
                          // Background Image
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage('assets/images/background.jpeg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          // Logo Centered
                          Positioned.fill(
                            child: Center(
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/logo.jpeg',
                                  height: 150, // Adjust logo size as needed
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bottom Half: White Background and Form
                    Expanded(
                      child: Container(
                        color: Colors.white, // White background for the bottom half
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                ),
                              ),
                              SizedBox(height: 20),
                              TextField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                ),
                                obscureText: true,
                              ),
                              SizedBox(height: 30),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: loginWithEmail,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.all(16),
                                    backgroundColor: Colors.deepOrangeAccent, // Green button
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    'Login',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Add Forgot Password functionality
                                },
                                child: Text(
                                  "Forgot Password",
                                  style: TextStyle(
                                    color: Colors.deepOrangeAccent,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline, // Underline text
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Navigate to SignUpPage
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SignUpPage()),
                                  );
                                },
                                child: Text(
                                  "New User? Sign Up!",
                                  style: TextStyle(
                                    color: Colors.deepOrangeAccent,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline, // Underline text
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
