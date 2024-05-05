import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:maazim/Home_Host.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:country_picker/country_picker.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart';

//Emailing the host
//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
import 'package:sendgrid_mailer/sendgrid_mailer.dart';

class Event {
  final String eventName;
  final String address; // New property for address
  final String eventLocation;
  final String eventType;
  final DateTime eventDate;
  final TimeOfDay eventTime;
  final String inviterName;
  final int numberOfInvitees;
  final List<String> inviteesPhoneNumbers;
  final int duration; // Duration of the event in hours
  Event({
    required this.eventName,
    required this.address,
    required this.eventLocation,
    required this.eventType,
    required this.eventDate,
    required this.eventTime,
    required this.inviterName,
    required this.numberOfInvitees,
    required this.inviteesPhoneNumbers,
    required this.duration,
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
  late TextEditingController _eventAddressController;
  late TextEditingController _eventLocationController;
  late TextEditingController _eventTypeController;
  late TextEditingController _inviterNameController;
  late TextEditingController _numberOfInviteesController;
  int _eventDuration = 1; // Default duration is 1 hour
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
    _eventAddressController = TextEditingController();
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
    _eventAddressController.dispose();
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

      // Create a set from the list to identify duplicates
      final phoneNumbersSet = phoneNumbers.toSet();

      if (phoneNumbersSet.length != phoneNumbers.length) {
        // There are duplicates, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Duplicate phone numbers are not allowed.'),
            backgroundColor: Colors.red,
          ),
        );
        return; // Stop further execution
      }

      String eventLocation = _eventLocationController.text;
      bool isValidLocation = _isValidLocation(eventLocation);
      if (!isValidLocation) {
        // Show error message or handle invalid location format
        return;
      }

      // Get the current user
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String userId = user.uid;

        // Create an Event object
        Event event = Event(
            eventName: _eventNameController.text,
            address: _eventAddressController.text,
            eventLocation: _eventLocationController.text,
            eventType: _eventTypeController.text,
            eventDate: _selectedDate,
            eventTime: _selectedTime,
            inviterName: _inviterNameController.text,
            numberOfInvitees: int.parse(_numberOfInviteesController.text),
            inviteesPhoneNumbers: phoneNumbers,
            duration: _eventDuration);

