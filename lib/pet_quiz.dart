import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pets_app/walker_section/application_summary.dart';
// Import the SummaryPage

class PetQuizPage extends StatefulWidget {
  final String userEmail; // Pass logged-in user email

  PetQuizPage({required this.userEmail});

  @override
  _PetQuizPageState createState() => _PetQuizPageState();
}

class _PetQuizPageState extends State<PetQuizPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, String> _responses = {};

  final List<Map<String, String>> _questions = [
    {'question': 'How long have you been walking pets?'},
    {'question': 'Do you have any certifications or training in pet care or animal handling?'},
    {'question': 'What types of pets have you worked with in the past?'},
    {'question': 'How many hours per week are you available for pet walking?'},
    {'question': 'How would you handle a pet that shows signs of aggression?'},
    {'question': 'Are you comfortable administering medications if needed?'},
    {'question': 'Describe a challenging situation you’ve had with a pet and how you resolved it.'},
    {'question': 'Do you have any special skills or services to offer (e.g., pet training, grooming)?'},
    {'question': 'Why do you want to be a pet walker with Paw Pals?'},
  ];

  Future<void> _checkAndSubmitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      try {
        // Check if user has already submitted an application
        final userQuery = await FirebaseFirestore.instance
            .collection('pet_walker_applications')
            .where('email', isEqualTo: widget.userEmail)
            .get();

        if (userQuery.docs.isEmpty) {
          await _submitForm();
        } else {
          _redirectToSummaryPage(widget.userEmail);
        }
      } catch (error) {
        print('Error checking submission status: $error');
        // Optionally, show an error message if necessary
      }
    }
  }

  Future<void> _submitForm() async {
    try {
      await FirebaseFirestore.instance.collection('pet_walker_applications').add({
        'responses': _responses,
        'submittedAt': Timestamp.now(),
        'status': 'pending',
        'email': widget.userEmail,
        'quizCompleted': true,
      });

      _redirectToSummaryPage(widget.userEmail);
    } catch (error) {
      print('Error submitting form: $error');
      // Show an error message here if necessary
    }
  }

  void _redirectToSummaryPage(String email) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ApplicationSummaryPage(email: email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pet Walker Quiz'),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView.builder(
                itemCount: _questions.length + 1,
                itemBuilder: (context, index) {
                  if (index < _questions.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _questions[index]['question']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Enter your answer here',
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.9),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Please answer this question';
                              return null;
                            },
                            onSaved: (value) => _responses[_questions[index]['question']!] =
                                value?.trim() ?? '',
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        onPressed: _checkAndSubmitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 18.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('Submit', style: TextStyle(fontSize: 18)),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
