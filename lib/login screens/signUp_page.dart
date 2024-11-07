import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pets_app/home_page.dart';  // Import the HomePage
import 'package:pets_app/login%20screens/profile_details.dart';
 // Import CompleteProfilePage

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isLoading = false; // To track loading state

  // Method to handle user sign up and store data in Firestore
  Future<void> signUpWithEmail() async {
    setState(() {
      _isLoading = true; // Show spinner
    });

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // Store user data in Firestore after successful sign-up
      await _firestore.collection('Users').doc(uid).set({
        'email': _emailController.text.trim(),
        'name': _nameController.text.trim(),
        'created_at': Timestamp.now(),
      });

      // Navigate to the CompleteProfilePage after successful signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CompleteProfilePage()
        ),
      );

      // Clear text fields after successful signup
      _emailController.clear();
      _passwordController.clear();
      _nameController.clear();
    } on FirebaseAuthException catch (e) {
      print('Error: ${e.message}');
    } finally {
      setState(() {
        _isLoading = false; // Hide spinner after process completes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Background Image with Logo in the Center
          Stack(
            alignment: Alignment.center, // Aligns everything at the center of the stack
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/background.jpeg'), // Your background image path
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              ClipOval(
                child: Image.asset(
                  'assets/images/logo.jpeg', // Your logo path
                  height: 150,
                ),
              ),
            ],
          ),

          // Rest of the UI with white background
          Expanded(
            child: Container(
              color: Colors.white, // Set background to white for the rest of the screen
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 40), // Adjust spacing between logo and form

                      // Name Field with Oval Border
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10), // Oval shape
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Email Field with Oval Border
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10), // Oval shape
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Password Field with Oval Border
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10), // Oval shape
                          ),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 20),

                      // Show spinner when loading, otherwise show the button
                      _isLoading
                          ? CircularProgressIndicator() // Show spinner while signing up
                          : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: signUpWithEmail,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrangeAccent, // Button color
                            padding: EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10), // Oval button shape
                            ),
                            textStyle: TextStyle(fontSize: 18),
                          ),
                          child: Text(
                            'Sign Up',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),

                      // Terms and Conditions Row
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'By continuing, you agree to our ',
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(height: 5),
                          GestureDetector(
                            onTap: () {
                              // Handle terms and conditions click
                            },
                            child: Text(
                              'Terms and Conditions',
                              style: TextStyle(
                                color: Colors.deepOrangeAccent,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Handle privacy policy click
                            },
                            child: Text(
                              'Privacy Policy',
                              style: TextStyle(
                                color: Colors.deepOrangeAccent,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
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
        ],
      ),
    );
  }
}
