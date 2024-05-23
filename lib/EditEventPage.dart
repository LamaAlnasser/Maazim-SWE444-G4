import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maazim/Home_Host.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:country_picker/country_picker.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:maazim/Event.dart';

class EditEventPage extends StatefulWidget {
  final String eventId;

  const EditEventPage({Key? key, required this.eventId}) : super(key: key);

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();
  late MaazimEvent event;
  bool _isLoading = true;

  late TextEditingController _eventNameController;
  late TextEditingController _eventAddressController;
  late TextEditingController _eventLocationController;
  late TextEditingController _inviterNameController;
  late TextEditingController _numberOfInviteesController;
  late TextEditingController _phoneController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  int _eventDuration = 1;
  List<Contact> _allContacts = [];
  List<String> _inviteesPhoneNumbers = [];
  List<String> _newPhoneNumbers = [];
  String _errorMessage = '';
  late TextEditingController _searchController;
  String? _selectedEventType;
  String? _selectedDressCode;
  String? _selectedTheme;

  List<String> _eventTypes = [
    'Conference',
    'Wedding',
    'Graduation',
    'Exhibition',
    'Birthday',
    'Party',
    'Other'
  ];
  final List<String> _dressCodeOptions = [
    'Casual',
    'Business Attire',
    'National Dress',
    'Formal',
    'Themed Dress ',
    'Other',
  ];
  final List<String> _themeOptions = [
    'Traditional',
    'Modern',
    'Outdoor',
    'Festive',
    'Other',
  ];

  Country selectedCountry = Country(
      phoneCode: "966",
      countryCode: "SA",
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: "Saudi Arabia",
      example: "Saudi Arabia",
      displayName: "Saudi Arabia",
      displayNameNoCountryCode: "KSA",
      e164Key: "");

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
      event = MaazimEvent.fromSnapshot(eventSnapshot);
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
    _inviterNameController = TextEditingController(text: event.inviterName);
    _numberOfInviteesController =
        TextEditingController(text: event.numberOfInvitees.toString());
    _phoneController = TextEditingController();
    _selectedDate = event.eventDate;
    _selectedTime = event.eventTime;
    _eventDuration = event.duration;
    _selectedEventType = event.eventType;
    _selectedDressCode = event.dressCode;
    _selectedTheme = event.theme;
    _inviteesPhoneNumbers = event.inviteesPhoneNumbers;
    _checkPermissionsAndLoadContacts();
    setState(() => _isLoading = false);
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
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          title: Text(
            "Permission Required",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content:
              Text("This app requires contact access to function properly."),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                backgroundColor:
                    const Color(0xFF9a85a4).withOpacity(0.9), // Rounded corners
              ),
              child: const Text('Cancel',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255))),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Dismiss the dialog but do nothing
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                backgroundColor:
                    const Color(0xFF9a85a4).withOpacity(0.9), // Rounded corners
              ),
              child: const Text('Open Settings',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255))),
              onPressed: () {
                openAppSettings(); // Open app settings
              },
            ),
          ],
        );
      },
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF9a85a4), // header background color
              onPrimary: Colors.white, // header text color
              surface: Color.fromARGB(255, 255, 255, 255), // background color
              onSurface: Colors.black, // body text color
            ),
            dialogBackgroundColor:
                Color.fromARGB(255, 255, 255, 255), // background color
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF9a85a4),
                padding: EdgeInsets.symmetric(
                    horizontal: 10), // Button background color
                shape: RoundedRectangleBorder(
                  // Button shape
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  void _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Color(0xFF9a85a4),
              onPrimary: Colors.white,
              surface: Color.fromARGB(255, 255, 255, 255),
              onSurface: Color.fromARGB(255, 0, 0, 0),
            ),
            dialogBackgroundColor: Color.fromARGB(255, 255, 255, 255),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF9a85a4),
                padding: EdgeInsets.symmetric(
                    horizontal: 10), // Button background color
                shape: RoundedRectangleBorder(
                  // Button shape
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime && _isFutureTime(picked))
      setState(() {
        _selectedTime = picked;
      });
  }

  bool _isFutureTime(TimeOfDay time) {
    final now = TimeOfDay.now();
    return time.hour > now.hour ||
        (time.hour == now.hour && time.minute > now.minute);
  }

  Future<void> _updateEvent() async {
    if (_formKey.currentState!.validate()) {
      final int currentNumberOfInvitees = event.numberOfInvitees;
      final int newNumberOfInvitees =
          int.tryParse(_numberOfInviteesController.text) ??
              currentNumberOfInvitees;
      if (newNumberOfInvitees < currentNumberOfInvitees) {
        setState(() {
          _errorMessage =
              'Number of invitees cannot be less than the current number of invitees.';
        });
        Future.delayed(Duration(seconds: 5), () {
          setState(() {
            _errorMessage = ''; // Clear the error message
          });
        });
        return;
      }

      if (newNumberOfInvitees !=
          _inviteesPhoneNumbers.length + _newPhoneNumbers.length) {
        setState(() {
          _errorMessage =
              'Number of invitees must match the count of phone numbers added.';
        });
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

      bool isEventConflict = await _checkEventConflict(selectedDateTime);
      if (isEventConflict) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Event Conflict',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: Text(
                  'An event already exists at the selected date and time.'),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
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
              ],
            );
          },
        );
        return;
      }

      try {
        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .update({
          'eventName': _eventNameController.text,
          'address': _eventAddressController.text,
          'eventLocation': _eventLocationController.text,
          'eventType': _selectedEventType,
          'eventDateTime': Timestamp.fromDate(selectedDateTime),
          'inviterName': _inviterNameController.text,
          'numberOfInvitees': newNumberOfInvitees,
          'inviteesPhoneNumbers': FieldValue.arrayUnion(_newPhoneNumbers),
          'duration': _eventDuration,
          'dressCode': _selectedDressCode,
          'theme': _selectedTheme,
        });

        // _sendNotificationsToInvitees();
        _notifyLocalUpdate();
        Navigator.pop(context);
      } catch (e) {
        print('Failed to update event: $e');
      }
    }
  }

  Future<bool> _checkEventConflict(DateTime selectedDateTime) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('events')
        .where('eventDateTime', isEqualTo: Timestamp.fromDate(selectedDateTime))
        .where(FieldPath.documentId, isNotEqualTo: widget.eventId)
        .get();
    return snapshot.docs.isNotEmpty;
  }

