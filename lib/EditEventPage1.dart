import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:country_picker/country_picker.dart';
import  'package:maazim/Event.dart';

class EditEventPage1 extends StatefulWidget {
  final String eventId;

  const EditEventPage1({Key? key, required this.eventId}) : super(key: key);

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage1> {
  late TextEditingController eventNameController;
  late TextEditingController eventDescriptionController;

  @override
  void initState() {
    super.initState();
    eventNameController = TextEditingController();
    eventDescriptionController = TextEditingController();
    fetchEventData();
  }

  void fetchEventData() async {
    try {
      // Fetch event data from Firestore
      DocumentSnapshot eventSnapshot =
          await FirebaseFirestore.instance.collection('events').doc(widget.eventId).get();
      // Set event data to the controllers
      setState(() {
        eventNameController.text = eventSnapshot['eventName'];
        eventDescriptionController.text = eventSnapshot['eventDescription'];
      });
    } catch (e) {
      // Handle errors
      print("Error fetching event data: $e");
    }
  }

  void updateEvent() async {
    try {
      // Update event data in Firestore
      await FirebaseFirestore.instance.collection('events').doc(widget.eventId).update({
        'eventName': eventNameController.text,
        'eventDescription': eventDescriptionController.text,
        // Add other fields you want to update
      });
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event updated successfully')),
      );
    } catch (e) {
      // Handle errors
      print("Error updating event: $e");
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update event. Please try again later.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: updateEvent,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Name',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: eventNameController,
              decoration: InputDecoration(
                hintText: 'Enter event name',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Event Description',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextFormField(
              controller: eventDescriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter event description',
              ),
            ),
            // Add more fields as needed
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    eventNameController.dispose();
    eventDescriptionController.dispose();
    super.dispose();
  }
}