import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserInvitationsPage extends StatefulWidget {
  const UserInvitationsPage({Key? key}) : super(key: key);

  @override
  _UserInvitationsPageState createState() => _UserInvitationsPageState();
}

class _UserInvitationsPageState extends State<UserInvitationsPage> {
  late Future<List<Map<String, dynamic>>> invitationsFuture;

  @override
  void initState() {
    super.initState();
    String userId =
        FirebaseAuth.instance.currentUser!.uid; // Get current user's ID
    invitationsFuture = getInvitationsForUser(userId);
  }

  Future<List<Map<String, dynamic>>> getInvitationsForUser(
      String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> invitations = [];

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('Invitations')
          .where('guestUserIds', arrayContains: userId)
          .get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> invitation = doc.data() as Map<String, dynamic>;
        invitation['id'] = doc.id; // Include the document ID
        invitations.add(invitation);
      }
      return invitations;
    } catch (e) {
      print("Error getting invitations: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Invitations'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: invitationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<Map<String, dynamic>> invitations = snapshot.data!;
            return ListView.builder(
              itemCount: invitations.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> invitation = invitations[index];
                return InkWell(
                  onTap: () {
                    // Navigate to a detail page to show all invitation details
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                InvitationDetailPage(invitation: invitation)));
                  },
                  child: Card(
                    margin: EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text(invitation['eventName']),
                      subtitle: Text(
                          "Hosted by: ${invitation['nameOfInviter']}\nDate: ${invitation['date'].toDate().toString()}"),
                      isThreeLine: true, // if you want to use the third line
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text("No invitations found."));
          }
        },
      ),
    );
  }
}

class InvitationDetailPage extends StatelessWidget {
  final Map<String, dynamic> invitation;

  const InvitationDetailPage({Key? key, required this.invitation})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(invitation['eventName']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Event: ${invitation['eventName']}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Type: ${invitation['eventType']}"),
            Text("Host: ${invitation['nameOfInviter']}"),
            Text("Date: ${invitation['date'].toDate().toString()}"),
            Text("Time: ${invitation['time']}"),
            Text("Location: ${invitation['eventLocation']}"),
            Text("Address: ${invitation['address']}"),
            // Add more fields as necessary
          ],
        ),
      ),
    );
  }
}
