import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailedApplicationReviewPage extends StatelessWidget {
  final String email;

  DetailedApplicationReviewPage({required this.email});

  Future<Map<String, dynamic>> _fetchApplicationData() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('pet_walker_applications')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final document = querySnapshot.docs.first;
      final data = document.data();
      final responses = data['responses'] as Map<String, dynamic>? ?? {};
      responses['reviewStatus'] = data['status'] ?? 'Pending';
      return responses;
    }
    return {};
  }

  Widget _buildQuestionAnswerPair(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            answer.isNotEmpty ? answer : 'N/A',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          Divider(color: Colors.grey[300]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Application Review'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchApplicationData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != null) {
            final applicationData = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Status: ${applicationData['reviewStatus']}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildQuestionAnswerPair(
                      "Are you comfortable administering medications if needed?",
                      applicationData['Are you comfortable administering medications if needed?'] ?? '',
                    ),
                    _buildQuestionAnswerPair(
                      "Describe a challenging situation you’ve had with a pet and how you resolved it.",
                      applicationData['Describe a challenging situation you’ve had with a pet and how you resolved it.'] ?? '',
                    ),
                    _buildQuestionAnswerPair(
                      "How would you handle a pet that shows signs of aggression?",
                      applicationData['How would you handle a pet that shows signs of aggression?'] ?? '',
                    ),
                    _buildQuestionAnswerPair(
                      "Do you have any special skills or services to offer (e.g., pet training, grooming)?",
                      applicationData['Do you have any special skills or services to offer (e.g., pet training, grooming)?'] ?? '',
                    ),
                    _buildQuestionAnswerPair(
                      "Why do you want to be a pet walker with Paw Pals?",
                      applicationData['Why do you want to be a pet walker with Paw Pals?'] ?? '',
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(
              child: Text(
                'No application found for this email.',
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            );
          }
        },
      ),
    );
  }
}
