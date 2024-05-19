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

class EventAttendancePage extends StatefulWidget {
  final String eventId;

  EventAttendancePage({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventAttendancePageState createState() => _EventAttendancePageState();
}

class _EventAttendancePageState extends State<EventAttendancePage> {
  late Future<DocumentSnapshot> eventDetailsFuture;
  late Event? event;

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
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this event?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await _deleteEvent(context, eventId);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteEvent(BuildContext context, String eventId) async {
    try {
      await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
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
            title: Text('Error'),
            content: Text('Failed to delete event: $error'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _deleteEntryCoordinator(String eventId) async {
    try {
      await FirebaseFirestore.instance.collection('coordinators').doc(eventId).delete();
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

      Event event = Event.fromSnapshot(eventSnapshot);

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

  Future<void> _sendFCMNotification(String deviceToken, Event event) async {
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
            'body': 'The event you were invited to has been deleted. Please check the details.',
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
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
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
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
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
              ? DateFormat('dd MMM yyyy, hh:mm a').format(dateAndTime)
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
            'Pending Invitees': _calculatePendingInvitees(eventData).length.toDouble(),
          };
          Map<String, Color> colorMap = {
            'Accepted Invitees': Colors.green,
            'Rejected Invitees': Colors.red,
            'Pending Invitees': Colors.orange,
          };

          // Check if the event is in the past
          bool isPastEvent = dateAndTime != null && dateAndTime.isBefore(DateTime.now());

          return ListView(
            padding: EdgeInsets.all(30.20),
            children: [
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
                  subtitle: Text('${eventData['numberOfInvitees'] ?? 'N/A'}',
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
                  subtitle: Text(_formatDuration(eventData['duration'] ?? 0),
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
                    'Date and Time',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  subtitle: Text(formattedDate,
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
                        Icons.access_time,
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
                          Container(height: 2, color: Color(0xFF9a85a4)),
                          SizedBox(height: 5),
                          ExpansionTile(
                            title: Text('Accepted Attendees (${acceptedInvitees.length})'),
                            leading: Icon(Icons.check_circle, color: Colors.green),
                            children: [
                              FutureBuilder<List<String?>>(
                                future: Future.wait(
                                  acceptedInvitees.map((phoneNumber) => _getFullNameFromPhoneNumber(phoneNumber)),
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }
                                  List<String?> fullNames = snapshot.data ?? [];
                                  List<Widget> listTiles = [];
                                  for (int i = 0; i < acceptedInvitees.length; i++) {
                                    listTiles.add(
                                      ListTile(
                                        title: Text('${acceptedInvitees[i]} (${fullNames[i] ?? 'Unknown'})'),
                                      ),
                                    );
                                  }
                                  return Column(children: listTiles);
                                },
                              ),
                            ],
                          ),
                          ExpansionTile(
                            title: Text('Rejected Attendees (${rejectedInvitees.length})'),
                            leading: Icon(Icons.cancel, color: Colors.red),
                            children: [
                              FutureBuilder<List<String?>>(
                                future: Future.wait(
                                  rejectedInvitees.map((phoneNumber) => _getFullNameFromPhoneNumber(phoneNumber)),
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }
                                  List<String?> fullNames = snapshot.data ?? [];
                                  List<Widget> listTiles = [];
                                  for (int i = 0; i < rejectedInvitees.length; i++) {
                                    listTiles.add(
                                      ListTile(
                                        title: Text('${rejectedInvitees[i]} (${fullNames[i] ?? 'Unknown'})'),
                                      ),
                                    );
                                  }
                                  return Column(children: listTiles);
                                },
                              ),
                            ],
                          ),
                          ExpansionTile(
                            title: Text('Pending Attendees (${_calculatePendingInvitees(eventData).length})'),
                            leading: Icon(Icons.access_time, color: Colors.orange),
                            children: [
                              FutureBuilder<List<String?>>(
                                future: Future.wait(
                                  _calculatePendingInvitees(eventData).map((phoneNumber) => _getFullNameFromPhoneNumber(phoneNumber)),
                                ),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }
                                  List<String?> fullNames = snapshot.data ?? [];
                                  List<Widget> listTiles = [];
                                  for (int i = 0; i < _calculatePendingInvitees(eventData).length; i++) {
                                    listTiles.add(
                                      ListTile(
                                        title: Text('${_calculatePendingInvitees(eventData)[i]} (${fullNames[i] ?? 'Unknown'})'),
                                      ),
                                    );
                                  }
                                  return Column(children: listTiles);
                                },
                              ),
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
                            Text('Edit', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Color.fromARGB(255, 185, 178, 189),
                        ),
                      ),
                    ),
                  Container(
                    width: 130,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        deleteEvent(context, widget.eventId);
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.delete, color: Colors.white),
                          SizedBox(width: 5),
                          Text('Delete', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Color.fromARGB(255, 230, 82, 71),
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
    var allInvitees = List<String>.from(eventData['inviteesPhoneNumbers'] as List? ?? []);
    var accepted = Set<String>.from(eventData['acceptedInvitees'] as List? ?? []);
    var rejected = Set<String>.from(eventData['rejectedInvitees'] as List? ?? []);
    return allInvitees
        .where((phoneNumber) => !accepted.contains(phoneNumber) && !rejected.contains(phoneNumber))
        .toList();
  }
}
