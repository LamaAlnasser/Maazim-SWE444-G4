import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:maazim/Event.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:maazim/Home_Host.dart';
import 'package:maazim/EditEventPage.dart';
import 'package:maazim/notification.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:collection/collection.dart';

class EventAttendancePage extends StatefulWidget {
  final String eventId;

  EventAttendancePage({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventAttendancePageState createState() => _EventAttendancePageState();
}

class _EventAttendancePageState extends State<EventAttendancePage> {
  late Future<DocumentSnapshot> eventDetailsFuture;
  late MaazimEvent? event;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    eventDetailsFuture = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get();
  }

  Future<void> deleteEvent(BuildContext context, String eventId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Deletion',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Text('Are you sure you want to delete this event?'),
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
                      const Color.fromRGBO(244, 67, 54, 1) // Rounded corners
                  ),
              child: const Text('Delete',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255))),
              onPressed: () async {
                await _deleteEvent(context, eventId);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const homePage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEvent(BuildContext context, String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .delete();
      await _deleteEntryCoordinator(eventId);
      await _sendNotificationsToInvitees(eventId);
      _notifyLocalUpdate();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const homePage()),
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Error',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            content: Text('Failed to delete event: $error'),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  backgroundColor: const Color(0xFF9a85a4)
                      .withOpacity(0.9), // Rounded corners
                ),
                child: const Text('OK',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 255, 255, 255))),
                onPressed: () {
                  Navigator.of(context)
                      .pop(); // Dismiss the dialog but do nothing
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _deleteEntryCoordinator(String eventId) async {
    try {
      await FirebaseFirestore.instance
          .collection('coordinators')
          .doc(eventId)
          .delete();
    } catch (error) {
      print('Failed to delete entry coordinator: $error');
    }
  }

  Future<void> _sendNotificationsToInvitees(String eventId) async {
    try {
      DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(eventId)
          .get();

      if (!eventSnapshot.exists) {
        print('Event not found');
        return;
      }

      MaazimEvent event = MaazimEvent.fromSnapshot(eventSnapshot);

      for (String phoneNumber in event.inviteesPhoneNumbers) {
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('phoneNumber', isEqualTo: phoneNumber)
            .limit(1)
            .get();

        if (userSnapshot.docs.isNotEmpty) {
          var userData = userSnapshot.docs.first.data() as Map<String, dynamic>;
          String? deviceToken = userData['deviceToken'];

          if (deviceToken != null) {
            await _sendFCMNotification(deviceToken, event);
          } else {
            print('No device token found for phone number: $phoneNumber');
          }
        } else {
          print('No user found with phone number: $phoneNumber');
        }
      }
    } catch (e) {
      print('Failed to send notifications: $e');
    }
  }

  Future<void> _sendFCMNotification(
      String deviceToken, MaazimEvent event) async {
    final String serverToken = 'YOUR_SERVER_KEY';

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'to': deviceToken,
          'notification': <String, dynamic>{
            'title': '${event.eventName} Deleted!',
            'body':
                'The event you were invited to has been deleted. Please check the details.',
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
          'data': <String, dynamic>{
            'eventId': event.eventId,
          },
        },
      ),
    );

    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }
  }

  Future<String?> getDeviceTokenFromPhoneNumber(String phoneNumber) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('phoneNumber', isEqualTo: phoneNumber)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data()['deviceToken'] as String?;
      } else {
        return null;
      }
    } catch (error) {
      print('Error retrieving device token from Firestore: $error');
      return null;
    }
  }

  void _notifyLocalUpdate() {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: 'basic_channel',
        title: 'Event Deleted',
        body: 'Your event has been deleted. Check out the latest details!',
      ),
    );
  }

