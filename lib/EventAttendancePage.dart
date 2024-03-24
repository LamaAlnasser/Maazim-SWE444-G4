import 'dart:html';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:maazim/my_invitations_page.dart';

class EventAttendanceUtils {
  static Widget buildAttendanceInfo({
    required List<String> acceptedInvitees,
    required List<String> rejectedInvitees,
    required List<String> allInviteesPhoneNumbers,
  }) {
    // Calculate the number of pending invitees
    List<String> pendingInvitees = allInviteesPhoneNumbers
        .where((phoneNumber) =>
            !acceptedInvitees.contains(phoneNumber) &&
            !rejectedInvitees.contains(phoneNumber))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Accepted Attendees (${acceptedInvitees.length})',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        // Display accepted invitees
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: acceptedInvitees
              .map((phoneNumber) => ListTile(
                    title: Text(phoneNumber),
                    leading: Icon(Icons.check_circle, color: Colors.green),
                  ))
              .toList(),
        ),
        SizedBox(height: 16),
        Text(
          'Pending Attendees (${pendingInvitees.length})',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        // Display pending invitees
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: pendingInvitees
              .map((phoneNumber) => ListTile(
                    title: Text(phoneNumber),
                    leading: Icon(Icons.access_time, color: Colors.orange),
                  ))
              .toList(),
        ),
      ],
    );
  }
}




/*
class EventAttendancePage extends StatefulWidget {
  final String eventId;

 EventAttendancePage({required this.eventId, required this.eventName});
  @override
  _EventAttendancePageState createState() => _EventAttendancePageState();
}

class _EventAttendancePageState extends State<EventAttendancePage> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> eventDataFuture;

  @override
  void initState() {
    super.initState();
    // Fetch event data from Firestore using the event ID
    eventDataFuture = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Details & Attendance'),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: eventDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.exists) {
            var eventData = snapshot.data!.data()!;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Event Name:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    eventData['eventName'],
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Event Details:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    eventData['eventDetails'],
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Event Location:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    eventData['eventLocation'],
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Event Date & Time:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    eventData['eventDateTime'],
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Attendance:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Display attendance information here
                  // You can retrieve this data from Firestore based on the event ID
                  // For example, you can show the number of attendees who accepted, rejected, or are pending
                   ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green), // Accepted icon
                title: Text('Accepted: 5'), // Number of accepted attendees
              ),
              ListTile(
                leading: Icon(Icons.cancel, color: Colors.red), // Rejected icon
                title: Text('Rejected: 2'), // Number of rejected attendees
              ),
              ListTile(
                leading: Icon(Icons.access_time, color: Colors.orange), // Pending icon
                title: Text('Pending: 3'), // Number of pending attendees
              ),
                ],
              ),
            );
          } else {
            return Center(child: Text('Event not found'));
          }
        },
      ),
    );
  }
}



class EventAttendancePage extends StatefulWidget {
  final String eventId;
  final String eventName;

  EventAttendancePage({required this.eventId, required this.eventName});

  @override
  _EventAttendancePageState createState() => _EventAttendancePageState();
}

class _EventAttendancePageState extends State<EventAttendancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 0, 0),
            child: 
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event: ${widget.eventName}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Event ID: ${widget.eventId}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Attendance Status:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                // Here you can display the number and names of people who accepted, rejected, or are pending
                // For example:
                ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green), // Accepted icon
                  title: Text('Accepted: 5'), // Number of accepted attendees
                ),
                ListTile(
                  leading: Icon(Icons.cancel, color: Colors.red), // Rejected icon
                  title: Text('Rejected: 2'), // Number of rejected attendees
                ),
                ListTile(
                  leading: Icon(Icons.access_time, color: Colors.orange), // Pending icon
                  title: Text('Pending: 3'), // Number of pending attendees
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



class EventAttendancePage extends StatefulWidget {
  final String eventId;
  final String eventName;

  EventAttendancePage({required this.eventId, required this.eventName});

  @override
  _EventAttendancePageState createState() => _EventAttendancePageState();
}

class _EventAttendancePageState extends State<EventAttendancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Attendance'),
        backgroundColor: Colors.deepPurple, // Change app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event: ${widget.eventName}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple, // Change text color
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Event ID: ${widget.eventId}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey, // Change text color
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Attendance Status:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF9a85a4), // Change text color
              ),
            ),
            SizedBox(height: 10),
            // Here you can display the number and names of people who accepted, rejected, or are pending
            // For example:
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green), // Accepted icon
              title: Text('Accepted: 5'), // Number of accepted attendees
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: Colors.red), // Rejected icon
              title: Text('Rejected: 2'), // Number of rejected attendees
            ),
            ListTile(
              leading: Icon(Icons.access_time, color: Colors.orange), // Pending icon
              title: Text('Pending: 3'), // Number of pending attendees
            ),
          ],
        ),
      ),
    );
  }
}








///////////////





 class EventAttendancePage extends StatelessWidget {
  final String eventId;
  final String eventName;

  const EventAttendancePage({
    Key? key,
    required this.eventId,
    required this.eventName,
  }) : super(key: key);

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Attendance: $eventName'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('events').doc(eventId).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }

                Map<String, dynamic> eventData = snapshot.data!.data() as Map<String, dynamic>;

                List<String> acceptedAttendees = List<String>.from(eventData['accepted'] ?? []);
                List<String> rejectedAttendees = List<String>.from(eventData['rejected'] ?? []);
                List<String> pendingAttendees = List<String>.from(eventData['pending'] ?? []);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Accepted Attendees (${acceptedAttendees.length})',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    if (acceptedAttendees.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: acceptedAttendees
                            .map((attendee) => ListTile(
                                  title: Text(attendee),
                                  leading: Icon(Icons.check_circle, color: Colors.green),
                                ))
                            .toList(),
                      )
                    else
                      Text('No accepted attendees'),

                    SizedBox(height: 16),

                    Text(
                      'Rejected Attendees (${rejectedAttendees.length})',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    if (rejectedAttendees.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: rejectedAttendees
                            .map((attendee) => ListTile(
                                  title: Text(attendee),
                                  leading: Icon(Icons.cancel, color: Colors.red),
                                ))
                            .toList(),
                      )
                    else
                      Text('No rejected attendees'),

                    SizedBox(height: 16),

                 /*   Text(
                      'Pending Attendees (${pendingAttendees.length})',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    if (pendingAttendees.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: pendingAttendees
                            .map((attendee) => ListTile(
                                  title: Text(attendee),
                                  leading: Icon(Icons.access_time, color: Colors.orange),
                                ))
                            .toList(),
                      )
                    else
                      Text('No pending attendees'),*/
                      ListTile(
  title: Row(
    children: [
      Icon(Icons.access_time, color: Colors.orange),
      SizedBox(width: 8), // Add some space between the icon and text
      Text(eventName),
    ],
  ),
  onTap: () {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Attendee Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: $attendee'), // Display attendee's name
              Text('Phone Number: ${getNameFromPhoneNumber(attendee)}'), // Display attendee's phone number
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  },
)

                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


