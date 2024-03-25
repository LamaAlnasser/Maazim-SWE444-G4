import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart'; // Add this import to format the date and time

class EventAttendancePage extends StatefulWidget {
  final String eventId;

  EventAttendancePage({Key? key, required this.eventId}) : super(key: key);

  @override
  _EventAttendancePageState createState() => _EventAttendancePageState();
}

class _EventAttendancePageState extends State<EventAttendancePage> {
  late Future<DocumentSnapshot> eventDetailsFuture;

  @override
  void initState() {
    super.initState();
    eventDetailsFuture = FirebaseFirestore.instance
        .collection('events')
        .doc(widget.eventId)
        .get();
  }

  Widget _buildLocationWidget(String address, {String? eventLocation}) {
    bool canOpenMap = eventLocation != null && eventLocation.isNotEmpty;
    return ListTile(
      leading: Icon(Icons.location_on, color: Colors.blue),
      title: Text(address),
      subtitle: canOpenMap
          ? Text('Tap to open maps', style: TextStyle(color: Colors.blue))
          : null,
      onTap: canOpenMap
          ? () async {
              if (await canLaunch(eventLocation)) {
                await launch(eventLocation);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not launch maps link')),
                );
              }
            }
          : null,
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

          return ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              ListTile(
                title: Text('Event Name'),
                subtitle: Text(eventData['eventName'] ?? 'N/A'),
                leading: Icon(Icons.event_note, color: Colors.blue),
              ),
              ListTile(
                title: Text('Event Type'),
                subtitle: Text(eventData['eventType'] ?? 'N/A'),
                leading: Icon(Icons.category, color: Colors.blue),
              ),
              ListTile(
                title: Text('Host'),
                subtitle: Text(eventData['inviterName'] ?? 'N/A'),
                leading: Icon(Icons.person, color: Colors.blue),
              ),
              ListTile(
                title: Text('Number of Invitees'),
                subtitle: Text('${eventData['numberOfInvitees'] ?? 'N/A'}'),
                leading: Icon(Icons.people, color: Colors.blue),
              ),
              ListTile(
                title: Text('Duration'),
                subtitle: Text(_formatDuration(eventData['duration'] ?? 0)),
                leading: Icon(Icons.hourglass_bottom, color: Colors.blue),
              ),
              ListTile(
                title: Text('Date and Time'),
                subtitle: Text(formattedDate),
                leading: Icon(Icons.access_time, color: Colors.blue),
              ),
              _buildLocationWidget(
                eventData['address'] ?? 'N/A',
                eventLocation: eventData['eventLocation'],
              ),
              ListTile(
                title: Text('Accepted Attendees'),
                trailing: Text('${acceptedInvitees.length}'),
                leading: Icon(Icons.check_circle, color: Colors.green),
              ),
              ListTile(
                title: Text('Rejected Attendees'),
                trailing: Text('${rejectedInvitees.length}'),
                leading: Icon(Icons.cancel, color: Colors.red),
              ),
              ListTile(
                title: Text('Pending Attendees'),
                trailing: Text(
                  // Check for null and use empty lists as defaults to safely calculate length
                  '${((eventData['inviteesPhoneNumbers'] as List? ?? []).length - (eventData['acceptedInvitees'] as List? ?? []).length - (eventData['rejectedInvitees'] as List? ?? []).length).toString()}',
                ),
                leading: Icon(Icons.access_time, color: Colors.orange),
              ),
            ],
          );
        },
      ),
    );
  }
}
