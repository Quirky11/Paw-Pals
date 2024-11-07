import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pets_app/admin%20section/application_details.dart';

class AdminApprovalPage extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Approvals')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('approvals').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No approvals available'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot approval = snapshot.data!.docs[index];
              String documentId = approval.id;
              String userId = approval['userId'];
              String status = approval['status'];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('User ID: $userId'),
                  subtitle: Text('Status: $status'),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ApplicationDetailsPage(documentId: documentId, responses: {},),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