/*  void _sendNotificationsToInvitees() async {
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
    );
  }
*/
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

  void _addPhoneNumber(String phoneNumber) {
    String cleanedNumber = _cleanPhoneNumber(phoneNumber);

    if (_validatePhoneNumber(cleanedNumber) &&
        !_inviteesPhoneNumbers.contains(cleanedNumber) &&
        !_newPhoneNumbers.contains(cleanedNumber)) {
      setState(() {
        _newPhoneNumbers.add(cleanedNumber);
      });
    } else {
      setState(() {
        _errorMessage = 'Invalid or duplicate number';
      });
      Future.delayed(Duration(seconds: 5), () {
        setState(() {
          _errorMessage = ''; // Clear the error message
        });
      });
    }
  }

  bool _canAddMoreContacts() {
    int maxInvitees = int.tryParse(_numberOfInviteesController.text) ?? 0;
    return _inviteesPhoneNumbers.length + _newPhoneNumbers.length < maxInvitees;
  }

  Widget _buildContactList() {
    return Container(
      height: 100, // Adjust height as needed
      child: ListView.builder(
        itemCount: _inviteesPhoneNumbers.length + _newPhoneNumbers.length,
        itemBuilder: (context, index) {
          if (index < _inviteesPhoneNumbers.length) {
            String phoneNumber = _inviteesPhoneNumbers[index];
            return ListTile(
              title: Text(phoneNumber),
              trailing: Icon(
                Icons.check,
                color: Colors.green,
              ),
            );
          } else {
            String phoneNumber =
                _newPhoneNumbers[index - _inviteesPhoneNumbers.length];
            return ListTile(
              title: Text(phoneNumber),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  setState(() {
                    _newPhoneNumbers
                        .removeAt(index - _inviteesPhoneNumbers.length);
                  });
                },
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildAddPhoneField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 5, 0),
      child: TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: 'Add Phone Number',
          labelStyle: const TextStyle(color: Color(0xFF9a85a4), fontSize: 14),
          errorStyle: const TextStyle(fontSize: 10),
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
          suffixIcon: IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _addPhoneNumber(_phoneController.text);
              _phoneController.clear();
            },
          ),
        ),
        onFieldSubmitted: (value) {
          _addPhoneNumber(value);
          _phoneController.clear();
        },
      ),
    );
  }

  Widget _buildEventTypeDropdown() {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 0, 5, 0),
      child: DropdownButtonFormField2<String>(
        decoration: InputDecoration(
          labelText: 'Event Type',
          labelStyle: const TextStyle(color: Color(0xFF9a85a4), fontSize: 14),
          errorStyle: const TextStyle(fontSize: 10),
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
        ),
        value: _selectedEventType,
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          width: 330,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Color.fromARGB(255, 233, 228, 237),
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
            overlayColor: MaterialStatePropertyAll(const Color(0xFF9a85a4))),
        onChanged: (String? newValue) {
          setState(() {
            _selectedEventType = newValue;
          });
        },
        items: _eventTypes.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              width: 150,
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

  Widget _buildDressCodeDropdown() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 5, 0),
      child: DropdownButtonFormField2<String>(
        decoration: InputDecoration(
          labelText: 'Dress Code',
          labelStyle: const TextStyle(color: Color(0xFF9a85a4), fontSize: 14),
          errorStyle: const TextStyle(fontSize: 10),
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
        ),
        value: _selectedDressCode,
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          width: 330,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Color.fromARGB(255, 233, 228, 237),
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
            overlayColor: MaterialStatePropertyAll(const Color(0xFF9a85a4))),
        onChanged: (String? newValue) {
          setState(() {
            _selectedDressCode = newValue;
          });
        },
        items: _dressCodeOptions.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList(),
        validator: (value) {
          if (value == null) {
            return 'Please select dress code';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildThemeDropdown() {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: DropdownButtonFormField2<String>(
        decoration: InputDecoration(
          labelText: 'Theme',
          labelStyle: const TextStyle(color: Color(0xFF9a85a4), fontSize: 14),
          errorStyle: const TextStyle(fontSize: 10),
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
        ),
        value: _selectedTheme,
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          width: 330,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Color.fromARGB(255, 233, 228, 237),
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
            overlayColor: MaterialStatePropertyAll(const Color(0xFF9a85a4))),
        onChanged: (String? newValue) {
          setState(() {
            _selectedTheme = newValue;
          });
        },
        items: _themeOptions.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Container(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList(),
        validator: (value) {
          if (value == null) {
            return 'Please select theme';
          }
          return null;
        },
      ),
    );
  }

  String _cleanPhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
  }

  bool _validatePhoneNumber(String phoneNumber) {
    return phoneNumber.startsWith('5') && phoneNumber.length == 9;
  }

  bool _isValidLocation(String location) {
    if (location.isEmpty) {
      return true;
    }
    RegExp googleMapsRegex = RegExp(r'https:\/\/(www\.)?google\.com\/maps\/.*');
    RegExp googleMapsRegex1 = RegExp(r'https:\/\/maps\.app\.goo\.gl\/.*');
    RegExp iOSMapsRegex = RegExp(r'(maps:\/\/|http:\/\/maps\.apple\.com\/).*');
    RegExp iOSMapsRegex1 = RegExp(r'https:\/\/maps\.apple\.com\/?\/*');
    return googleMapsRegex.hasMatch(location) ||
        googleMapsRegex1.hasMatch(location) ||
        iOSMapsRegex.hasMatch(location) ||
        iOSMapsRegex1.hasMatch(location);
  }

  Future<bool> _isValidMapLink(String link) async {
    return link.startsWith('https://maps.google.com/') ||
        link.startsWith('https://maps.apple.com/') ||
        link.startsWith('https://maps.app.goo.gl/');
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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
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
                    backgroundColor: const Color(0xFF9a85a4).withOpacity(0.9),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Edit Event')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/Logo.PNG',
                height: 30,
              ),
              const SizedBox(width: 8),
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
                "Edit Event",
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
                padding: const EdgeInsets.fromLTRB(8, 0, 5, 0),
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
              _buildEventTypeDropdown(),
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    flex:
                        3, // Adjust flex factor if needed to manage space distribution
                    child: _buildThemeDropdown(),
                  ),
                  const SizedBox(
                      width: 10), // Add some space between the dropdowns
                  Flexible(
                    flex:
                        3, // Adjust flex factor if needed to manage space distribution
                    child: _buildDressCodeDropdown(),
                  ),
                ],
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
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
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
                    if (value == null || value.isEmpty) {
                      return null;
                    }
                    if (!_isValidLocation(value)) {
                      return 'Please enter a Google Maps or iOS Maps link';
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
                    if (count !=
                        _inviteesPhoneNumbers.length +
                            _newPhoneNumbers.length) {
                      setState(() {
                        _errorMessage =
                            'Number of invitees must match the count of phone numbers added.';
                      });
                      Future.delayed(Duration(seconds: 5), () {
                        setState(() {
                          _errorMessage = ''; // Clear the error message
                        });
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
              _buildAddPhoneField(),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 5, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                ),
              ),
              _buildContactList(),
              const SizedBox(height: 5),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 0, 10),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                  onPressed: _updateEvent,
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF9a85a4).withOpacity(0.9),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showContactPicker() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            width: 400,
            height: 600,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Color.fromARGB(255, 255, 255, 255),
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 14, 0, 0),
                      child: Text(
                        'Select Contacts',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
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
                                color:
                                    const Color(0xFF9a85a4).withOpacity(0.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                                color:
                                    const Color(0xFF9a85a4).withOpacity(0.6)),
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
                              filterContacts(_searchController.text);
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
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                        child: ListView.builder(
                          itemCount: _allContacts.length,
                          itemBuilder: (BuildContext context, int index) {
                            Contact contact = _allContacts[index];
                            return ListTile(
                              key: ValueKey(contact.identifier),
                              title: Text(contact.displayName ?? "No Name"),
                              subtitle: Text(contact.phones != null &&
                                      contact.phones!.isNotEmpty
                                  ? contact.phones!.first.value ?? "No Number"
                                  : "No Number"),
                              trailing: Checkbox(
                                value: _inviteesPhoneNumbers.contains(
                                        contact.phones?.first.value) ||
                                    _newPhoneNumbers
                                        .contains(contact.phones?.first.value),
                                onChanged: (bool? value) {
                                  if (value == true) {
                                    if (_canAddMoreContacts()) {
                                      _addPhoneNumber(
                                          contact.phones?.first.value ?? "");
                                    } else {
                                      setState(() {
                                        _errorMessage =
                                            'You have reached the maximum number of invitees';
                                      });
                                      Future.delayed(Duration(seconds: 5), () {
                                        setState(() {
                                          _errorMessage =
                                              ''; // Clear the error message
                                        });
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      _newPhoneNumbers
                                          .remove(contact.phones?.first.value);
                                    });
                                  }
                                },
                                activeColor: Color(0xFF9a85a4),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          backgroundColor: const Color(0xFF9a85a4)
                              .withOpacity(0.9), // Rounded corners
                        ),
                        child: const Text('Done',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 255, 255))),
                      ),
                    ),
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

  void filterContacts(String query) {
    List<Contact> tmp = [];
    if (query.isNotEmpty) {
      tmp.addAll(_allContacts.where((contact) =>
          (contact.displayName ?? "")
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          (contact.phones != null &&
              contact.phones!.any((phone) =>
                  phone.value != null && phone.value!.contains(query)))));
    } else {
      tmp = List.from(_allContacts);
    }
    setState(() {
      _allContacts = tmp;
    });
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventAddressController.dispose();
    _eventLocationController.dispose();
    _inviterNameController.dispose();
    _numberOfInviteesController.dispose();
    _phoneController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
