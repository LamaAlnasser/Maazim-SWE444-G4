import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:country_picker/country_picker.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:maazim/Event.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Fo
import 'package:maazim/CreateEventPage.dart';


class EditEventPage extends StatefulWidget {
  final String eventId;

  const EditEventPage({Key? key, required this.eventId}) : super(key: key);

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  late Event event;

  late TextEditingController _eventNameController;
  late TextEditingController _eventAddressController;
  late TextEditingController _eventLocationController;
  late TextEditingController _eventTypeController;
  late TextEditingController _inviterNameController;
  late TextEditingController _numberOfInviteesController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  int _eventDuration = 1;

  @override
  void initState() {
    super.initState();
    fetchEventDetails();
  }

  void fetchEventDetails() async {
    DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
      .collection('events')
      .doc(widget.eventId)
      .get();

    if (eventSnapshot.exists) {
      event = Event.fromSnapshot(eventSnapshot);
      _initializeForm();
    } else {
      print("Event not found");
      Navigator.pop(context);
    }
  }

  void _initializeForm() {
    _eventNameController = TextEditingController(text: event.eventName);
    _eventAddressController = TextEditingController(text: event.address);
    _eventLocationController = TextEditingController(text: event.eventLocation);
    _eventTypeController = TextEditingController(text: event.eventType);
    _inviterNameController = TextEditingController(text: event.inviterName);
    _numberOfInviteesController = TextEditingController(text: event.numberOfInvitees.toString());
    _selectedDate = event.eventDate;
    _selectedTime = event.eventTime;
    _eventDuration = event.duration;
    bool _isLoading;
    setState(() => _isLoading = false);
  }

  void _updateEvent() async {
  
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('events').doc(widget.eventId).update({
          'eventName': _eventNameController.text,
          'address': _eventAddressController.text,
          'eventLocation': _eventLocationController.text,
          'eventType': _eventTypeController.text,
          'eventDateTime': Timestamp.fromDate(DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _selectedTime.hour,
            _selectedTime.minute,
          )),
          'inviterName': _inviterNameController.text,
          'numberOfInvitees': int.tryParse(_numberOfInviteesController.text) ?? 0,
          'duration': _eventDuration,
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Event updated successfully")));
        Navigator.pop(context);
             _sendNotificationsToInvitees(); // To send FCM notifications
      _notifyLocalUpdate(); // Local notification


      } catch (e) {
        print('Failed to update event: $e');
      }
    }
  }
 void _sendNotificationsToInvitees() async {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().microsecondsSinceEpoch.remainder(600000000),
      channelKey: 'basic_channel',
      title: '${event.eventName} Updated!',
      body: 'The event you are invited to has been updated. Please check the details.',
      notificationLayout: NotificationLayout.Default,
    ),
    actionButtons: [
      NotificationActionButton(
        key: 'OPEN_EVENT',
        label: 'View Event',
      ),
    ],
    // The schedule parameter is optional, use it if you want to schedule the notification
  );
}

void _notifyLocalUpdate() {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      channelKey: 'basic_channel',
      title: 'Event Updated',
      body: 'Your event has been updated. Check out the latest details!',
    ),
  );
}



@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Edit Event Details'),
      actions: [
        IconButton(
          icon: Icon(Icons.save),
          onPressed: _updateEvent,
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _eventNameController,
              decoration: InputDecoration(
                labelText: 'Event Name',
                prefixIcon: Icon(Icons.event),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                filled: true,
                fillColor: Color(0xFF9a85a4).withOpacity(0.1),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _eventLocationController,
              decoration: InputDecoration(
                labelText: 'Event Location Link',
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                filled: true,
                fillColor: Color(0xFF9a85a4).withOpacity(0.1),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _eventAddressController,
              decoration: InputDecoration(
                labelText: 'Event Address',
                prefixIcon: Icon(Icons.home),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                filled: true,
                fillColor: Color(0xFF9a85a4).withOpacity(0.1),
              ),
            ),
            SizedBox(height: 20),
     
            TextFormField(
              controller: _inviterNameController,
              decoration: InputDecoration(
                labelText: 'Inviter Name',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                filled: true,
                fillColor: Color(0xFF9a85a4).withOpacity(0.1),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _numberOfInviteesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Number of Invitees',
                prefixIcon: Icon(Icons.group),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                filled: true,
                fillColor: Color(0xFF9a85a4).withOpacity(0.1),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null && pickedDate != _selectedDate) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: TextEditingController(text: DateFormat('yyyy-MM-dd').format(_selectedDate)),
                  decoration: InputDecoration(
                    labelText: 'Event Date',
                    prefixIcon: Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    filled: true,
                    fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime,
                );
                if (pickedTime != null && pickedTime != _selectedTime) {
                  setState(() {
                    _selectedTime = pickedTime;
                  });
                }
              },
              child: AbsorbPointer(
                child: TextFormField(
                  controller: TextEditingController(text: _selectedTime.format(context)),
                  decoration: InputDecoration(
                    labelText: 'Event Time',
                    prefixIcon: Icon(Icons.access_time),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    filled: true,
                    fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Slider(
              value: _eventDuration.toDouble(),
              min: 1,
              max: 24,
              divisions: 23,
              label: '$_eventDuration hours',
              onChanged: (double value) {
                setState(() {
                  _eventDuration = value.toInt();
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9a85a4), // Button background color
                foregroundColor: Color.fromARGB(255, 255, 255, 255),
                shape: StadiumBorder(), // Rounded edges
              ),
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    ),
  );
}

}
