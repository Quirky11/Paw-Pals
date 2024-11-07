import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pets_app/booking_confirmation.dart';

class BookingPage extends StatefulWidget {
  final double feePerHour;

  BookingPage({required this.feePerHour});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  int selectedHours = 1;
  bool showSummary = false;

  double get totalAmount => selectedHours * widget.feePerHour;

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
          // Content layer
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withOpacity(0.6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Date Picker
                      Card(
                        color: Colors.white.withOpacity(0.8),
                        child: ListTile(
                          title: Text(
                            selectedDate == null
                                ? 'Select Date'
                                : DateFormat('yyyy-MM-dd').format(selectedDate!),
                            style: TextStyle(color: Colors.black),
                          ),
                          trailing: Icon(Icons.calendar_today, color: Colors.black),
                          onTap: _pickDate,
                        ),
                      ),
                      SizedBox(height: 20),
                      // Time Picker
                      Card(
                        color: Colors.white.withOpacity(0.8),
                        child: ListTile(
                          title: Text(
                            selectedTime == null
                                ? 'Select Time'
                                : selectedTime!.format(context),
                            style: TextStyle(color: Colors.black),
                          ),
                          trailing: Icon(Icons.access_time, color: Colors.black),
                          onTap: _pickTime,
                        ),
                      ),
                      SizedBox(height: 20),
                      // Hour Selector
                      Card(
                        color: Colors.white.withOpacity(0.8),
                        child: ListTile(
                          title: Text(
                            'Select Hours: $selectedHours',
                            style: TextStyle(color: Colors.black),
                          ),
                          trailing: Icon(Icons.timer, color: Colors.black),
                          onTap: _selectHours,
                        ),
                      ),
                      SizedBox(height: 20),
                      // Booking Summary
                      if (showSummary)
                        Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Card(
                            color: Colors.white.withOpacity(0.8),
                            child: Container(
                              padding: const EdgeInsets.all(20.0),
                              height: 250, // Increased height of the summary section
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Booking Summary',
                                    style: TextStyle(
                                      fontSize: 24, // Increased font size
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 15), // Adjusted spacing
                                  Text(
                                    'Date: ${selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : 'Not selected'}',
                                    style: TextStyle(
                                      fontSize: 18, // Increased font size
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Time: ${selectedTime != null ? selectedTime!.format(context) : 'Not selected'}',
                                    style: TextStyle(
                                      fontSize: 18, // Increased font size
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Hours: $selectedHours',
                                    style: TextStyle(
                                      fontSize: 18, // Increased font size
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20, // Increased font size
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      SizedBox(height: 10),
                      // Reset Button moved outside the summary box
                      if (showSummary)
                        Center(
                          child: ElevatedButton(
                            onPressed: _resetBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text('Reset Booking'),
                          ),
                        ),
                    ],
                  ),
                ),
                // Bottom section with total amount and send request button
                Container(
                  color: Colors.white.withOpacity(0.9),
                  padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${totalAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: (selectedDate != null && selectedTime != null)
                            ? _sendRequest
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Send Request'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _pickDate() async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now, // Prevent selecting past dates
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
        selectedTime = null; // Reset time selection when date changes
        _updateSummaryVisibility();
      });
    }
  }

  void _pickTime() async {
    TimeOfDay? pickedTime;
    DateTime now = DateTime.now();

    if (selectedDate != null && isSameDate(selectedDate!, now)) {
      // If the selected date is today, only allow future times
      pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      // Ensure the selected time is not in the past
      if (pickedTime != null) {
        DateTime selectedDateTime = DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (selectedDateTime.isBefore(now)) {
          pickedTime = null; // Invalidate the selected time if it’s in the past
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select a future time.')),
          );
        }
      }
    } else {
      // If the selected date is not today, allow any time
      pickedTime = await showTimePicker(
        context: context,
        initialTime: selectedTime ?? TimeOfDay.now(),
      );
    }

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
        _updateSummaryVisibility();
      });
    }
  }

  bool isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _selectHours() async {
    int? hours = await showDialog(
      context: context,
      builder: (context) {
        int tempHours = selectedHours;
        return AlertDialog(
          title: Text('Select Hours'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(tempHours.toString()),
                  Slider(
                    value: tempHours.toDouble(),
                    min: 1,
                    max: 24,
                    divisions: 23,
                    label: tempHours.toString(),
                    onChanged: (value) {
                      setState(() {
                        tempHours = value.toInt();
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(tempHours);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    if (hours != null) {
      setState(() {
        selectedHours = hours;
        _updateSummaryVisibility();
      });
    }
  }

  void _resetBooking() {
    setState(() {
      selectedDate = null;
      selectedTime = null;
      selectedHours = 1;
      showSummary = false;
    });
  }

  void _sendRequest() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookingConfirmationPage(
          selectedDate: selectedDate!,
          selectedTime: selectedTime!,
          selectedHours: selectedHours,
          totalAmount: totalAmount,
          petWalkerName: 'John Doe', // Example name, replace with actual data
          petWalkerContact: 'johndoe@example.com',
          petWalkerRating: 2,
          petWalkerExperience: '',
          isConfirmed: false, // Initial status as "Pending"
        ),
      ),
    );

    // Check if booking was confirmed 12 hours before the booking time
    DateTime bookingDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    DateTime responseDeadline = bookingDateTime.subtract(Duration(hours: 12));

    if (DateTime.now().isBefore(responseDeadline)) {
      // Display "Pending" until walker confirms the booking
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking is pending confirmation. It must be confirmed within 12 hours.')),
      );
    } else {
      // Add logic to cancel or notify user if not confirmed within 12 hours
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking response deadline missed. Please try again or contact support.')),
      );
    }
  }


  void _updateSummaryVisibility() {
    if (selectedDate != null && selectedTime != null) {
      setState(() {
        showSummary = true;
      });
    } else {
      setState(() {
        showSummary = false;
      });
    }
  }
}
