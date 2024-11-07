import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ApplicationDetailsPage extends StatelessWidget {
  final String documentId;
  final Map<String, dynamic> responses;

  ApplicationDetailsPage({required this.documentId, required this.responses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Application Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Application ID: $documentId', style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            ...responses.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('${entry.key}: ${entry.value}', style: TextStyle(fontSize: 16)),
            )),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Approve action
                    FirebaseFirestore.instance
                        .collection('pet_walker_applications')
                        .doc(documentId)
                        .update({'status': 'approved'});
                    Navigator.pop(context);
                  },
                  child: Text('Approve'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Deny action
                    FirebaseFirestore.instance
                        .collection('pet_walker_applications')
                        .doc(documentId)
                        .update({'status': 'denied'});
                    Navigator.pop(context);
                  },
                  child: Text('Deny'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
