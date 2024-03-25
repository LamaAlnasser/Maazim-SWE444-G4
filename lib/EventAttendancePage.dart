import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventAttendancePage extends StatefulWidget {
  final String eventId;

  EventAttendancePage({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventAttendancePageState createState() => _EventAttendancePageState();
}

class _EventAttendancePageState extends State<EventAttendancePage> {
  late Future<Map<String, dynamic>> eventDetailsFuture;

  @override
  void initState() {
    super.initState();
    eventDetailsFuture = getEventDetails(widget.eventId);
  }

  Future<Map<String, dynamic>> getEventDetails(String eventId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot eventSnapshot =
        await firestore.collection('events').doc(eventId).get();
    if (eventSnapshot.exists) {
      return eventSnapshot.data() as Map<String, dynamic>;
    } else {
      throw Exception('Event not found');
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: eventDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          }

          Map<String, dynamic> eventData = snapshot.data!;
          List<String> acceptedInvitees =
              List<String>.from(eventData['acceptedInvitees'] ?? []);
          List<String> rejectedInvitees =
              List<String>.from(eventData['rejectedInvitees'] ?? []);
          List<String> inviteesPhoneNumbers =
              List<String>.from(eventData['inviteesPhoneNumbers'] ?? []);

          // Calculate the number of pending invitees
          List<String> pendingInvitees = inviteesPhoneNumbers
              .where((phoneNumber) =>
                  !acceptedInvitees.contains(phoneNumber) &&
                  !rejectedInvitees.contains(phoneNumber))
              .toList();

          int pendingCount = pendingInvitees.length;

          // Display the details of the event here
          return ListView(
            children: <Widget>[
              ListTile(
                title: Text('Event Name'),
                subtitle: Text(eventData['eventName'] ?? 'N/A'),
              ),
              ListTile(
                title: Text('Event Date and Time'),
                subtitle: Text(
                    eventData['eventDateTime']?.toDate().toString() ?? 'N/A'),
              ),
              ListTile(
                title: Text('Event Location'),
                subtitle: Text(eventData['eventLocation'] ?? 'N/A'),
              ),
              ListTile(
                title: Text('Event Type'),
                subtitle: Text(eventData['eventType'] ?? 'N/A'),
              ),
              ListTile(
                title: Text('Inviter Name'),
                subtitle: Text(eventData['inviterName'] ?? 'N/A'),
              ),
              ListTile(
                title: Text('Number of Invitees'),
                subtitle: Text('${eventData['numberOfInvitees'] ?? 0}'),
              ),
              ListTile(
                title: Text('Accepted Attendees'),
                subtitle: Text(acceptedInvitees.join(', ') ?? 'N/A'),
              ),
              ListTile(
                title: Text('Rejected Attendees'),
                subtitle: Text(rejectedInvitees.join(', ') ?? 'N/A'),
              ),
              ListTile(
                title: Text('Pending Attendees'),
                subtitle: Text(pendingCount.toString()),
              ),
            ],
          );
        },
      ),
    );
  }
}