//////////////


class EventAttendancePage extends StatelessWidget {
  final String eventId;
  final String eventName;

  const EventAttendancePage({
    Key? key,
    required this.eventId,
    required this.eventName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Attendance: $eventName'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, List<String>>>(
          future: EventAttendanceAnalysis.analyzeAttendance(
            10, // Provide the numberOfInvitees here
            ['552478997', '532094741', '3456789012'], // Provide the inviteesPhoneNumbers here
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              Map<String, List<String>> attendance = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accepted Attendees (${attendance['accepted']!.length})',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Display accepted attendees
                  // Similarly, display rejected and pending attendees
                ],
              );
            } else {
              return Text('No data available');
            }
          },
        ),
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Attendance: $eventName'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
       child:  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          const  Text(
              'Event Information:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 22),
           Text('Event Name :$eventName', style: TextStyle(color: Color(0xFF9a85a4), fontSize: 14)
            ) ,
            Text('Event Type :$KeyEventType', style: const TextStyle(color: Color(0xFF9a85a4), fontSize: 14)
            )
            , Text('Event Location :$KeyLocation', style: TextStyle(color: Color(0xFF9a85a4), fontSize: 14)
            )
          ]
       )
  )
  )
  }

class EventAttendancePage extends StatelessWidget {
  final String eventId;
  final String eventName;
  final int numberOfInvitees;
  final List<String> inviteesPhoneNumbers;

  const EventAttendancePage({
    Key? key,
    required this.eventId,
    required this.eventName, required this.numberOfInvitees, required this.inviteesPhoneNumbers,
  }) : super(key: key);
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Event Attendance: $eventName'),
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         const Text(
            'Event Information:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
         const SizedBox(height: 22),
          Text('Event Name: $eventName', style: TextStyle(color: Color(0xFF9a85a4), fontSize: 14)),
          Text('Event Type: $KeyEventType', style: const TextStyle(color: Color(0xFF9a85a4), fontSize: 14)),
          Text('Event Location: $KeyLocation', style: TextStyle(color: Color(0xFF9a85a4), fontSize: 14)),
        ],
      ),
    ),
  );
}

