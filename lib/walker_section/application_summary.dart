import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pets_app/walker_section/application_review.dart';

class ApplicationSummaryPage extends StatelessWidget {
  final String email;

  ApplicationSummaryPage({required this.email});

  Future<Map<String, dynamic>> _fetchApplicationSummary() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('pet_walker_applications')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final document = querySnapshot.docs.first;
      final data = document.data();
      return {
        'firstName': data['firstName'] ?? 'N/A',
        'email': data['email'] ?? 'N/A',
        'status': data['status'] ?? 'Pending',
        'timestamp': data['timestamp'] ?? Timestamp.now(),
      };
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpeg'), // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Semi-transparent overlay for readability
          Container(
            color: Colors.black.withOpacity(0.6), // Adjust opacity as needed
          ),
          // Content
          FutureBuilder<Map<String, dynamic>>(
            future: _fetchApplicationSummary(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData && snapshot.data != null) {
                final applicationData = snapshot.data!;
                final DateTime timestamp = (applicationData['timestamp'] as Timestamp).toDate();
                final formattedTimestamp = "${timestamp.day}/${timestamp.month}/${timestamp.year}";

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Application details card
                        Card(
                          elevation: 8,
                          color: Colors.white.withOpacity(0.9), // Slight transparency
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Application Summary",
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orangeAccent,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  "First Name: ${applicationData['firstName']}",
                                  style: TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                                Text(
                                  "Email: ${applicationData['email']}",
                                  style: TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                                Text(
                                  "Status: ${applicationData['status']}",
                                  style: TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                                Text(
                                  "Submitted on: $formattedTimestamp",
                                  style: TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Button to review application
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailedApplicationReviewPage(email: email),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orangeAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                          ),
                          child: Text(
                            "Review My Application",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        // Note and icon at the bottom
                        Column(
                          children: [
                            Text(
                              "Note: Your application will be reviewed within 1-2 working days.",
                              style: TextStyle(fontSize: 14, color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Thank you for applying!",
                              style: TextStyle(fontSize: 14, color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Team Paw Pals",
                                  style: TextStyle(fontSize: 14, color: Colors.white70),
                                ),
                                SizedBox(width: 5),
                                Icon(
                                  Icons.pets,
                                  color: Colors.blue,
                                  size: 18,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return Center(
                  child: Text(
                    'No application found for this email.',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
