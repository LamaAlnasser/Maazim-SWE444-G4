import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maazim/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class cWelcomePage extends StatefulWidget {
  final String eventID;

  const cWelcomePage({Key? key, required this.eventID}) : super(key: key);

  @override
  _cWelcomePageState createState() => _cWelcomePageState();
}

class _cWelcomePageState extends State<cWelcomePage> {
  String _eventName = '';
  DateTime _eventDate = DateTime.now();
  String _eventTime = '';
  String _formattedDate = ''; // Add a new variable for the formatted date
  String _countdown = ''; // Add a variable for the countdown
  Timer? _timer; // Add a Timer variable
  String _eventStatus = ''; // Variable to display the event status message

  @override
  void initState() {
    super.initState();
    _fetchEventDetails();
    _startCountdown(); // Start the countdown when the widget initializes
  }

  void _fetchEventDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> eventDoc = await FirebaseFirestore
          .instance
          .collection('events')
          .doc(widget.eventID)
          .get();

      if (eventDoc.exists) {
        Map<String, dynamic>? eventData = eventDoc.data();

        setState(() {
          _eventName = eventData?['eventName'] ?? 'No event name';
          Timestamp eventTimestamp =
              eventData?['eventDateTime'] as Timestamp? ?? Timestamp.now();
          _eventDate = eventTimestamp.toDate();
          _eventTime = TimeOfDay.fromDateTime(_eventDate).format(context);

          // Format the date to a human-readable form
          _formattedDate = DateFormat('dd MMMM yyyy').format(
              _eventDate); // Using 'DateFormat' from 'package:intl/intl.dart'
        });
      } else {
        print('No document found for event ID: ${widget.eventID}');
      }
    } catch (e) {
      print('Error fetching event details: $e');
    }
  }

  void _startCountdown() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      final now = DateTime.now();
      if (now.isAfter(_eventDate)) {
        _timer?.cancel();
        setState(() {
          _eventStatus =
              'The event has started!'; // Message indicating the event has started
          _countdown = '00:00:00:00'; // Reset the countdown to zero
        });
      } else {
        setState(() {
          Duration difference = _eventDate.difference(now);
          String twoDigits(int n) => n.toString().padLeft(2, '0');
          final days = twoDigits(difference.inDays);
          final hours = twoDigits(difference.inHours.remainder(24));
          final minutes = twoDigits(difference.inMinutes.remainder(60));
          final seconds = twoDigits(difference.inSeconds.remainder(60));
          _countdown = '$days:$hours:$minutes:$seconds';
        });
      }
    });
  }

  Widget _buildTimeBox(String value, String label,
      {double width = 80, double height = 80}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: width,
          height: height,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 28, // Adjust font size here
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 4),
        Text(label)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Duration timeLeft = _eventDate.difference(DateTime.now());
    // Convert the duration into individual components
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final days = timeLeft.isNegative ? '00' : twoDigits(timeLeft.inDays);
    final hours =
        timeLeft.isNegative ? '00' : twoDigits(timeLeft.inHours.remainder(24));
    final minutes = timeLeft.isNegative
        ? '00'
        : twoDigits(timeLeft.inMinutes.remainder(60));
    final seconds = timeLeft.isNegative
        ? '00'
        : twoDigits(timeLeft.inSeconds.remainder(60));

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_eventName.isNotEmpty) ...[
              Text('$_eventName',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              SizedBox(height: 1),
              Text(' $_formattedDate, $_eventTime',
                  style: TextStyle(fontSize: 18)), // Display the formatted date
              SizedBox(height: 30),
            ],
            // Custom countdown timer
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16.0), // Add padding to the sides
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTimeBox(days, 'DAYS'),
                  _buildTimeBox(hours, 'HOURS'),
                  _buildTimeBox(minutes, 'MINUTES'),
                  _buildTimeBox(seconds, 'SECONDS'),
                ],
              ),
            ),
            if (_eventStatus.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  _eventStatus,
                  style: TextStyle(
                    color:
                        Color(0xFF006400), // Color for the event status message
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            SizedBox(height: 50), // Space before logout button

            // Logout Button
            ElevatedButton(
              onPressed: () async {
                // Show the logout confirmation dialog
                bool confirmLogout = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Center(
                        child: Text(
                          "Logout",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Are you sure you want to log out?",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(
                                false); // Return false if user chooses "No"
                          },
                          style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            backgroundColor: Color(0xFF9a85a4).withOpacity(0.9),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pop(true); // Return true if user chooses "Yes"
                          },
                          style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(),
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 16),
                            backgroundColor: Color(0xFF9a85a4).withOpacity(0.9),
                          ),
                          child: Text(
                            "OK",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
                // If the user confirms the logout, sign out and navigate to the main page
                if (confirmLogout) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => MyApp()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                backgroundColor: Color(0xFF9a85a4).withOpacity(0.9),
              ),
              child: Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
