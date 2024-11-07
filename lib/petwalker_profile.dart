import 'package:flutter/material.dart';
import 'package:pets_app/booking_page.dart';

class PetWalkerProfilePage extends StatelessWidget {
  final String profileImage;
  final String name;
  final String bio;
  final double? rating; // null if no rating
  final String experience;
  final String email;
  final String phoneNumber;
  final String address;
  final double feePerHour; // new field for the charging fee per hour
  final List<String> reviews; // list of reviews, empty if none
  final bool hasBeenBooked; // to track if the walker has been booked before

  PetWalkerProfilePage({
    required this.profileImage,
    required this.name,
    required this.bio,
    this.rating,
    required this.experience,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.feePerHour,
    this.reviews = const [],
    this.hasBeenBooked = false,
  });

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
                image: AssetImage('assets/images/background.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Profile content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(profileImage),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 6,
                        color: Colors.black45,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  color: Colors.white.withOpacity(0.8),
                  elevation: 5,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfileField('Bio', bio),
                        _buildRatingSection(),
                        _buildProfileField('Experience', experience),
                        _buildProfileField('Email', email),
                        _buildProfileField('Phone', phoneNumber),
                        _buildProfileField('Address', address),
                        _buildProfileField('Fee Per Hour', '\$$feePerHour'), // Display fee per hour
                        _buildReviewsSection(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BookingPage(feePerHour: feePerHour),
                  ),
                );
              },
              child: Text('Book a Slot'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileField(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            content,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    if (reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'New',
          style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Colors.orange),
        ),
      );
    } else if (rating != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(Icons.star, color: Colors.orange),
            SizedBox(width: 5),
            Text(
              rating!.toString(),
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    } else {
      return SizedBox.shrink(); // No rating section displayed if no rating and not "New"
    }
  }

  Widget _buildReviewsSection() {
    if (reviews.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reviews',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ...reviews.map((review) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Text(review),
          )),
        ],
      );
    } else {
      return Text(
        'No reviews yet.',
        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
      );
    }
  }
}
