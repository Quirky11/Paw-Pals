import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pets_app/login%20screens/profile_details.dart';

class OTPVerificationPage extends StatefulWidget {
  final String verificationId;
  final String phoneNumber; // Add this to show the phone number

  OTPVerificationPage({required this.verificationId, required this.phoneNumber});

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  int _remainingTime = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _remainingTime = 60;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('We have sent a verification code to'),
            Text(widget.phoneNumber, style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return _buildOTPField(index);
              }),
            ),
            SizedBox(height: 20),
            _buildResendSection(),
            SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Handle more options logic
              },
              child: Text('Try more options',style: TextStyle(color: Colors.deepOrangeAccent)),
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                // Go back to login methods
                Navigator.pop(context); // Navigate back to the login screen
              },
              child: Text(
                'Go back to login methods',
                style: TextStyle(decoration: TextDecoration.underline,color: Colors.deepOrangeAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOTPField(int index) {
    return SizedBox(
      width: 40,
      child: TextField(
        controller: _otpControllers[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '', // Removes character count indicator
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder( // Set the border color when the field is focused (tapped)
            borderSide: BorderSide(color: Colors.deepOrangeAccent),
          ),
          enabledBorder: OutlineInputBorder( // Normal border color when not focused
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          }
        },
      ),
    );
  }


  Widget _buildResendSection() {
    return Column(
      children: [
        Text(
          _remainingTime > 0
              ? 'Didn\'t get the OTP? Wait $_remainingTime seconds'
              : 'Didn\'t get the OTP?',style: TextStyle(color: Colors.deepOrangeAccent)
        ),
        if (_remainingTime == 0)
          TextButton(
            onPressed: () {
              // Reset the timer and allow resending OTP
              _startTimer();
              // Logic to resend the OTP
            },
            child: Text('Resend OTP',style: TextStyle(color: Colors.deepOrangeAccent),),
          ),
      ],
    );
  }

  Future<void> _verifyOTP() async {
    String otp = _otpControllers.map((controller) => controller.text.trim()).join();
    if (otp.length == 6) {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      try {
        await _auth.signInWithCredential(credential);
        // Navigate to the CompleteProfilePage after successful OTP verification
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CompleteProfilePage()),
        );
      } catch (e) {
        _showErrorDialog('Invalid OTP');
      }
    } else {
      _showErrorDialog('Please enter a valid 6-digit OTP.');
    }
  }


  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}
