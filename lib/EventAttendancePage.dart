import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventAttendancePage {
  static Widget buildAttendanceInfo({
    required String eventId,
    required List<String> allInviteesPhoneNumbers,
  }) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('events').doc(eventId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return Text('No data available');
        }

        Map<String, dynamic> eventData = snapshot.data!.data() as Map<String, dynamic>;

        List<String> acceptedInvitees = List<String>.from(eventData['acceptedInvitees'] ?? []);
        List<String> rejectedInvitees = List<String>.from(eventData['rejectedInvitees'] ?? []);

        // Calculate the number of pending invitees
        List<String>pendingInvitees = allInviteesPhoneNumbers
            .where((phoneNumber) =>
                !acceptedInvitees.contains(phoneNumber) &&
                !rejectedInvitees.contains(phoneNumber))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Information:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 22),
            Text('Event Name: ${eventData['eventName']}', style: TextStyle(color: Color(0xFF9a85a4), fontSize: 14)),
            Text('Event Location: ${eventData['eventLocation']}', style: TextStyle(color: Color(0xFF9a85a4), fontSize: 14)),
            Text('Event Type: ${eventData['eventType']}', style: TextStyle(color: Color(0xFF9a85a4), fontSize: 14)),
            Text('Event Date: ${eventData['eventDate']}', style: TextStyle(color: Color(0xFF9a85a4), fontSize: 14)),
            Text('Event Time: ${eventData['eventTime']}', style: TextStyle(color: Color(0xFF9a85a4), fontSize: 14)),
            Text('Inviter Name: ${eventData['inviterName']}', style: TextStyle(color: Color(0xFF9a85a4), fontSize: 14)),
            Text('Number of Invitees: ${eventData['numberOfInvitees']}', style: TextStyle(color: Color(0xFF9a85a4), fontSize: 14)),
            SizedBox(height: 16),
            Text(
              'Accepted Attendees (${acceptedInvitees.length})',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Display accepted invitees
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: acceptedInvitees
                  .map<Widget>((phoneNumber) => ListTile(
                        title: Text(phoneNumber),
                        leading: Icon(Icons.check_circle, color: Colors.green),
                      ))
                  .toList(),
            ),
            SizedBox(height: 16),
            Text(
              'Rejected Attendees (${rejectedInvitees.length})',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            // Display rejected invitees
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rejectedInvitees
                  .map((phoneNumber) => ListTile(
                        title: Text(phoneNumber),
                        leading: Icon(Icons.cancel, color: Colors.red),
                      ))
                  .toList()
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
                  .map<Widget>((phoneNumber) => ListTile(
                        title: Text(phoneNumber),
                        leading: Icon(Icons.access_time, color: Colors.orange),
                      ))
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}
