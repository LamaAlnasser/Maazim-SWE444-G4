
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:maazim/EditEventPage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart'; // Add this import to format the date and time
import 'package:pie_chart/pie_chart.dart';
import  'package:maazim/Event.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:maazim/Home_Host.dart';
import 'package:maazim/EditEventPage.dart';

import 'package:maazim/notification.dart';

//import 'package:awesome_notifications_fcm/awesome_notifications_fcm.dart';
import 'Home_Host.dart';


class EventAttendancePage extends StatefulWidget {
  final String eventId;

  EventAttendancePage({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventAttendancePageState createState() => _EventAttendancePageState();
}

class _EventAttendancePageState extends State<EventAttendancePage> {
  late Future<DocumentSnapshot> eventDetailsFuture;
  
  get dataMap => null;
    late Event? event;
    

  @override
  void initState() {
    super.initState();
    eventDetailsFuture = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get();
        
  }
  

void deleteEvent(BuildContext context, String eventId) {
  // Show confirmation dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () {
              // Dismiss the dialog
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Call the function to delete the event
              _deleteEvent(context, eventId);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Event updated successfully")));
              Navigator.pop(context);
              _sendNotificationsToInvitees(); // To send FCM notifications
              _notifyLocalUpdate();
            },
            child: Text('Delete'),
          ),
        ],
      );
    },
  );
}

  void _sendNotificationsToInvitees() async {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: DateTime.now().microsecondsSinceEpoch.remainder(1000000),
      channelKey: 'basic_channel',
      title: '${event!.eventName} Updated!',
      body: 'The event you are invited to has been Deleted. Please check the details.',
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
      title: 'Event delete',
      body: 'Your event has been deleted. Check out the latest details!',
    ),
  );
}
 
void _deleteEvent(BuildContext context, String eventId) {
  // Delete the event from Firebase
  FirebaseFirestore.instance.collection('events').doc(eventId).delete().then((_) {
    // Show success message
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Event deleted successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                // Close the success dialog
       Navigator.push(
    context,
      MaterialPageRoute(builder: (context) => const homePage()),
     );
                // Navigate back to events page
                // Show a snackbar to indicate successful deletion
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Your deletion is completed.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }).catchError((error) {
    // Show an error message using an alert dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Failed to delete event: $error'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  });
}

void navigateToEditEventPage(BuildContext context, String eventId) {
Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => EditEventPage(eventId: eventId)),
  );

}
/*
void editEvent(BuildContext context, String eventId) async {
  // Show a loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Center(child: CircularProgressIndicator());
    },
  );

  Event? event = await fetchEventByIdFromFirestore(eventId);

  // Dismiss the loading indicator
  Navigator.pop(context);
  if (event != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventPage(eventId: eventId), // Pass the entire event object
      ),
    );
  } else {
    // Handle the case where the event was not found
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Event not found.'))
    );
  }
}



Future<Event?> fetchEventByIdFromFirestore(String eventId) async {
  CollectionReference eventsRef = FirebaseFirestore.instance.collection('events');

  try {
    DocumentSnapshot eventDoc = await eventsRef.doc(eventId).get();
    if (eventDoc.exists && eventDoc.data() != null) {
      Map<String, dynamic> data = eventDoc.data() as Map<String, dynamic>;
      Event event = Event(
        eventName: data['eventName'],
        address: data['address'],
        eventLocation: data['eventLocation'],
        eventType: data['eventType'],
        eventDate: (data['eventDateTime'] as Timestamp).toDate(),
        eventTime: TimeOfDay.fromDateTime((data['eventDateTime'] as Timestamp).toDate()),
        inviterName: data['inviterName'],
        numberOfInvitees: data['numberOfInvitees'],
        inviteesPhoneNumbers: List<String>.from(data['inviteesPhoneNumbers']),
        duration: data['duration'],
      );
      return event;
    }
  } catch (e) {
    print('Error fetching event: $e');
    return null;
  }
  return null;
}



*/



  Future<String?> _getFullNameFromPhoneNumber(String phoneNumber) async {
  try {
    // Query Firestore to find the document where the phoneNumber field matches the given phoneNumber
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('phoneNumber', isEqualTo: phoneNumber)
        .limit(1)
        .get();

    // Check if any documents were found
    if (querySnapshot.docs.isNotEmpty) {
      // Extract first name and last name from the retrieved document
      String firstName = querySnapshot.docs.first.data()['firstName'];
      String lastName = querySnapshot.docs.first.data()['lastName'];
      // Concatenate first name and last name
      String fullName = '$firstName $lastName';
      return fullName;
    } else {
      // No matching document found for the phone number
      return 'Unknown';
    }
  } catch (error) {
    // Error occurred while querying Firestore
    print('Error retrieving full name from Firestore: $error');
    return null;
  }
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
        color: Color(0xFF9a85a4), // Background color for the circle
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.location_on,
          color: Colors.white, // Icon color
          size: 30,
        ),
      ),
    ), 
      title: Text(
       'Address'  ,
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
            width: 100, // Adjust the width as needed
            height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color(0xFF9a85a4), // Button background color
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 2), // changes position of shadow
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


  String _formatDuration(int hours) {
    return '$hours hour${hours != 1 ? 's' : ''}';
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
          return ListView(
            padding: EdgeInsets.all(30.20),
            children: [
       Container(
  decoration: BoxDecoration(
    color: Color.fromARGB(171, 224, 214, 230), // Nurse tangle color
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
        color: Color(0xFF9a85a4), // Background color for the circle
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.event_note,
          color: Colors.white, // Icon color
          size: 30,
        ),
      ),
    ),
  ),
),SizedBox(height: 10),
 Container(
  decoration: BoxDecoration(
    color: Color.fromARGB(171, 224, 214, 230), // Nurse tangle color
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
        color: Color(0xFF9a85a4), // Background color for the circle
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.category,
          color: Colors.white, // Icon color
          size: 30,
        ),
      ),
    ),
  ),
),
SizedBox(height: 10),
 Container(
  decoration: BoxDecoration(
    color: Color.fromARGB(171, 224, 214, 230), // Nurse tangle color
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
        color: Color(0xFF9a85a4), // Background color for the circle
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.person,
          color: Colors.white, // Icon color
          size: 30,
        ),
      ),
    ),
  ),
),SizedBox(height: 10),
 Container(
  decoration: BoxDecoration(
    color: Color.fromARGB(171, 224, 214, 230), // Nurse tangle color
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
        color: Color(0xFF9a85a4), // Background color for the circle
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.people,
          color: Colors.white, // Icon color
          size: 30,
        ),
      ),
    ),
  ),
)
             , SizedBox(height: 10),

 Container(
  decoration: BoxDecoration(
    color: Color.fromARGB(171, 224, 214, 230), // Nurse tangle color
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
    subtitle:Text(_formatDuration(eventData['duration'] ?? 0),
      style: TextStyle(
        fontSize: 15,
      ),
    ),
    leading: Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF9a85a4), // Background color for the circle
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.hourglass_bottom,
          color: Colors.white, // Icon color
          size: 30,
        ),
      ),
    ),
  ),
)
 , SizedBox(height: 10),
