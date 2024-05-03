import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:maazim/Home_Host.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:country_picker/country_picker.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

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
  List<Contact> _allContacts = [];
  List<Contact> _selectedContacts = [];
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
  String _errorMessage = '';
  late TextEditingController _searchController;
 String? _selectedEventType; // For storing the selected event type
  List<String> _eventTypes = [
    'Conference',
    'Wedding',
    'Graduation',
    'Exhibition',
    'Birthday',
    'Party',
    'Other'
  ]; // Example event types

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

  void _checkPermissionsAndLoadContacts() async {
    var permissionStatus = await Permission.contacts.status;
    if (!permissionStatus.isGranted) {
      await Permission.contacts.request();
      permissionStatus = await Permission.contacts.status;
    }

    if (permissionStatus.isPermanentlyDenied) {
      _showPermissionDialog();
    } else if (await Permission.contacts.isGranted) {
      Iterable<Contact> contacts =
          await ContactsService.getContacts(withThumbnails: false);
      setState(() {
        _allContacts = contacts.toList();
      });
    } else {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Permission Required"),
          content:
              Text("This app requires contact access to function properly."),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Dismiss the dialog but do nothing
              },
            ),
            TextButton(
              child: Text("Settings"),
              onPressed: () {
                openAppSettings(); // Open app settings
              },
            ),
          ],
        );
      },
    );
  }

  void _scheduleReminder(Event event) {
  DateTime notificationTime = event.eventDate.subtract(Duration(days: 2));
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      channelKey: 'basic_channel',
      title: 'Upcoming Event Reminder',
      body: '${event.eventName} is happening soon on ${event.eventDate}',
      notificationLayout: NotificationLayout.BigText,
    ),
    schedule: NotificationCalendar.fromDate(date: notificationTime)
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
    _searchController = TextEditingController();
    _checkPermissionsAndLoadContacts();
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
    _searchController.dispose();
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

  void _createEventAndSendInvitations() async {
    if (_formKey.currentState!.validate()) {
      // Collect all phone numbers from selected contacts
      List<String> phoneNumbers = _selectedContacts
          .map(
              (contact) => _cleanPhoneNumber(contact.phones?.first.value ?? ""))
          .where((number) =>
              number.isNotEmpty) // Ensure no empty strings are added
          .toList();

      // Remove duplicates
      Set<String> uniquePhoneNumbers = Set.from(phoneNumbers);


    // Proceed only if the number of unique phone numbers matches the number of invitees
    final int numberOfInvitees = int.tryParse(_numberOfInviteesController.text) ?? 0;
    if (uniquePhoneNumbers.length != numberOfInvitees) {
      setState(() {
        _errorMessage = 'Number of selected invitees does not match the specified number.';
      });
         // Set a timer to clear the error message after 5 seconds
      Future.delayed(Duration(seconds: 5), () {
        setState(() {
          _errorMessage = ''; // Clear the error message
        });
      });
      return;
    }

      final DateTime selectedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      // Check for event conflicts before proceeding
      bool isEventConflict = await _checkEventConflict(selectedDateTime);
      if (isEventConflict) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Event Conflict'),
              content: Text(
                  'An event already exists at the selected date and time.'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF9a85a4).withOpacity(0.9),
                  ),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
        return;
      }

      // No conflicts, proceed with event creation
      Event newEvent = Event(
        eventName: _eventNameController.text,
        address: _eventAddressController.text,
        eventLocation: _eventLocationController.text,
        eventType: _eventTypeController.text,
        eventDate: _selectedDate,
        eventTime: _selectedTime,
        inviterName: _inviterNameController.text,
        numberOfInvitees: numberOfInvitees,
        inviteesPhoneNumbers: uniquePhoneNumbers.toList(),
        duration: _eventDuration,
      );

      // Add event to Firestore
      FirebaseFirestore.instance.collection('events').add({
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'eventName': newEvent.eventName,
        'address': newEvent.address,
        'eventLocation': newEvent.eventLocation,
        'eventType': newEvent.eventType,
        'eventDateTime': Timestamp.fromDate(selectedDateTime),
        'inviterName': newEvent.inviterName,
        'numberOfInvitees': newEvent.numberOfInvitees,
        'inviteesPhoneNumbers': newEvent.inviteesPhoneNumbers,
        'duration': newEvent.duration,
        'acceptedInvitees': [],
        'rejectedInvitees': [],
      }).then((value) {
        _sendSMSInvitations(uniquePhoneNumbers.toList());
        _onEventCreatedSuccessfully();
        // At the end of your event creation logic, after the event is successfully created
    _scheduleReminder(newEvent);
      }).catchError((error) {
        setState(() {
          _errorMessage = 'Failed to create event: $error';
        });
           // Set a timer to clear the error message after 5 seconds
      Future.delayed(Duration(seconds: 5), () {
        setState(() {
          _errorMessage = ''; // Clear the error message
        });
      });
      });
    }
  }

  Future<bool> _checkEventConflict(DateTime selectedDateTime) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('events')
        .where('eventDateTime', isEqualTo: Timestamp.fromDate(selectedDateTime))
        .get();
    return snapshot.docs.isNotEmpty;
  }

  // Assuming this function is called after successfully creating an event
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

  // Method to build contact list UI
  Widget _buildContactList() {
    return Container(
      height: 100, // Set a fixed height for the contact list container
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _selectedContacts.length,
        itemBuilder: (BuildContext context, int index) {
          Contact contact = _selectedContacts[index];
          return ListTile(
            title: Text(contact.displayName ?? "No Name"),
            subtitle: Text(contact.phones?.first.value ?? "No Number"),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () =>
                  setState(() => _selectedContacts.removeAt(index)),
            ),
          );
        },
      ),
    );
  }

  bool _canAddMoreContacts() {
    int maxInvitees = int.tryParse(_numberOfInviteesController.text) ?? 0;
    return _selectedContacts.length < maxInvitees;
  }

  void _addPhoneNumber(String phoneNumber) {
    String cleanedNumber = _cleanPhoneNumber(phoneNumber);

    if (!_canAddMoreContacts()) {
      setState(() {
        _errorMessage = 'You have reached the maximum number of invitees';
      });
         // Set a timer to clear the error message after 5 seconds
      Future.delayed(Duration(seconds: 5), () {
        setState(() {
          _errorMessage = ''; // Clear the error message
        });
      });
      return;
    }

    if (_validatePhoneNumber(cleanedNumber) &&
        !_selectedContacts.any((contact) =>
            contact.phones?.first.value?.trim() == cleanedNumber)) {
      Contact newContact = Contact(
        displayName: "Custom Number",
        phones: [Item(label: "mobile", value: cleanedNumber)],
      );
      setState(() {
        _selectedContacts.add(newContact);
      });
    } else {
      setState(() {
        _errorMessage = 'Invalid or duplicate number';
      });
         // Set a timer to clear the error message after 5 seconds
      Future.delayed(Duration(seconds: 5), () {
        setState(() {
          _errorMessage = ''; // Clear the error message
        });
      });
    }
  }

  void _toggleContactSelection(Contact contact) {
    if (_selectedContacts.contains(contact)) {
      setState(() => _selectedContacts.remove(contact));
    } else {
      if (!_canAddMoreContacts()) {
        setState(() {
          _errorMessage = 'You have reached the maximum number of invitees';
        });
           // Set a timer to clear the error message after 5 seconds
      Future.delayed(Duration(seconds: 5), () {
        setState(() {
          _errorMessage = ''; // Clear the error message
        });
      });
        return;
      }
      setState(() => _selectedContacts.add(contact));
    }
  }

  Widget _buildAddPhoneField() {
    TextEditingController _phoneController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 5, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              onFieldSubmitted: _addPhoneNumber,
              decoration: InputDecoration(
                  labelText: 'Add Phone Number',
                  labelStyle: const TextStyle(color: Color(0xFF9a85a4)),
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
                    icon: Icon(Icons.add),
                    onPressed: () => _addPhoneNumber(_phoneController.text),
                  ),
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
            ),
          ),
        ],
      ),
    );
  }

  bool _validatePhoneNumber(String phoneNumber) {
    // Add specific validations based on the selected country
    switch (selectedCountry.countryCode) {
      case 'AE':
        return phoneNumber.startsWith('5') && phoneNumber.length == 9;
      case 'SA':
        return phoneNumber.startsWith('5') && phoneNumber.length == 9;
      case 'US':
        return phoneNumber.length == 10;
      default:
        return true; // Assume valid for countries not specifically handled
    }
  }

  void _showContactPicker() async {
    int inviteCount = int.tryParse(_numberOfInviteesController.text) ?? 0;
    List<Contact> filteredContacts = List.from(_allContacts);

  void filterContacts(String query) {
  List<Contact> tmp = [];
  if (query.isNotEmpty) {
    tmp.addAll(_allContacts.where(
      (contact) =>
        (contact.displayName ?? "").toLowerCase().contains(query.toLowerCase()) ||
        (contact.phones != null && contact.phones!.any(
          (phone) => phone.value != null && phone.value!.contains(query)
        ))
    ));
  } else {
    tmp = List.from(_allContacts);
  }
  setState(() {
    filteredContacts = tmp;
     print("hoor");
  });
}


    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 400, // or another fixed width
            height: 600,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18),color: Color.fromARGB(255, 255, 255, 255)),
            // or another fixed height
            child: StatefulBuilder(
             builder: (BuildContext context, StateSetter setState) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                  child: Text('Select Contacts',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      labelStyle: const TextStyle(
                          color: Color(0xFF9a85a4), fontSize: 14),
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
                       prefixIcon: IconButton(
        icon: Icon(Icons.search),
        onPressed: () {
          filterContacts(_searchController.text);  // Trigger filtering on button press
        },
      ),
                    ),
                    onChanged: (String text) {
                        setState(() {
                          filterContacts(text);
                        });
                      },
                  ),
                ),
                Expanded(
                  child: Padding(padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
              child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return ListView.builder(
                      itemCount: filteredContacts.length,
                      itemBuilder: (BuildContext context, int index) {
                        Contact contact = filteredContacts[index];
                        return ListTile(
                          key: ValueKey(contact.identifier),
                          title: Text(contact.displayName ?? "No Name"),
                          subtitle: Text(contact.phones?.first.value ?? "No Number"),
                          trailing: Checkbox(
                            value: _selectedContacts.contains(contact),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  if (!_selectedContacts.contains(contact)) {
                                    _toggleContactSelection(contact);
                                  }
                                } else {
                                  _selectedContacts.remove(contact);
                                }
                              });
                            },
                            activeColor: Color(0xFF9a85a4),
                          ),
                        );
                      },
                    );
                  },
                ),
                  ),
              ),
                const SizedBox(height: 10),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    backgroundColor: const Color(0xFF9a85a4)
                        .withOpacity(0.9), // Rounded corners
                  ),
                  child: const Text('Done',style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255))),
                ),),
                const SizedBox(height: 10),
              ],
            );
           },
            ),
          ),
        );
      },
    );
  }

  String _cleanPhoneNumber(String phoneNumber) {
    // Remove non-digits from the phone number, keeping "+" for international format
    return phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
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

   Widget _buildEventTypeDropdown() {
    return Padding(padding: EdgeInsets.fromLTRB(8, 0, 5, 0),
    child: DropdownButtonFormField2<String>(
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
      value: _selectedEventType,
 dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              width: 330,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color:  Color.fromARGB(255, 233, 228, 237),
              ),
               elevation: 16,
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: MaterialStateProperty.all<double>(6),
                thumbVisibility: MaterialStateProperty.all<bool>(true),
              ),
            ),
           menuItemStyleData: const MenuItemStyleData(
              height: 50,
              padding: EdgeInsets.only(left: 14, right: 14),
              overlayColor:MaterialStatePropertyAll(const Color(0xFF9a85a4))
            ),
      onChanged: (String? newValue) {
        setState(() {
          _selectedEventType = newValue!;
        });
      },
      items: _eventTypes
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5), // Adjust horizontal padding here
          child: Text(
                        value,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
          width: 150, // Use this to adjust width if necessary
        ),
        );
      }).toList(),
      validator: (value) {
                if (value == null) {
                  return 'Please select event type';
                }
                return null;
              },
     ),
     
      );
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
      _buildEventTypeDropdown(), // Insert the dropdown widget
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
                            icon: Icon(Icons.remove,),
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
                            icon: Icon(Icons.add,),
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
              /* ...List.generate(
                _inviteesPhoneControllers.length,
                (index) => _buildPhoneNumberField(index),
              ),*/
              _buildAddPhoneField(),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 5, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 0, 1),
                      child: Text(
                        'Select contacts from contacts list',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9a85a4),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 4.0, vertical: 8),
                        decoration: BoxDecoration(
                          color: Color(0xFF9a85a4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            TextButton(
                              onPressed: _showContactPicker,
                              child: Text(
                                "From Contacts",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF9a85a4),
                                ),
                              ),
                            ),
                            IconButton(
                                padding: EdgeInsets.fromLTRB(160, 0, 0, 0),
                                icon: Icon(Icons.arrow_forward_ios,),
                                onPressed: _showContactPicker),
                          ],
                        )),
                  ],
                ),
              ),
// Within your build method, call this where you want to display the contacts
              _buildContactList(),
              const SizedBox(height: 5),
              // Error message display
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 0, 10),
                  child: Text(_errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 12),textAlign: TextAlign.center,),
                ),
              const SizedBox(height: 5),

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