Widget buildEventAttendance(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Event Attendance: $eventName'),
    ),
    body: FutureBuilder<Map<String, Map<String, dynamic>>>(
      future: EventAttendanceAnalysis.analyzeAttendance(
        numberOfInvitees, // Provide the numberOfInvitees here
        inviteesPhoneNumbers, // Provide the inviteesPhoneNumbers here
      ),
      builder: (BuildContext context, AsyncSnapshot<Map<String, Map<String, dynamic>>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          Map<String, List<String>> attendance = snapshot.data!.cast<String, List<String>>();
          return SingleChildScrollView( // Add a SingleChildScrollView here if needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accepted Attendees (${attendance['accepted']!.length})',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Display accepted attendees
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: attendance['accepted']!.map((phoneNumber) {
                    // You can fetch user name using phone number here
                    // Example: Text('Name: ${fetchUserName(phoneNumber)}'),
                    return ListTile(
                      title: Text(phoneNumber),
                      leading: Icon(Icons.check_circle, color: Colors.green),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                Text(
                  'Rejected Attendees (${attendance['rejected']!.length})',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Display rejected attendees
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: attendance['rejected']!.map((phoneNumber) {
                    // You can fetch user name using phone number here
                    // Example: Text('Name: ${fetchUserName(phoneNumber)}'),
                    return ListTile(
                      title: Text(phoneNumber),
                      leading: Icon(Icons.cancel, color: Colors.red),
                    );
                  }).toList(),
                ),
                SizedBox(height: 16),
                Text(
                  'Pending Attendees (${attendance['pending']!.length})',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Display pending attendees
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: attendance['pending']!.map((phoneNumber) {
                    // You can fetch user name using phone number here
                    // Example: Text('Name: ${fetchUserName(phoneNumber)}'),
                    return ListTile(
                      title: Text(phoneNumber),
                      leading: Icon(Icons.access_time, color: Colors.orange),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        } else {
          return Text('No data available');
        }
      },
    ),
  );
}}
   /*@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Attendance: $eventName'),

       child:FutureBuilder<Map<String, Map<String, dynamic>>> (future: EventAttendanceAnalysis.analyzeAttendance(
          numberOfInvitees, // Provide the numberOfInvitees here
          inviteesPhoneNumbers,// Provide the inviteesPhoneNumbers here
          ), builder: (BuildContext context, AsyncSnapshot<Map<String, Map<String, dynamic>>> snapshot) {  if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              Map<String, List<String>> attendance = snapshot.data!.cast<String, List<String>>();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accepted Attendees (${attendance['accepted']!.length})',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Display accepted attendees
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: attendance['accepted']!.map((phoneNumber) {
                      // You can fetch user name using phone number here
                      // Example: Text('Name: ${fetchUserName(phoneNumber)}'),
                      return ListTile(
                        title: Text(phoneNumber),
                        leading: Icon(Icons.check_circle, color: Colors.green),
                      );
                    }
                    ).toList(),
                  ),
//
                  SizedBox(height: 16),
                  Text(
                    'Rejected Attendees (${attendance['rejected']!.length})',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Display rejected attendees
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: attendance['rejected']!.map((phoneNumber) {
                      // You can fetch user name using phone number here
                      // Example: Text('Name: ${fetchUserName(phoneNumber)}'),
                      return ListTile(
                        title: Text(phoneNumber),
                        leading: Icon(Icons.cancel, color: Colors.red),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Pending Attendees (${attendance['pending']!.length})',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // Display pending attendees
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: attendance['pending']!.map((phoneNumber) {
                      // You can fetch user name using phone number here
                      // Example: Text('Name: ${fetchUserName(phoneNumber)}'),
                      return ListTile(
                        title: Text(phoneNumber),
                        leading: Icon(Icons.access_time, color: Colors.orange),
                      );
                    }).toList(),
                  ),
                ],
              );
            } else {
              return Text('No data available');
            } },
        )
      )
    );
    } }*/
    //
class EventAttendanceAnalysis {
  static Future<Map<String, Map<String, dynamic>>> analyzeAttendance(
      int numberOfInvitees, List<String> inviteesPhoneNumbers) async {
    Map<String, Map<String, dynamic>> attendance = {
      'accepted': {'count': 0, 'icon': Icons.check_circle, 'color': Colors.green},
      'rejected': {'count': 0, 'icon': Icons.cancel, 'color': Colors.red},
      'pending': {'count': 0, 'icon': Icons.access_time, 'color': Colors.orange},
    };
    try {
      // Fetch the responses of invitees from Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('responses')
          .where('eventId', isEqualTo: 'YOUR_EVENT_ID')
          .get();
      // Iterate over the invitees' phone numbers
      for (int i = 0; i < numberOfInvitees; i++) {
        String phoneNumber = inviteesPhoneNumbers[i];   
        // Check if the response for the current invitee exists
        QueryDocumentSnapshot? response = querySnapshot.docs.firstWhere(
          (doc) => doc['phoneNumber'] == phoneNumber,
        );
          if (response != null) {
          // If response exists, categorize the attendee based on the response
          String status = response['status'];
          if (status == 'accepted') {
            attendance['accepted']!['count']++;
          } else if (status == 'rejected') {
            attendance['rejected']!['count']++;
          }}
         else {
          // If no response, consider the attendee as pending
          attendance['pending']!['count']++;
        }
      }
    } catch (e) {
      print('Error analyzing attendance: $e');
    }
    return attendance;
  }
}
/*
class EventAttendanceAnalysis {
  static Future<Map<String, List<String>>> analyzeAttendance(
      int numberOfInvitees, List<String> inviteesPhoneNumbers) async {
    Map<String, List<String>> attendance = {
      'accepted': [],
      'rejected': [],
      'pending': [],
    };

    try {
      // Fetch the responses of invitees from Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('responses')
          .where('eventId', isEqualTo: 'YOUR_EVENT_ID')
          .get();

      // Iterate over the invitees' phone numbers
      for (int i = 0; i < numberOfInvitees; i++) {
        String phoneNumber = inviteesPhoneNumbers[i];
        
        // Check if the response for the current invitee exists
       
        /*QueryDocumentSnapshot response = querySnapshot.docs.firstWhere(
          (doc) => doc['phoneNumber'] == phoneNumber,
          orElse: () => null,
        );*/
// Check if the response for the current invitee exists
QueryDocumentSnapshot? response = querySnapshot.docs.firstWhere(
  (doc) => doc['phoneNumber'] == phoneNumber,
);

        if (response != null) {
          // If response exists, categorize the attendee based on the response
          String status = response['status'];
          switch (status) {
            case 'accepted':
              attendance['accepted']!.add(phoneNumber);
              break;
            case 'rejected':
              attendance['rejected']!.add(phoneNumber);
              break;
            case 'pending':
              attendance['pending']!.add(phoneNumber);
              break;
          }
        } else {
          // If no response, consider the attendee as pending
          attendance['pending']!.add(phoneNumber);
        }
      }
    } catch (e) {
      print('Error analyzing attendance: $e');
    }

    return attendance;
  }
}
///////
/*Future<String> getNameFromPhoneNumber(String phoneNumber) async {
  try {
    // Query Firestore to find the document with the given phone number
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();

    // If a document is found, return the corresponding name
    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first['name'];
    } else {
      // If no document is found, return null or an appropriate default value
      return 'Unknown';
    }
  } catch (e) {
    print('Error getting name from phone number: $e');
    // Handle the error as needed
    return 'Unknown';
  }
}



@override
  _EventAttendancePageState createState() => _EventAttendancePageState();
}

class _EventAttendancePageState extends State<EventAttendancePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Attendance'),
        backgroundColor: Colors.deepPurple, // Change app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event: ${widget.eventName}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple, // Change text color
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Event ID: ${widget.eventId}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey, // Change text color
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Attendance Status:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple, // Change text color
              ),
            ),
            SizedBox(height: 10),
            // Here you can display the number and names of people who accepted, rejected, or are pending
            // For example:
            ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green), // Accepted icon
              title: Text('Accepted: 5'), // Number of accepted attendees
            ),
            ListTile(
              leading: Icon(Icons.cancel, color: Colors.red), // Rejected icon
              title: Text('Rejected: 2'), // Number of rejected attendees
            ),
            ListTile(
              leading: Icon(Icons.access_time, color: Colors.orange), // Pending icon
              title: Text('Pending: 3'), // Number of pending attendees
            ),
          ],
        ),
      ),
    );
  }
}