Container(
  decoration: BoxDecoration(
    color: Color.fromARGB(171, 224, 214, 230), // Nurse tangle color
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
    subtitle:Text(formattedDate,
      style: TextStyle(
        fontSize: 15,
      ),
    ),
    leading: Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF9a85a4), // Background color for the circle
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.access_time,
          color: Colors.white, // Icon color
          size: 30,
        ),
      ),
    ),
  ),
) ,
              SizedBox(height: 10),
              _buildLocationWidget(
                eventData['address'] ?? 'N/A',
                eventLocation: eventData['eventLocation'],
              ),
              SizedBox(height: 10),
             Container(
  margin: EdgeInsets.all(3), // Add margin to provide spacing from the surrounding widgets
  padding: EdgeInsets.all(3), // Add padding to provide spacing from the container's edge
  decoration: BoxDecoration(
    color: Color(0xFF9a85a4), // Set background color of the container
    borderRadius: BorderRadius.circular(15), // Add rounded corners
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.2), // Set shadow color
        spreadRadius: 2,
        blurRadius: 5,
        offset: Offset(0, 2), // Set shadow offset
      ),
    ],
  ),
  
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch, // Make children expand horizontally
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
        'Attendance Analysis', // Title for the section
        textAlign:TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,shadows: [
      Shadow(
        color: Colors.grey.withOpacity(0.5),
        offset: Offset(2, 2),
        blurRadius: 3,
      ),
    ],
        ),
      ),
        Container( height: 2,color: Color(0xFF9a85a4)),SizedBox(height: 5),
     // Add some space between title and ExpansionTiles

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
          return CircularProgressIndicator(); // Placeholder until data is loaded
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
        return Column(
          children: listTiles,
        );
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
          return CircularProgressIndicator(); // Placeholder until data is loaded
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
        return Column(
          children: listTiles,
        );
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
          return CircularProgressIndicator(); // Placeholder until data is loaded
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
        return Column(
          children: listTiles,
        );
      },
    ),
  ],
),


      SizedBox(height: 15), // Add some space between ExpansionTiles and chart
      Text (textAlign:TextAlign.center,
        'Attendance Chart Analysis', // Title for the chart section
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,shadows: [
      Shadow(
        color: Colors.grey.withOpacity(0.5),
        offset: Offset(2, 2),
        blurRadius: 3,
      ),
    ],
        ),
      ),      Container( height: 2,color: Color(0xFF9a85a4)),

      // Placeholder for attendance chart can be added here

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
  mainAxisAlignment: MainAxisAlignment.spaceAround, // Adjust as needed
  children: [
    Container(
      width: 170,
      height: 40,
      child: ElevatedButton(
        onPressed: () {
             // Navigate to the EditEventPage when the button is pressed
        //editEvent(context ,widget.eventId);
          navigateToEditEventPage(context,widget.eventId);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.edit, color: Colors.white), // Edit icon
            SizedBox(width: 5),
            Text('Edit Event', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: Colors.blue,
        ),
      ),
    ),
    Container(
    width: 170,
      height: 40,
      child: ElevatedButton(
        onPressed: () {
         deleteEvent(context, widget.eventId); 
          // Add your delete button logic here
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete, color: Colors.white), // Delete icon
            SizedBox(width: 5),
            Text('Delete Event', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: Colors.red,
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
  

  // This helper function computes the list of pending invitees.
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
  


}

