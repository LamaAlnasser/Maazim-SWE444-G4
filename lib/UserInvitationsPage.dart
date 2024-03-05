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
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
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
        invitation['id'] = doc.id;
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
      appBar: AppBar(title: Text('Your Invitations')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: invitationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            List<Map<String, dynamic>> invitations = snapshot.data!;
            //Crads
            return ListView.builder(
              itemCount: invitations.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> invitation = invitations[index];
                bool accepted = invitation['acceptedUserIds'].contains(userId);
                bool rejected = invitation['rejectedUserIds'].contains(userId);

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(invitation['eventName']),
                    subtitle: Text("Hosted by: ${invitation['nameOfInviter']}"),
                    trailing: accepted
                        ? Icon(Icons.check, color: Colors.green)
                        : (rejected
                            ? Icon(Icons.close, color: Colors.red)
                            : null),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InvitationDetailPage(
                            invitation: invitation,
                          ),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          // Update the list of invitations based on the result
                        });
                      }
                    },
                  ),
                );
              },
            );
          } else {
            return Center(
                child: Text(
                    "Oops, no invitations at the moment \u{1F614}\n Keep an eye out for surprises soon!"));
          }
        },
      ),
    );
  }
}

// After tap on the invitation card [Event details+ accept or reject an invitation]
class InvitationDetailPage extends StatefulWidget {
  final Map<String, dynamic> invitation;

  const InvitationDetailPage({Key? key, required this.invitation})
      : super(key: key);

  @override
  _InvitationDetailPageState createState() => _InvitationDetailPageState();
}

class _InvitationDetailPageState extends State<InvitationDetailPage> {
  late bool hasAccepted;
  late bool hasRejected;

  @override
  void initState() {
    super.initState();
    String userId = FirebaseAuth.instance.currentUser!.uid;
    hasAccepted = widget.invitation['acceptedUserIds'].contains(userId);
    hasRejected = widget.invitation['rejectedUserIds'].contains(userId);
  }

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.invitation['eventName']),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Event: ${widget.invitation['eventName']}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Type: ${widget.invitation['eventType']}"),
            Text("Host: ${widget.invitation['nameOfInviter']}"),
            Text("Date: ${widget.invitation['date'].toDate().toString()}"),
            Text("Time: ${widget.invitation['time']}"),
            Text("Location: ${widget.invitation['eventLocation']}"),
            Text("Address: ${widget.invitation['address']}"),
            SizedBox(height: 20),
            if (!hasAccepted && !hasRejected)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => respondToInvitation(true),
                    child: Text('Accept'),
                    style: ElevatedButton.styleFrom(primary: Colors.green),
                  ),
                  ElevatedButton(
                    onPressed: () => respondToInvitation(false),
                    child: Text('Reject'),
                    style: ElevatedButton.styleFrom(primary: Colors.red),
                  ),
                ],
              ),
            if (hasAccepted)
              Text("You have accepted this invitation.",
                  style: TextStyle(color: Colors.green, fontSize: 16)),
            if (hasRejected)
              Text("You have rejected this invitation.",
                  style: TextStyle(color: Colors.red, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Future<void> respondToInvitation(bool isAccepted) async {
    // Confirmation dialog
    bool confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                  isAccepted ? 'Accept Invitation?' : 'Reject Invitation?'),
              content: Text(
                  'Are you sure you want to ${isAccepted ? 'accept' : 'reject'} this invitation?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(isAccepted ? 'Accept' : 'Reject'),
                ),
              ],
            );
          },
        ) ??
        false; // Handling null (tap outside the dialog)

    if (!confirm) return; // Exit if not confirmed

    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference invitationRef = FirebaseFirestore.instance
        .collection('Invitations')
        .doc(widget.invitation['id']);

    // Transaction to update the invitation response
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(invitationRef);

      if (!snapshot.exists) {
        throw Exception("Document does not exist!");
      }
      List<dynamic> acceptedUserIds =
          List.from(snapshot['acceptedUserIds'] ?? []);
      List<dynamic> rejectedUserIds =
          List.from(snapshot['rejectedUserIds'] ?? []);

      if (isAccepted) {
        if (!acceptedUserIds.contains(userId)) {
          acceptedUserIds.add(userId);
        }
        rejectedUserIds.remove(userId);
      } else {
        if (!rejectedUserIds.contains(userId)) {
          rejectedUserIds.add(userId);
        }
        acceptedUserIds.remove(userId);
      }

      transaction.update(invitationRef, {
        'acceptedUserIds': acceptedUserIds,
        'rejectedUserIds': rejectedUserIds,
      });
    }).then((value) {
      setState(() {
        hasAccepted = isAccepted;
        hasRejected = !isAccepted;
      });
    });
  }
}