List<Widget> _buildAttendanceSections({
  required BuildContext context,
  required List<Map<String, dynamic>> sections,
}) {
  return sections.map((section) {
    final title = section['title'];
    final icon = section['icon'];
    final color = section['color'];
    final attendees = section['attendees'];

    return ExpansionTile(
      title: Text(
        '$title Attendees (${attendees.length})',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      leading: Icon(icon, color: color),
      children: [
        FutureBuilder<List<String?>>(
          future: Future.wait(
            attendees.map((phoneNumber) =>
                _getFullNameFromPhoneNumber(phoneNumber)),
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            List<String?> fullNames = snapshot.data ?? [];
            return Column(
              children: List.generate(attendees.length, (index) {
                return ListTile(
                  title: Text(
                    '${attendees[index]} (${fullNames[index] ?? 'Unknown'})',
                  ),);}),);},), ],  );
  }).toList();
}
  void navigateToEditEventPage(BuildContext context, String eventId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditEventPage(eventId: eventId)),
    );
  }

  String _formatDuration(int hours) {
    return '$hours hour${hours != 1 ? 's' : ''}';
  }

  Widget _buildLocationWidget(String address, {String? eventLocation}) {
    bool canOpenMap = eventLocation != null && eventLocation.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(171, 224, 214, 230),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF9a85a4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.location_on,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
        title: Text(
          'Address',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          address,
          style: TextStyle(
            fontSize: 15,
          ),
        ),
        trailing: canOpenMap
            ? Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Color(0xFF9a85a4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () async {
                    if (await canLaunch(eventLocation!)) {
                      await launch(eventLocation);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Could not launch maps link')),
                      );
                    }
                  },
                  child: Text(
                    'Open Maps',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Future<String?> _getFullNameFromPhoneNumber(String phoneNumber) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('phoneNumber', isEqualTo: phoneNumber)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        String firstName = querySnapshot.docs.first.data()['firstName'];
        String lastName = querySnapshot.docs.first.data()['lastName'];
        return '$firstName $lastName';
      } else {
        return 'Unknown';
      }
    } catch (error) {
      print('Error retrieving full name from Firestore: $error');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Event Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Color.fromARGB(255, 41, 39, 39)),
            onPressed: () {
              deleteEvent(context, widget.eventId);
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: eventDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data?.data() == null) {
            return Center(child: Text('No data available'));
          }

          Map<String, dynamic> eventData =
              snapshot.data!.data() as Map<String, dynamic>;
          var dateAndTime = eventData['eventDateTime']?.toDate();
          var formattedDate = dateAndTime != null
              ? DateFormat('dd MMM yyyy').format(dateAndTime)
              : 'N/A';
          var formattedTime = dateAndTime != null
              ? DateFormat('hh:mm a').format(dateAndTime)
              : 'N/A';

          // Ensure the lists are not null before accessing them
          List<String> acceptedInvitees =
              List<String>.from(eventData['acceptedInvitees'] ?? []);
          List<String> rejectedInvitees =
              List<String>.from(eventData['rejectedInvitees'] ?? []);
          List<String> inviteesPhoneNumbers =
              List<String>.from(eventData['inviteesPhoneNumbers'] ?? []);
          Map<String, double> dataMap = {
            'Accepted Invitees': acceptedInvitees.length.toDouble(),
            'Rejected Invitees': rejectedInvitees.length.toDouble(),
            'Pending Invitees':
                _calculatePendingInvitees(eventData).length.toDouble(),
          };
          Map<String, Color> colorMap = {
            'Accepted Invitees': Colors.green,
            'Rejected Invitees': Colors.red,
            'Pending Invitees': Colors.orange,
          };

          // Check if the event is in the past
          bool isPastEvent =
              dateAndTime != null && dateAndTime.isBefore(DateTime.now());
          String eventName = eventData['eventName'];

          return ListView(
            padding: EdgeInsets.all(30),
            children: [
              // Date and Time at the beginning
              Row(
                children: [
                  Container(
                    width: 90,
                    padding:
                        EdgeInsets.symmetric(vertical: 10.0, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(171, 224, 214,
                          230), // Adjust the color to match the image
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          DateFormat('MMM').format(
                              dateAndTime), // Display month in short format (e.g., "May")
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF9a85a4),
                          ),
                        ),
                        Text(
                          DateFormat('dd').format(dateAndTime), // Display day
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 30,
                            color: Color(
                                0xFF9a85a4), // Adjust the text color to white
                          ),
                        ),
                        Text(
                          DateFormat('yyyy')
                              .format(dateAndTime), // Display year
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(
                                0xFF9a85a4), // Adjust the text color to white
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 25),
                  Container(
                    padding: EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: Color.fromARGB(171, 224, 214,
                          230), // Adjust the color to match the image
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE').format(dateAndTime) +
                              ' at ' +
                              DateFormat('h:mm a').format(dateAndTime),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Color.fromARGB(221, 40, 40,
                                40), // Adjust the text color to white
                          ),
                        ),
                        SizedBox(
                            height: 3), // Add spacing between text and button
                        TextButton.icon(
                          onPressed: () {
                            // Show the confirmation dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor:
                                      Color.fromARGB(255, 255, 255, 255),
                                  title: Text(
                                    'Add to Calendar',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  content: Text(
                                    'Do you want to add "${eventName}" event to your calendar?',
                                  ),
                                  actions: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: const StadiumBorder(),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 16),
                                          backgroundColor:
                                              const Color(0xFF9a85a4)
                                                  .withOpacity(
                                                      0.9), // Rounded corners
                                        ),
                                        child: const Text('Cancel',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255))),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog

                                          // Use a parent context that is still valid
                                          final parentContext =
                                              scaffoldKey.currentContext!;
                                          // Prepare event data to pass to the addToCalendar method
                                          Map<String, dynamic> eventDataToSend =
                                              {
                                            'eventName': eventData['eventName'],
                                            'eventDateTime':
                                                eventData['eventDateTime'],
                                            'duration': eventData['duration'],
                                            // Include other necessary event fields
                                          };
                                          // Call addToCalendar method
                                          bool eventAdded = await addToCalendar(
                                              eventDataToSend, parentContext);
                                          if (eventAdded) {
                                            showDialog(
                                              context: parentContext,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 255, 255, 255),
                                                  title: Text(
                                                    'Success',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  content: Text(
                                                      "Event has been added to your calendar."),
                                                  actions: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5),
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(); // Close the dialog
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          shape:
                                                              const StadiumBorder(),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 10,
                                                                  horizontal:
                                                                      16),
                                                          backgroundColor:
                                                              const Color(
                                                                      0xFF9a85a4)
                                                                  .withOpacity(
                                                                      0.9), // Rounded corners
                                                        ),
                                                        child: const Text('OK',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        255))),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          } else {
                                            showDialog(
                                              context: parentContext,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 255, 255, 255),
                                                  title: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Stack(
                                                        alignment:
                                                            Alignment.center,
                                                        children: [
                                                          Icon(
                                                            Icons.circle,
                                                            color: Colors.red
                                                                .withOpacity(
                                                                    0.2),
                                                            size: 40,
                                                          ),
                                                          Text(
                                                            "!",
                                                            style: TextStyle(
                                                              color: Colors.red,
                                                              fontSize: 24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Error',
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ],
                                                  ),
                                                  content: Text(
                                                      "Event already exists in the calendar."),
                                                  actions: <Widget>[
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 5),
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop(); // Close the dialog
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          shape:
                                                              const StadiumBorder(),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 10,
                                                                  horizontal:
                                                                      16),
                                                          backgroundColor:
                                                              const Color(
                                                                      0xFF9a85a4)
                                                                  .withOpacity(
                                                                      0.9), // Rounded corners
                                                        ),
                                                        child: const Text('OK',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        255))),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          shape: const StadiumBorder(),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 16),
                                          backgroundColor:
                                              const Color(0xFF9a85a4)
                                                  .withOpacity(
                                                      0.9), // Rounded corners
                                        ),
                                        child: const Text('Yes',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255))),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.calendar_today,
                              color: Color(0xFF9a85a4)),
                          label: Text('Add to calendar',
                              style: TextStyle(color: Color(0xFF9a85a4))),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(171, 224, 214, 230),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Text(
                    'Event Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  subtitle: Text(
                    eventData['eventName'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF9a85a4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.event_note,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(171, 224, 214, 230),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Text(
                    'Event Type',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  subtitle: Text(
                    eventData['eventType'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF9a85a4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.category,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(171, 224, 214, 230),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Text(
                    'Host',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  subtitle: Text(
                    eventData['inviterName'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF9a85a4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(171, 224, 214, 230),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Text(
                    'Number of Invitees',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  subtitle: Text(
                    '${eventData['numberOfInvitees'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF9a85a4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.people,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(171, 224, 214, 230),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Text(
                    'Duration',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  subtitle: Text(
                    _formatDuration(eventData['duration'] ?? 0),
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF9a85a4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.hourglass_bottom,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(171, 224, 214, 230),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Text(
                    'Theme',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  subtitle: Text(
                    eventData['theme'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF9a85a4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.palette,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(171, 224, 214, 230),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  title: Text(
                    'Dress Code',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  subtitle: Text(
                    eventData['dressCode'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF9a85a4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.checkroom_sharp,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10),
              _buildLocationWidget(
                eventData['address'] ?? 'N/A',
                eventLocation: eventData['eventLocation'],
              ),
              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.all(3),
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Color(0xFF9a85a4),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      margin: EdgeInsets.all(8),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 252, 252),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
  crossAxisAlignment: CrossAxisAlignment.stretch,
  children: [
    Text(
      'Attendance Analysis',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.grey.withOpacity(0.5),
            offset: Offset(2, 2),
            blurRadius: 3,
          ),
        ],
      ),
    ),
    Divider(color: Color(0xFF9a85a4)),
    ..._buildAttendanceSections(
      context: context,
      sections: [
        {
          'title': 'Accepted',
          'icon': Icons.check_circle,
          'color': Colors.green,
          'attendees': acceptedInvitees,
        },
        {
          'title': 'Rejected',
          'icon': Icons.cancel,
          'color': Colors.red,
          'attendees': rejectedInvitees,
        },
        {
          'title': 'Pending',
          'icon': Icons.access_time,
          'color': Colors.orange,
          'attendees': _calculatePendingInvitees(eventData),
        },
      ],
    ),
  

                       
                          SizedBox(height: 15),
                          Text(
                            textAlign: TextAlign.center,
                            'Attendance Chart Analysis',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  offset: Offset(2, 2),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                          Container(height: 2, color: Color(0xFF9a85a4)),
                          Container(
                            height: 150,
                            child: PieChart(
                              dataMap: dataMap,
                              colorList: colorMap.values.toList(),
                              chartType: ChartType.disc,
                              legendOptions: LegendOptions(
                                showLegendsInRow: false,
                                legendPosition: LegendPosition.right,
                              ),
                              chartValuesOptions: ChartValuesOptions(
                                showChartValues: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!isPastEvent) // Show Edit button only for future events
                    Container(
                      width: 130,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          navigateToEditEventPage(context, widget.eventId);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.edit, color: Colors.white),
                            SizedBox(width: 5),
                            Text('Edit',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Color(0xFF9a85a4).withOpacity(0.9),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  List<String> _calculatePendingInvitees(Map<String, dynamic> eventData) {
    var allInvitees =
        List<String>.from(eventData['inviteesPhoneNumbers'] as List? ?? []);
    var accepted =
        Set<String>.from(eventData['acceptedInvitees'] as List? ?? []);
    var rejected =
        Set<String>.from(eventData['rejectedInvitees'] as List? ?? []);
    return allInvitees
        .where((phoneNumber) =>
            !accepted.contains(phoneNumber) && !rejected.contains(phoneNumber))
        .toList();
  }

  static final DeviceCalendarPlugin _deviceCalendarPlugin =
      DeviceCalendarPlugin();

  // Retrieve and show available calendars
  static Future<List<Calendar>> retrieveCalendars() async {
    try {
      var result = await _deviceCalendarPlugin.retrieveCalendars();
      print('Retrieved calendars successfully');
      if (result.isSuccess && result.data != null) {
        print('Number of calendars found: ${result.data!.length}');
        return result.data!;
      }
      print('No calendars found or access not granted');
      return [];
    } catch (e) {
      print('Error retrieving calendars: $e');
      return [];
    }
  }

  // Function to present user with a choice of calendars
  static Future<String?> selectCalendar(BuildContext context) async {
    List<Calendar> calendars = await retrieveCalendars();
    if (calendars.isEmpty) {
      print('No calendars available to select');
      return null;
    }

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          title: Text(
            'Choose a Calendar',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: calendars.map((calendar) {
                return SimpleDialogOption(
                  onPressed: () {
                    // Only proceed if ID is not null
                    if (calendar.id != null) {
                      Navigator.pop(context, calendar.id);
                    } else {
                      print("Selected calendar ID is null, cannot proceed.");
                    }
                  },
                  child: Text(calendar.name ?? 'Unnamed Calendar'),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // Method to check if the event already exists in the calendar
  static Future<bool> isEventAlreadyInCalendar(
      String calendarId, Map<String, dynamic> event) async {
    final tz.TZDateTime startOriginal = tz.TZDateTime.from(
        (event['eventDateTime'] as Timestamp).toDate(), tz.getLocation('UTC'));
    final tz.TZDateTime start = tz.TZDateTime(
        startOriginal.location,
        startOriginal.year,
        startOriginal.month,
        startOriginal.day,
        startOriginal.hour,
        startOriginal.minute); // Strip seconds and milliseconds

    final int duration = event['duration'];
    final tz.TZDateTime end = start.add(Duration(hours: duration));

    print('Checking if event already exists in calendar...');
    print(
        'Event details - Title: ${event['eventName']}, Start: $start, End: $end');

    var retrieveEventsParams = RetrieveEventsParams(
      startDate: start,
      endDate: end,
    );

    var result = await _deviceCalendarPlugin.retrieveEvents(
        calendarId, retrieveEventsParams);

    if (result.isSuccess && result.data != null) {
      for (var existingEvent in result.data!) {
        tz.TZDateTime existingStart = tz.TZDateTime(
            existingEvent.start!.location,
            existingEvent.start!.year,
            existingEvent.start!.month,
            existingEvent.start!.day,
            existingEvent.start!.hour,
            existingEvent.start!.minute);
        tz.TZDateTime existingEnd = tz.TZDateTime(
            existingEvent.end!.location,
            existingEvent.end!.year,
            existingEvent.end!.month,
            existingEvent.end!.day,
            existingEvent.end!.hour,
            existingEvent.end!.minute);

        if (existingEvent.title == event['eventName'] &&
            existingStart.isAtSameMomentAs(start) &&
            existingEnd.isAtSameMomentAs(end)) {
          print('Event already exists in the calendar');
          return true;
        }
      }
    }

    print('Event does not exist in the calendar');
    return false;
  }

  // Method to add an event to the chosen calendar
  static Future<bool> addToCalendar(
      Map<String, dynamic> event, BuildContext context) async {
    print('Attempting to add event to calendar...');
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
      print('Permissions not granted. Requesting permissions...');
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
        print('Permissions denied');
        return false;
      }
    }
    print('Permissions granted');

    String? calendarId = await selectCalendar(context);
    if (calendarId == null) {
      print("No calendar selected to add events");
      return false;
    }

    // Check if the event already exists
    bool eventExists = await isEventAlreadyInCalendar(calendarId, event);
    if (eventExists) {
      print('Event already exists in the calendar');
      return false;
    }

    print('Calendar selected, adding event');
    final tz.TZDateTime start = tz.TZDateTime.from(
        (event['eventDateTime'] as Timestamp).toDate(), tz.getLocation('UTC'));
    final tz.TZDateTime end =
        start.add(Duration(hours: event['duration'] ?? 2));

    final Event calendarEvent = Event(
      calendarId,
      title: event['eventName'],
      start: start,
      end: end,
    );

    try {
      await _deviceCalendarPlugin.createOrUpdateEvent(calendarEvent);
      print('Event added/updated successfully');
      return true;
    } catch (e) {
      print('Error creating/updating event: $e');
      return false;
    }
  }
}
