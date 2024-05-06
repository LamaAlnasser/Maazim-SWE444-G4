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
import 'package:intl/intl.dart'; 
import 'package:maazim/CreateEventPage.dart';
import 'package:contacts_service/contacts_service.dart';


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
   late TextEditingController _phoneController; 
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
   _phoneController = TextEditingController();
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
             _sendNotificationsToInvitees1(); // To send FCM notifications
      _notifyLocalUpdate1(); // Local notification


      } catch (e) {
        print('Failed to update event: $e');
      }
    }
  }
 void _sendNotificationsToInvitees1() async {
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

void _notifyLocalUpdate1() {
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
          Container(
            child: Column(
               children: [
          // Existing form fields here
          _buildAddPhoneField(),
          _buildContactList(),
          // Additional UI components and logic
              ],
             ),
          )
            ,SizedBox(height: 20),Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 5, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                      child: Text(
                        'Event Duration (1 to 10 hours)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9a85a4),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                      decoration: BoxDecoration(
                        color: Color(0xFF9a85a4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.remove,
                            ),
                            onPressed: () {
                              setState(() {
                                if (_eventDuration > 1) _eventDuration--;
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              '$_eventDuration hours',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFF9a85a4)),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add,
                            ),
                            onPressed: () {
                              if (_eventDuration < 10) {
                                setState(() => _eventDuration++);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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

// Define variables for managing contacts
List<Contact> _selectedContacts = [];
TextEditingController _searchController = TextEditingController();
String _errorMessage = '';

String _cleanPhoneNumber(String phoneNumber) {
  return phoneNumber.replaceAll(RegExp(r'[^\d+]'), ''); // Keep only digits and '+'.
}

bool _validatePhoneNumber(String phoneNumber) {
  // Simple validation rule; adjust as necessary.
  return phoneNumber.length >= 10;
}

void _addPhoneNumber(String phoneNumber) {
  String cleanedNumber = _cleanPhoneNumber(phoneNumber);
  if (_validatePhoneNumber(cleanedNumber)) {
    Contact newContact = Contact(
      displayName: "Custom Number",
      phones: [Item(label: "mobile", value: cleanedNumber)],
    );
    if (!_selectedContacts.contains(newContact)) {
      setState(() {
        _selectedContacts.add(newContact);
      });
    } else {
      _errorMessage = 'Duplicate number';
      // Consider showing a message or handling duplicates differently.
    }
  } else {
    _errorMessage = 'Invalid phone number';
    // Handle invalid number entry.
  }
}
Widget _buildContactList() {
  return Container(
    height: 100, // Adjust height as needed
    child: ListView.builder(
      itemCount: _selectedContacts.length,
      itemBuilder: (context, index) {
        Contact contact = _selectedContacts[index];
        return ListTile(
          title: Text(contact.displayName ?? "No Name"),
          subtitle: Text(contact.phones?.first.value ?? "No Number"),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => setState(() => _selectedContacts.removeAt(index)),
          ),
        );
      },
    ),
  );
}

Widget _buildAddPhoneField() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(8, 0, 5, 0),
    child: TextField(
      controller: TextEditingController(),
      decoration: InputDecoration(
        labelText: 'Add Phone Number',
        suffixIcon: IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            _addPhoneNumber(_phoneController.text);
            _phoneController.clear();
          },
        ),
      ),
      keyboardType: TextInputType.phone,
      onSubmitted: (value) {
        _addPhoneNumber(value);
      },
    ),
  );
}


  @override
  void dispose() {
    _eventNameController.dispose();
    _eventTypeController.dispose();
    _eventLocationController.dispose();
    _eventAddressController.dispose();
   _numberOfInviteesController.dispose();
   _phoneController.dispose(); // Dispose controller when the widget is disposed
    super.dispose();
  }


}
