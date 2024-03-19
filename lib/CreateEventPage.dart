import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';


class Event {
  final String eventName;
  final String eventLocation;
  final String eventType;
  final DateTime eventDate;
  final TimeOfDay eventTime;
  final String inviterName;
  final int numberOfInvitees;

  Event({
    required this.eventName,
    required this.eventLocation,
    required this.eventType,
    required this.eventDate,
    required this.eventTime,
    required this.inviterName,
    required this.numberOfInvitees,
  });
}

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({Key? key}) : super(key: key);

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  List<String> _inviteesPhoneNumbers = [];

  late TextEditingController _inviteePhoneNumberController;
  late TextEditingController _eventNameController;
  late TextEditingController _eventLocationController;
  late TextEditingController _eventTypeController;
  late TextEditingController _inviterNameController;
  late TextEditingController _numberOfInviteesController;
  late DateTime _selectedDate = DateTime.now();
  late TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _eventNameController = TextEditingController();
    _eventLocationController = TextEditingController();
    _eventTypeController = TextEditingController();
    _inviterNameController = TextEditingController();
    _numberOfInviteesController = TextEditingController();
     _inviteePhoneNumberController = TextEditingController();
    // Fetch user data and autofill inviter name
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Retrieve the user document from Firestore
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      // Extract first name from user data and autofill inviter name
      String firstName = userData.data()?['firstName'] ?? '';
      String lastName = userData.data()?['lastName'] ?? '';
      String fullName = '$firstName $lastName';
      _inviterNameController.text = fullName;
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventLocationController.dispose();
    _eventTypeController.dispose();
    _inviterNameController.dispose();
    _numberOfInviteesController.dispose();
    _inviteePhoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: _selectedTime);
    if (picked != null && picked != _selectedTime)
      setState(() {
        _selectedTime = picked;
      });
  }

  void _createEvent() {
    if (_formKey.currentState!.validate()) {
      Event event = Event(
        eventName: _eventNameController.text,
        eventLocation: _eventLocationController.text,
        eventType: _eventTypeController.text,
        eventDate: _selectedDate,
        eventTime: _selectedTime,
        inviterName: _inviterNameController.text,
        numberOfInvitees: int.parse(_numberOfInviteesController.text),
      );

      // Here you can save the event data to Firestore or perform any other actions.
      // For example:
      FirebaseFirestore.instance.collection('events').add({
        'eventName': event.eventName,
        'eventLocation': event.eventLocation,
        'eventType': event.eventType,
        'eventDateTime': Timestamp.fromDate(
            DateTime(event.eventDate.year, event.eventDate.month,
                event.eventDate.day, event.eventTime.hour, event.eventTime.minute)),
        'inviterName': event.inviterName,
        'numberOfInvitees': event.numberOfInvitees,
      });

      // Optionally, you can show a success message or navigate to another page.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event created successfully!'),
        ),
      );
    }
  }

  void _openLocation() async {
    String url = _eventLocationController.text;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Event'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _eventNameController,
                decoration: InputDecoration(labelText: 'Event Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _eventLocationController,
                      decoration: InputDecoration(labelText: 'Event Location'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter event location';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.link),
                    onPressed: _openLocation,
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _eventTypeController,
                decoration: InputDecoration(labelText: 'Event Type'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter event type';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: TextEditingController(
                              text: '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}'),
                          decoration: InputDecoration(labelText: 'Event Date'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select event date';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: TextEditingController(
                              text:
                                  '${_selectedTime.hour}:${_selectedTime.minute}'),
                          decoration: InputDecoration(labelText: 'Event Time'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select event time';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _inviterNameController,
                decoration: InputDecoration(labelText: 'Name of Inviter'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _numberOfInviteesController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Number of Invitees'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of invitees';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createEvent,
                child: Text('Create Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}