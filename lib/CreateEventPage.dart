import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:country_picker/country_picker.dart';

class Event {
  final String eventName;
  final String eventLocation;
  final String eventType;
  final DateTime eventDate;
  final TimeOfDay eventTime;
  final String inviterName;
  final int numberOfInvitees;
  final List<String> inviteesPhoneNumbers;
  Event({
    required this.eventName,
    required this.eventLocation,
    required this.eventType,
    required this.eventDate,
    required this.eventTime,
    required this.inviterName,
    required this.numberOfInvitees,
    required this.inviteesPhoneNumbers,
  });
}

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({Key? key}) : super(key: key);

  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _eventNameController;
  late TextEditingController _eventLocationController;
  late TextEditingController _eventTypeController;
  late TextEditingController _inviterNameController;
  late TextEditingController _numberOfInviteesController;
  late DateTime _selectedDate = DateTime.now();
  late TimeOfDay _selectedTime = TimeOfDay.now();
  late List<TextEditingController> _inviteesPhoneControllers;
  Country selectedCountry = Country(
      phoneCode: "966",
      countryCode: "SA",
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: "SaudiArabia",
      example: "SaudiArabia",
      displayName: "SaudiArabia",
      displayNameNoCountryCode: "KSA",
      e164Key: "");

  void showCustomCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      countryFilter: <String>['SA', 'US', 'AE'],
      onSelect: (Country country) {
        setState(() {
          selectedCountry = country;
        });
      },
      countryListTheme: const CountryListThemeData(bottomSheetHeight: 500),
    );
  }

  @override
  void initState() {
    super.initState();
    _eventNameController = TextEditingController();
    _eventLocationController = TextEditingController();
    _eventTypeController = TextEditingController();
    _inviterNameController = TextEditingController();
    _numberOfInviteesController = TextEditingController();
    _inviteesPhoneControllers = [TextEditingController()];
    // Fetch user data and autofill inviter name
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Retrieve the user document from Firestore
      DocumentSnapshot<Map<String, dynamic>> userData = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(user.uid)
          .get();

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
    for (var controller in _inviteesPhoneControllers) {
      controller.dispose();
    }
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

  void _createEventAndSendInvitations() {
    if (_formKey.currentState!.validate()) {
      // Extract phone numbers into a list
      List<String> phoneNumbers = _inviteesPhoneControllers
          .map((controller) => controller.text.trim())
          .where((number) => number.isNotEmpty)
          .toList();

      // Retrieve the host user ID
      String userId = FirebaseAuth.instance.currentUser!.uid;
      // Create an Event object
      Event event = Event(
        eventName: _eventNameController.text,
        eventLocation: _eventLocationController.text,
        eventType: _eventTypeController.text,
        eventDate: _selectedDate,
        eventTime: _selectedTime,
        inviterName: _inviterNameController.text,
        numberOfInvitees: int.parse(_numberOfInviteesController.text),
        inviteesPhoneNumbers: phoneNumbers,
      );

      // Save the event data to Firestore
      FirebaseFirestore.instance.collection('events').add({
        'eventName': event.eventName,
        'eventLocation': event.eventLocation,
        'eventType': event.eventType,
        'eventDateTime': Timestamp.fromDate(DateTime(
            event.eventDate.year,
            event.eventDate.month,
            event.eventDate.day,
            event.eventTime.hour,
            event.eventTime.minute)),
        'inviterName': event.inviterName,
        'numberOfInvitees': event.numberOfInvitees,
        'inviteesPhoneNumbers': event.inviteesPhoneNumbers,
        'userId': userId,
      }).then((value) {
        _sendSMSInvitations(phoneNumbers);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Event created and invitations sent successfully!')),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to create event. Please try again.')),
        );
      });
    }
  }

  void _sendSMSInvitations(List<String> phoneNumbers) {
    String message = "You're invited to ${_eventNameController.text} on "
        "${_selectedDate.toIso8601String()}. Please join us.";
    sendSMS(message: message, recipients: phoneNumbers).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send invitations: $error')),
      );
    });
  }

  Widget _buildPhoneNumberField(int index) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 5, 10),
        child: TextFormField(
          controller: _inviteesPhoneControllers[index],
          cursorColor: const Color(0xFF9a85a4),
          keyboardType: TextInputType.phone,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
              labelText: 'Invitee ${index + 1} Phone Number',
              labelStyle: const TextStyle(color: Color(0xFF9a85a4)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              fillColor: const Color(0xFF9a85a4).withOpacity(0.1),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide:
                    BorderSide(color: const Color(0xFF9a85a4).withOpacity(0.0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide:
                    BorderSide(color: const Color(0xFF9a85a4).withOpacity(0.6)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: Colors.red),
              ),
              filled: true,
              prefixIcon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: InkWell(
                  onTap: () {
                    showCustomCountryPicker(context);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        selectedCountry.flagEmoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${selectedCountry.phoneCode}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 113, 113, 113),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          validator: (value) {
            // Check if the value is empty
            if (value == null || value.isEmpty) {
              return 'Required phone number.';
            }

            // Specific checks for the UAE
            if (selectedCountry.countryCode == 'AE' &&
                !(value.startsWith('5') && value.length == 9)) {
              return 'Please enter 9-digit number e.g. 5XXXXXXXX.';
            }
            // Specific checks for Saudi Arabia
            if (selectedCountry.countryCode == 'SA' &&
                !(value.startsWith('5') && value.length == 9)) {
              return 'Please enter 9-digit number e.g. 5XXXXXXXX.';
            }
            // Specific checks for the USA
            if (selectedCountry.countryCode == 'US' && value.length != 10) {
              return 'Please enter 10-digit number.';
            }
            return null;
          },
        ));
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
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(
            mainAxisSize: MainAxisSize
                .min, // Use this to make sure the children of the Row are at the center.
            children: [
              Image.asset(
                'assets/Logo.PNG', // Replace 'your_image.png' with your image asset path
                height: 30, // Adjust the height as needed
              ),
              const SizedBox(
                  width: 8), // Add some space between the image and the title
              const Text(
                'Maazim',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Create Event",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    8, 0, 5, 0), // 16 pixels left padding
                //First
                child: TextFormField(
                  controller: _eventNameController,
                  decoration: InputDecoration(
                    labelText: 'Event Name',
                    labelStyle:
                        const TextStyle(color: Color(0xFF9a85a4), fontSize: 14),
                    errorStyle: const TextStyle(fontSize: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: const Color(0xFF9a85a4).withOpacity(0.1),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                          color: const Color(0xFF9a85a4).withOpacity(0.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                          color: const Color(0xFF9a85a4).withOpacity(0.6)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 5, 0),
                child: TextFormField(
                  controller: _eventLocationController,
                  decoration: InputDecoration(
                    labelText: 'Event Location',
                    labelStyle:
                        const TextStyle(color: Color(0xFF9a85a4), fontSize: 14),
                    errorStyle: const TextStyle(fontSize: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: const Color(0xFF9a85a4).withOpacity(0.1),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                          color: const Color(0xFF9a85a4).withOpacity(0.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                          color: const Color(0xFF9a85a4).withOpacity(0.6)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    filled: true,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.link),
                      onPressed: _openLocation,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event location';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 5, 0),
                child: TextFormField(
                  controller: _eventTypeController,
                  decoration: InputDecoration(
                    labelText: 'Event Type',
                    labelStyle:
                        const TextStyle(color: Color(0xFF9a85a4), fontSize: 14),
                    errorStyle: const TextStyle(fontSize: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: const Color(0xFF9a85a4).withOpacity(0.1),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                          color: const Color(0xFF9a85a4).withOpacity(0.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                          color: const Color(0xFF9a85a4).withOpacity(0.6)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter event type';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 5, 0),
                      child: GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: TextEditingController(
                                text:
                                    '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}'),
                            decoration: InputDecoration(
                              labelText: 'Event Date',
                              labelStyle: const TextStyle(
                                  color: Color(0xFF9a85a4), fontSize: 14),
                              errorStyle: const TextStyle(fontSize: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              fillColor:
                                  const Color(0xFF9a85a4).withOpacity(0.1),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                    color: const Color(0xFF9a85a4)
                                        .withOpacity(0.0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                    color: const Color(0xFF9a85a4)
                                        .withOpacity(0.6)),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              filled: true,
                            ),
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
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 6, 0),
                      child: GestureDetector(
                        onTap: () => _selectTime(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            controller: TextEditingController(
                                text:
                                    '${_selectedTime.hour}:${_selectedTime.minute}'),
                            decoration: InputDecoration(
                              labelText: 'Event Time',
                              labelStyle: const TextStyle(
                                  color: Color(0xFF9a85a4), fontSize: 14),
                              errorStyle: const TextStyle(fontSize: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              fillColor:
                                  const Color(0xFF9a85a4).withOpacity(0.1),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                    color: const Color(0xFF9a85a4)
                                        .withOpacity(0.0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide(
                                    color: const Color(0xFF9a85a4)
                                        .withOpacity(0.6)),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              filled: true,
                            ),
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
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 5, 0),
                child: TextFormField(
                  controller: _inviterNameController,
                  decoration: InputDecoration(
                    labelText: 'Name of Inviter',
                    labelStyle:
                        const TextStyle(color: Color(0xFF9a85a4), fontSize: 14),
                    errorStyle: const TextStyle(fontSize: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: const Color(0xFF9a85a4).withOpacity(0.1),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                          color: const Color(0xFF9a85a4).withOpacity(0.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                          color: const Color(0xFF9a85a4).withOpacity(0.6)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 5, 0),
                child: TextFormField(
                  controller: _numberOfInviteesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Number of Invitees',
                    labelStyle:
                        const TextStyle(color: Color(0xFF9a85a4), fontSize: 14),
                    errorStyle: const TextStyle(fontSize: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: const Color(0xFF9a85a4).withOpacity(0.1),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                          color: const Color(0xFF9a85a4).withOpacity(0.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(
                          color: const Color(0xFF9a85a4).withOpacity(0.6)),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    filled: true,
                  ),
                  onChanged: (value) {
                    final count = int.tryParse(value) ?? 1;
                    if (count != _inviteesPhoneControllers.length) {
                      setState(() {
                        _inviteesPhoneControllers = List.generate(
                          count,
                          (index) => _inviteesPhoneControllers.length > index
                              ? _inviteesPhoneControllers[index]
                              : TextEditingController(),
                        );
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter number of invitees';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),
              ...List.generate(
                _inviteesPhoneControllers.length,
                (index) => _buildPhoneNumberField(index),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: _createEventAndSendInvitations,
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF9a85a4).withOpacity(0.9),
                  ),
                  child: const Text(
                    'Create',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
