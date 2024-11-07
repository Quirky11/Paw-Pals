import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookingConfirmationPage extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final int selectedHours;
  final String petWalkerContact;
  final double totalAmount;
  final String petWalkerName;
  final double petWalkerRating;
  final String petWalkerExperience;
  final bool isConfirmed;

  BookingConfirmationPage({
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedHours,
    required this.totalAmount,
    required this.petWalkerContact,
    required this.petWalkerName,
    required this.petWalkerRating,
    required this.petWalkerExperience,
    required this.isConfirmed,
  });

  String get formattedDate => DateFormat('yyyy-MM-dd').format(selectedDate);
  String getFormattedTime(BuildContext context) => selectedTime.format(context);

  @override
  Widget build(BuildContext context) {
    final bool isExpired = DateTime.now().isAfter(
      DateTime(selectedDate.year, selectedDate.month, selectedDate.day,
          selectedTime.hour, selectedTime.minute)
          .subtract(Duration(hours: 12)),
    );

    return Scaffold(
      backgroundColor: Colors.grey[400],
      body: Stack(
        children: [
          // Gradient Background
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.4)],
              ),
              image: DecorationImage(
                image: AssetImage('assets/images/background.jpeg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken),
              ),
            ),
          ),
          // Content Card
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7), // Change to white
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pet Walker Info with Frosted Glass Effect
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white, // Change to white for the overlay
                          borderRadius: BorderRadius.circular(15),
                          backgroundBlendMode: BlendMode.lighten, // Add this line for a lighter effect
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage('assets/images/petwalker.jpeg'),
                              radius: 35,
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    petWalkerName,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black, // Change to black
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.orange, size: 18),
                                      SizedBox(width: 5),
                                      Text(
                                        '$petWalkerRating ★ - $petWalkerExperience',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87, // Change to a darker color
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      // Booking Summary with Icons
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Booking Summary',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Change to black
                            ),
                          ),
                          SizedBox(height: 15),
                          bookingDetailRow(Icons.calendar_today, 'Date', formattedDate),
                          bookingDetailRow(Icons.access_time, 'Time', getFormattedTime(context)),
                          bookingDetailRow(Icons.timer, 'Duration', '$selectedHours hours'),
                          bookingDetailRow(Icons.attach_money, 'Total Amount', '\$${totalAmount.toStringAsFixed(2)}'),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Status Indicator and Message Button
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: isConfirmed ? Colors.green : isExpired ? Colors.red : Colors.orange,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text(
                                  isConfirmed ? 'Approved' : isExpired ? 'Expired' : 'Pending Approval',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Action to message walker
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: Icon(Icons.message, color: Colors.white),
                              label: Text(
                                'Message Walker',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
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

  Widget bookingDetailRow(IconData icon, String title, String detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 24),
          SizedBox(width: 10),
          Text(
            '$title: ',
            style: TextStyle(fontSize: 18, color: Colors.black87), // Change to a darker color
          ),
          Expanded(
            child: Text(
              detail,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black), // Change to black
            ),
          ),
        ],
      ),
    );
  }
}
