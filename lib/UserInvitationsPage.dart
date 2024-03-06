import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
            return ListView.builder(
              itemCount: invitations.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> invitation = invitations[index];
                // Format the date and time
                DateTime eventDate = (invitation['date'] as Timestamp).toDate();
                String formattedDate =
                    DateFormat('EEEE, MMMM d, yyyy').format(eventDate);
                String formattedTime = DateFormat('h:mm a').format(eventDate);
                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          InvitationDetailPage(invitation: invitation),
                    ),
                  ),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                    height: 160,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        Container(
                          height: 136,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            color: index.isEven
                                ? Color.fromARGB(255, 154, 133, 164)
                                : Color.fromARGB(255, 84, 73, 89),
                            boxShadow: [
                              BoxShadow(
                                offset: Offset(0, 15),
                                blurRadius: 27,
                                color: Colors.black12,
                              ),
                            ],
                          ),
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: SizedBox(
                            height: 136,
                            width: MediaQuery.of(context).size.width -
                                100, // Reduced from 200 to 100
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Spacer(),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Text(
                                      "$formattedDate, $formattedTime", // Replace with actual date and time
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                      maxLines:
                                          1, // Ensure the text does not wrap over more than one line
                                    )),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Text(
                                      invitation['eventName'],
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),

                                      maxLines:
                                          1, // Ensure the text does not wrap over more than one line
                                    )),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          20), // Consistent padding for nameOfInviter
                                  child: Text(
                                    "Hosted by: ${invitation['nameOfInviter']}",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: invitation['acceptedUserIds']
                                            .contains(userId)
                                        ? Colors.green
                                        : invitation['rejectedUserIds']
                                                .contains(userId)
                                            ? Colors.red // Color for Rejected
                                            : Colors
                                                .grey, // Default color for Pending
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(22),
                                        topRight: Radius.circular(22)),
                                  ),
                                  child: Text(
                                    invitation['acceptedUserIds']
                                            .contains(userId)
                                        ? "Accepted"
                                        : invitation['rejectedUserIds']
                                                .contains(userId)
                                            ? "Rejected" // Text for Rejected
                                            : "Pending", // Default text for Pending
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text("Oops, no invitations at the moment."));
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
            Text("Location: ${widget.invitation['eventLocationAddress']}"),
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