        // Save the event data to Firestore
        FirebaseFirestore.instance.collection('events').add({
          'userId': userId,
          'eventName': event.eventName,
          'address': event.address, // Now saving address
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
          'duration': event.duration,
          'acceptedInvitees': [], // Initialize as empty list
          'rejectedInvitees': [], // Initialize as empty list
        }).then((value) {
          //Added
          // After the event is created, you have the event ID
          String eventId = value.id;
          String username = _generateUsername(eventId); // Using event ID
          String originalPass = generatePlaintextPassword(8);
          String password = generateHashedPassword(originalPass);

          // Save the coordinator credentials to a new collection
          FirebaseFirestore.instance.collection('coordinators').add({
            'eventId': eventId,
            'username': username,
            'password': password, // Hashing before saving
          }).then((_) {
            // Print credentials as log
            print(
                'Coordinator credentials - Username: $username, Password: $password');
            User? user = FirebaseAuth.instance.currentUser;
            String userEmail = user?.email ?? 'No email found';

            // Coordinator credentials saved, now send the email
            // sendEmailConfirmation(
            //   toEmail: userEmail, // Retrieved from the FirebaseAuth user object
            //   eventName: _eventNameController.text,
            //   eventAddress: _eventAddressController.text,
            //   eventDateTime: _selectedDate.add(Duration(
            //       hours: _selectedTime.hour,
            //       minutes: _selectedTime
            //           .minute)), // Converts selected date and time into a DateTime
            //   eventType: _eventTypeController.text,
            //   inviterName: _inviterNameController.text,
            //   numberOfInvitees:
            //       int.tryParse(_numberOfInviteesController.text) ??
            //           0, // Parses the number of invitees safely
            //   eventDuration:
            //       _eventDuration, // Already an integer, no need to convert to string
            //   coordinatorUsername:
            //       username, // Generated username for the coordinator
            //   coordinatorPassword:
            //       originalPass, // Generated password for the coordinator
            // );
//i didnt send email reomve the comments above to send
          });
          //Until here

          _sendSMSInvitations(phoneNumbers);
          _onEventCreatedSuccessfully();
        }).catchError((error) {});
      }
    }
  }

  //Added
  Future<void> sendEmailConfirmation({
    required String toEmail,
    required String eventName,
    required String eventAddress,
    required DateTime eventDateTime,
    required String eventType,
    required String inviterName,
    required int numberOfInvitees,
    required int eventDuration,
    required String coordinatorUsername,
    required String coordinatorPassword,
  }) async {
    try {
      final mailer = Mailer(
          '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');
      final toAddress = Address(toEmail);
      final fromAddress = Address(
          'MaazimTeam@outlook.com'); // Use your verified sender email here
      final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
      final timeFormat = DateFormat('h:mm a');
      final eventDate = dateFormat.format(eventDateTime);
      final eventTime = timeFormat.format(eventDateTime);

      final subject = 'Confirmation for "$eventName" Event';
      final content = Content(
          'text/plain',
          'Dear $inviterName,\n\n'
              'Great news - your event "$eventName" is all set to go! Below you\'ll find the key details for your event:\n\n'
              'Event Type: $eventType\n'
              'Date: $eventDate\n'
              'Time: $eventTime\n'
              'Duration: $eventDuration hour(s)\n'
              'Location: $eventAddress\n'
              'Guests: $numberOfInvitees attendees expected\n\n'
              'Coordinator Access\n'
              'To ensure smooth management of your event, please provide your entry coordinator with the credentials below:\n\n'
              'Username: $coordinatorUsername\n'
              'Password: $coordinatorPassword\n\n'
              'We\'re excited to be a part of your special day and look forward to helping you create memorable experiences.\n\n'
              'Warm regards,\n'
              'The Maazim Team');

      final personalization = Personalization([toAddress]);
      final email =
          Email([personalization], fromAddress, subject, content: [content]);

      final response = await mailer.send(email);
      //print("Email sent: ${response.message}");
    } catch (e) {
      print("Failed to send email: $e");
    }
  }

  //Added
  String _generateUsername(String eventId) {
    // Example: Use the event ID with some random text and append the domain
    return 'EC_$eventId@Maazim.com';
  }

  //Added
  // String _generatePassword() {
  //   // Generate a random password
  //   const length = 8;
  //   final random = Random.secure();
  //   const availableChars =
  //       'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  //   final password = List.generate(length,
  //           (index) => availableChars[random.nextInt(availableChars.length)])
  //       .join();

  //   // Print the original password just to debug
  //   print('Original Password: $password');

  //   // Hash the password
  //   var bytes = utf8.encode(password); // data being hashed
  //   var digest = sha256.convert(bytes);

  //   return digest.toString();
  // }

  String generatePlaintextPassword(int length) {
    const allowedChars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    final password = List.generate(length,
        (index) => allowedChars[random.nextInt(allowedChars.length)]).join();
    print('orginal pass  $password');
    return password;
  }

  String generateHashedPassword(String password) {
    final bytes = utf8.encode(password); // data being hashed
    final digest = sha256.convert(bytes);

    return digest.toString();
  }

  // Assuming this function is called afteraa successfully creating an event
  void _onEventCreatedSuccessfully() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const homePage()),
    );
  }

  bool _isValidLocation(String location) {
    if (location.isEmpty) {
      // Empty location is valid since it's optional
      return true;
    }

    // Regular expressions for Google Maps and iOS Maps links
    RegExp googleMapsRegex = RegExp(r'https:\/\/(www\.)?google\.com\/maps\/.*');
    RegExp googleMapsRegex1 = RegExp(r'https:\/\/maps\.app\.goo\.gl\/.*');
    RegExp iOSMapsRegex = RegExp(r'(maps:\/\/|http:\/\/maps\.apple\.com\/).*');
    RegExp iOSMapsRegex1 = RegExp(r'https:\/\/maps\.apple\.com\/?\/*');

    // Check if the location matches either of the formats
    return googleMapsRegex.hasMatch(location) ||
        googleMapsRegex1.hasMatch(location) ||
        iOSMapsRegex.hasMatch(location) ||
        iOSMapsRegex1.hasMatch(location);
  }

  Future<bool> _isValidMapLink(String link) async {
    // Check if the link starts with a valid Google Maps or iOS Maps URL
    return link.startsWith('https://maps.google.com/') ||
        link.startsWith('https://maps.apple.com/') ||
        link.startsWith('https://maps.app.goo.gl/');
  }

  void _sendSMSInvitations(List<String> phoneNumbers) {
    String message = "You're invited to ${_eventNameController.text} on "
        "${_selectedDate.toIso8601String()}. \n Please visit the Maazim application to accept or reject (RSVP) the invitation";
    sendSMS(message: message, recipients: phoneNumbers).catchError((error) {
      //ScaffoldMessenger.of(context).showSnackBar(
      //SnackBar(content: Text('Failed to send invitations: $error')),
      // );
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
              return 'Please enter phone number.';
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

            final duplicates = _inviteesPhoneControllers
                .where((controller) => controller.text.trim() == value.trim())
                .length;
            if (duplicates > 1) {
              return 'Duplicate phone number detected.';
            }
            return null; // If no duplicates are found, return null.
          },
        ));
  }

  void _openLocation() async {
    String url = _eventLocationController.text;
    if (await _isValidMapLink(url)) {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        // Handle error
      }
    } else {
      // Display error message for invalid map link
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Invalid Map Link',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content:
                Text('Please provide a valid Google Maps or iOS Maps link.'),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    backgroundColor: const Color(0xFF9a85a4)
                        .withOpacity(0.9), // Rounded corners
                  ),
                  child: const Text('OK',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255))),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  String? validateString(String? value, {int maxLength = 50}) {
    if (value == null || value.isEmpty) {
      return 'This field is required.';
    }
    if (value.length > maxLength) {
      return 'Maximum length exceeded. Maximum characters: $maxLength';
    }
    return null;
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
                    if (value.contains(RegExp(r'[0-9]'))) {
                      return 'Note: only letters.';
                    }
                    if (value.length > 30) {
                      return 'Maximum length exceeded. Maximum characters: 30';
                    }
                    return null;
                  },
                ),
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
                    if (value.length > 30) {
                      return 'Maximum length exceeded. Maximum characters: 30';
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
                    if (value.contains(RegExp(r'[0-9]'))) {
                      return 'Note: only letters.';
                    }
                    if (value.length > 30) {
                      return 'Maximum length exceeded. Maximum characters: 30';
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
              const SizedBox(height: 5),
              Padding(
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
                            icon: Icon(Icons.remove, color: Color(0xFF9a85a4)),
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
                            icon: Icon(Icons.add, color: Color(0xFF9a85a4)),
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
              const SizedBox(height: 10),
              // Insert the new address field here, before the event location field
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 5, 0),
                child: TextFormField(
                  controller: _eventAddressController,
                  decoration: InputDecoration(
                    labelText: 'Event Address',
                    hintText: 'street, district, city',
                    hintStyle: TextStyle(
                        color: Color.fromARGB(255, 199, 184, 207),
                        fontSize: 14),
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
                      return 'Please enter event address';
                    }
                    if (value.length > 50) {
                      return 'Maximum length exceeded. Maximum characters: 50';
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
                    labelText: 'Event Location Link (Optional)',
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
                    // Check if the value is empty
                    if (value == null || value.isEmpty) {
                      return null; // Return null for empty values since it's optional
                    }

                    // Check if the location is valid using the _isValidLocation function
                    if (!_isValidLocation(value)) {
                      return 'Please enter a Google Maps or iOS Maps link';
                    }

                    return null; // Return null if the location is valid
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
