/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class UserInvitationsPage extends StatefulWidget {
  const UserInvitationsPage({Key? key}) : super(key: key);

  @override
  _UserInvitationsPageState createState() => _UserInvitationsPageState();
}

class _UserInvitationsPageState extends State<UserInvitationsPage> {
  late Future<List<Map<String, dynamic>>> invitationsFuture;
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  bool _showUpcomingInvitations = true;


  @override
  void initState() {
    super.initState();
    invitationsFuture = getInvitationsForUser(userId);
  }

  Future<List<Map<String, dynamic>>> getInvitationsForUser(
      String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> invitations = [];
//to make the pending invitations appear first in the list
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

      // Sort invitations: pending first, then accepted, and rejected last
      invitations.sort((a, b) {
        bool aAccepted = a['acceptedUserIds'].contains(userId);
        bool aRejected = a['rejectedUserIds'].contains(userId);
        bool bAccepted = b['acceptedUserIds'].contains(userId);
        bool bRejected = b['rejectedUserIds'].contains(userId);

        if (!aAccepted && !aRejected && (bAccepted || bRejected)) {
          return -1; // a is pending, should come before b
        } else if ((aAccepted || aRejected) && !bAccepted && !bRejected) {
          return 1; // b is pending, should come before a
        } else {
          return 0; // Keep original order if both are the same type
        }
      });

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
        automaticallyImplyLeading: false, // Remove the back button
        title: Row(
          children: [
            SizedBox(width: 8), // Add space between the icon and the title
            Text(
              'My Invitations',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ],
        ),
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
                // Format the date and time
                DateTime eventDate = (invitation['date'] as Timestamp).toDate();
                String formattedDate =
                    DateFormat('EEEE, MMMM d, yyyy').format(eventDate);
                String formattedTime = invitation['time'];
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
    DateTime eventDate = (widget.invitation['date'] as Timestamp).toDate();
    String formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(eventDate);
    String formattedTime =
        widget.invitation['time']; // Use the time directly as a string

    double fem = MediaQuery.of(context).size.width / 400;
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 30 * fem),
                  decoration: BoxDecoration(
                    color: Color(0xff9a85a4),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30 * fem),
                      bottomLeft: Radius.circular(30 * fem),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33656cee),
                        offset: Offset(0, 2),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 28 * fem),
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image:
                                AssetImage('assets/images/boarder/white.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: SizedBox(
                          height: MediaQuery.of(context).padding.top + 12 * fem,
                        ),
                      ),
                      SizedBox(height: 10 * fem),
                      Text(
                        widget.invitation['eventName'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30 * fem,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      SizedBox(height: 4 * fem),
                      Text(
                        widget.invitation['eventType'],
                        style: TextStyle(
                            fontSize: 22 * fem,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      SizedBox(height: 0 * fem),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 35 * fem),
                  child: Text(
                    "${widget.invitation['nameOfInviter']} \nInvites you to ${widget.invitation['eventName']}!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20 * fem,
                        color: Color(0xff9a85a4),
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30 * fem),
                  child: _buildDateInformationRow(eventDate),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30 * fem),
                  child: Text(
                    "At $formattedTime",
                    style: TextStyle(
                        fontSize: 18 * fem,
                        color: Color(0xff9a85a4),
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 1 * fem),
                  child: Text(
                    "${widget.invitation['eventLocationAddress']}",
                    style: TextStyle(
                        fontSize: 16 * fem,
                        color: Color(0xff9a85a4),
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20 * fem),
                  child: Text(
                    "Looking Forward!",
                    style: TextStyle(
                        fontSize: 20 * fem,
                        color: Color(0xff9a85a4),
                        fontWeight: FontWeight.w700),
                  ),
                ),
                if (!hasAccepted && !hasRejected) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _responseButton(true, fem),
                      _responseButton(false, fem),
                    ],
                  ),
                ] else ...[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: _responseStatus(),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: 50 *
                fem, // Adjust as needed to place it at the desired position from the bottom
            left: 20 *
                fem, // Adjust as needed to place it at the desired position from the left
            child: IconButton(
              icon: Icon(Icons.arrow_back,
                  color: Colors.black), // Customize as needed
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => UserInvitationsPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _responseButton(bool isAccepted, double fem) {
    return Padding(
      padding: EdgeInsets.only(
          top: 21.0 * fem,
          right: isAccepted ? 0 * fem : 0,
          left: isAccepted ? 0 : 0 * fem),
      child: OutlinedButton(
        onPressed: () => respondToInvitation(isAccepted),
        style: OutlinedButton.styleFrom(
          shape: CircleBorder(),
          side: BorderSide(
            width: 2.0,
            color: isAccepted
                ? Color.fromRGBO(29, 197, 139, 1)
                : Color.fromRGBO(233, 51, 75, 1),
          ),
          minimumSize: Size(50 * fem, 50 * fem),
        ),
        child: Icon(
          isAccepted ? Icons.check : Icons.close,
          color: isAccepted ? Color(0xff009606) : Color(0xffff2828),
          size: 24.0 * fem,
        ),
      ),
    );
  }

  Widget _responseStatus() {
    if (hasAccepted) {
      return Text(
        "You have accepted this invitation.",
        style: TextStyle(
            color: Colors.green, fontSize: 16, fontWeight: FontWeight.w700),
      );
    } else if (hasRejected) {
      return Text(
        "You have rejected this invitation.",
        style: TextStyle(
            color: Colors.red, fontSize: 16, fontWeight: FontWeight.w700),
      );
    }
    return SizedBox
        .shrink(); // Returns an empty widget for better conditional rendering
  }

  Widget _buildDateInformationRow(DateTime eventDate) {
    final dayOfWeek = DateFormat('EEEE').format(eventDate);
    final day = DateFormat('d').format(eventDate);
    final monthYear = DateFormat('MMM yyyy').format(eventDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          dayOfWeek,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        _verticalDivider(),
        Text(day,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            )),
        _verticalDivider(),
        Text(monthYear,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            )),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 24,
      child: VerticalDivider(
        color: Colors.black,
        thickness: 2,
      ),
    );
  }

  Future<void> respondToInvitation(bool isAccepted) async {
    // Confirmation dialog
    bool confirm = await showCupertinoDialog<bool>(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: Text('Confirm Your Response'),
            content: Text(
                'Are you sure you want to ${isAccepted ? 'accept' : 'reject'} this invitation?'),
            actions: <Widget>[
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(isAccepted ? 'Accept' : 'Reject'),
              ),
            ],
          ),
        ) ??
        false; // Handling null (tap outside the dialog or pressing cancel returns false)

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
*/

/*
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class UserInvitationsPage extends StatefulWidget {
  const UserInvitationsPage({Key? key}) : super(key: key);

  @override
  _UserInvitationsPageState createState() => _UserInvitationsPageState();
}

class _UserInvitationsPageState extends State<UserInvitationsPage> {
  late Future<List<Map<String, dynamic>>> upcomingInvitationsFuture;
  late Future<List<Map<String, dynamic>>> pastInvitationsFuture;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    upcomingInvitationsFuture = getInvitationsForUser(true);
    pastInvitationsFuture = getInvitationsForUser(false);
  }

  Future<List<Map<String, dynamic>>> getInvitationsForUser(bool upcoming) async {
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

      // Sort invitations: pending first, then accepted, and rejected last
      invitations.sort((a, b) {
        bool aAccepted = a['acceptedUserIds'].contains(userId);
        bool aRejected = a['rejectedUserIds'].contains(userId);
        bool bAccepted = b['acceptedUserIds'].contains(userId);
        bool bRejected = b['rejectedUserIds'].contains(userId);

        if (!aAccepted && !aRejected && (bAccepted || bRejected)) {
          return -1; // a is pending, should come before b
        } else if ((aAccepted || aRejected) && !bAccepted && !bRejected) {
          return 1; // b is pending, should come before a
        } else {
          return 0; // Keep original order if both are the same type
        }
      });

      if (upcoming) {
        return invitations.where((invitation) {
          DateTime eventDate = (invitation['date'] as Timestamp).toDate();
          return eventDate.isAfter(DateTime.now());
        }).toList();
      } else {
        return invitations.where((invitation) {
          DateTime eventDate = (invitation['date'] as Timestamp).toDate();
          return eventDate.isBefore(DateTime.now());
        }).toList();
      }
    } catch (e) {
      print("Error getting invitations: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          //i add this
          automaticallyImplyLeading: false, // Remove the back button
        title: Row(
          children: [
            SizedBox(width: 8), // Add space between the icon and the title
            Text(
              'My Invitations',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ],
        ),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildInvitationsList(upcomingInvitationsFuture),
            _buildInvitationsList(pastInvitationsFuture),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationsList(Future<List<Map<String, dynamic>>> invitationsFuture) {
    return FutureBuilder<List<Map<String, dynamic>>>(
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
              String formattedTime = invitation['time'];
             // Check if the event is in the past
  bool isPastEvent = eventDate.isBefore(DateTime.now());

return isPastEvent ? _buildPastInvitationCard(invitation, formattedDate, formattedTime) : _buildUpcomingInvitationCard(invitation, formattedDate, formattedTime);
            },
          );
        } else {
          return Center(child: Text("Oops, no invitations at the moment."));
        }
      },
    );
  }
  Widget _buildPastInvitationCard(Map<String, dynamic> invitation, String formattedDate, String formattedTime) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      height: 160,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Container(
            height: 136,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Colors.purple, // Adjust the color as per your design
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
              width: MediaQuery.of(context).size.width - 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Spacer(),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "$formattedDate, $formattedTime",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                      )),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        invitation['eventName'],
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        maxLines: 1,
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Hosted by: ${invitation['nameOfInviter']}",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildUpcomingInvitationCard(Map<String, dynamic> invitation, String formattedDate, String formattedTime) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => InvitationDetailPage(invitation: invitation),
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
                color: Colors.blue, // Adjust the color as per your design
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
                width: MediaQuery.of(context).size.width - 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Spacer(),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "$formattedDate, $formattedTime",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                        )),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          invitation['eventName'],
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Hosted by: ${invitation['nameOfInviter']}",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: invitation['acceptedUserIds'].contains(userId)
                            ? Colors.green
                            : invitation['rejectedUserIds'].contains(userId)
                                ? Colors.red
                                : Colors.grey,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(22), topRight: Radius.circular(22)),
                      ),
                      child: Text(
                        invitation['acceptedUserIds'].contains(userId)
                            ? "Accepted"
                            : invitation['rejectedUserIds'].contains(userId)
                                ? "Rejected"
                                : "Pending",
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
    DateTime eventDate = (widget.invitation['date'] as Timestamp).toDate();
    String formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(eventDate);
    String formattedTime = widget.invitation['time'];

    double fem = MediaQuery.of(context).size.width / 400;
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 30 * fem),
                  decoration: BoxDecoration(
                    color: Color(0xff9a85a4),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(30 * fem),
                      bottomLeft: Radius.circular(30 * fem),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33656cee),
                        offset: Offset(0, 2),
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 28 * fem),
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/boarder/white.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: SizedBox(
                          height: MediaQuery.of(context).padding.top + 12 * fem,
                        ),
                      ),
                      SizedBox(height: 10 * fem),
                      Text(
                        widget.invitation['eventName'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 30 * fem,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      SizedBox(height: 4 * fem),
                      Text(
                        widget.invitation['eventType'],
                        style: TextStyle(
                            fontSize: 22 * fem,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                      SizedBox(height: 0 * fem),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 35 * fem),
                  child: Text(
                    "${widget.invitation['nameOfInviter']} \nInvites you to ${widget.invitation['eventName']}!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20 * fem,
                        color: Color(0xff9a85a4),
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30 * fem),
                  child: _buildDateInformationRow(eventDate),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30 * fem),
                  child: Text(
                    "At $formattedTime",
                    style: TextStyle(
                        fontSize: 18 * fem,
                        color: Color(0xff9a85a4),
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 1 * fem),
                  child: Text(
                    "${widget.invitation['eventLocationAddress']}",
                    style: TextStyle(
                        fontSize: 16 * fem,
                        color: Color(0xff9a85a4),
                        fontWeight: FontWeight.w700),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20 * fem),
                  child: Text(
                    "Looking Forward!",
                    style: TextStyle(
                        fontSize: 20 * fem,
                        color: Color(0xff9a85a4),
                        fontWeight: FontWeight.w700),
                  ),
                ),
                if (!hasAccepted && !hasRejected) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _responseButton(true, fem),
                      _responseButton(false, fem),
                    ],
                  ),
                ] else ...[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: _responseStatus(),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            top: 50 * fem,
            left: 20 * fem,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => UserInvitationsPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _responseButton(bool isAccepted, double fem) {
    return Padding(
      padding: EdgeInsets.only(
          top: 21.0 * fem,
          right: isAccepted ? 0 * fem : 0,
          left: isAccepted ? 0 : 0 * fem),
      child: OutlinedButton(
        onPressed: () => respondToInvitation(isAccepted),
        style: OutlinedButton.styleFrom(
          shape: CircleBorder(),
          side: BorderSide(
            width: 2.0,
            color: isAccepted ? Color.fromRGBO(29, 197, 139, 1) : Color.fromRGBO(233, 51, 75, 1),
          ),
          minimumSize: Size(50 * fem, 50 * fem),
        ),
        child: Icon(
          isAccepted ? Icons.check : Icons.close,
          color: isAccepted ? Color(0xff009606) : Color(0xffff2828),
          size: 24.0 * fem,
        ),
      ),
    );
  }

  Widget _responseStatus() {
    if (hasAccepted) {
      return Text(
        "You have accepted this invitation.",
        style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.w700),
      );
    } else if (hasRejected) {
      return Text(
        "You have rejected this invitation.",
        style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.w700),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildDateInformationRow(DateTime eventDate) {
    final dayOfWeek = DateFormat('EEEE').format(eventDate);
    final day = DateFormat('d').format(eventDate);
    final monthYear = DateFormat('MMM yyyy').format(eventDate);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          dayOfWeek,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        _verticalDivider(),
        Text(
          day,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        _verticalDivider(),
        Text(
          monthYear,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 24,
      child: VerticalDivider(
        color: Colors.black,
        thickness: 2,
      ),
    );
  }

  Future<void> respondToInvitation(bool isAccepted) async {
    bool confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text('Confirm Your Response'),
        content: Text('Are you sure you want to ${isAccepted ? 'accept' : 'reject'} this invitation?'),
        actions: <Widget>[
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(isAccepted ? 'Accept' : 'Reject'),
          ),
        ],
      ),
    ) ?? false;

    if (!confirm) return;

    String userId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference invitationRef =
        FirebaseFirestore.instance.collection('Invitations').doc(widget.invitation['id']);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(invitationRef);

      if (!snapshot.exists) {
        throw Exception("Document does not exist!");
      }
      List<dynamic> acceptedUserIds = List.from(snapshot['acceptedUserIds'] ?? []);
      List<dynamic> rejectedUserIds = List.from(snapshot['rejectedUserIds'] ?? []);

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

*/

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class UserInvitationsPage extends StatefulWidget {
  const UserInvitationsPage({Key? key}) : super(key: key);

  @override
  _UserInvitationsPageState createState() => _UserInvitationsPageState();
}

class _UserInvitationsPageState extends State<UserInvitationsPage> {
  late Future<List<Map<String, dynamic>>> upcomingInvitationsFuture;
  late Future<List<Map<String, dynamic>>> pastInvitationsFuture;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    upcomingInvitationsFuture = getUpcomingInvitationsForUser(userId);
    pastInvitationsFuture = getPastInvitationsForUser(userId);
  }

  Future<List<Map<String, dynamic>>> getUpcomingInvitationsForUser(
      String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> invitations = [];
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('Invitations')
          .where('guestUserIds', arrayContains: userId)
          .where('date', isGreaterThan: Timestamp.now())
          .get();
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> invitation = doc.data() as Map<String, dynamic>;
        invitation['id'] = doc.id;
        invitations.add(invitation);
      }
      return invitations;
    } catch (e) {
      print("Error getting upcoming invitations: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPastInvitationsForUser(
      String userId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> invitations = [];
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('Invitations')
          .where('guestUserIds', arrayContains: userId)
          .where('date', isLessThan: Timestamp.now())
          .get();
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> invitation = doc.data() as Map<String, dynamic>;
        invitation['id'] = doc.id;
        invitations.add(invitation);
      }
      return invitations;
    } catch (e) {
      print("Error getting past invitations: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Invitations')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF9a85a4),
                  ),
                  child: Text(
                    'Upcoming',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF9a85a4),
                  ),
                  child: Text(
                    'Past Invitations',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: _buildInvitationsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInvitationsList() {
    return ListView(
      children: [
        FutureBuilder<List<Map<String, dynamic>>>(
          future: upcomingInvitationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              List<Map<String, dynamic>> upcomingInvitations = snapshot.data!;
              return _buildInvitationsSection("Upcoming", upcomingInvitations);
            } else {
              return SizedBox(); // No upcoming invitations
            }
          },
        ),
        FutureBuilder<List<Map<String, dynamic>>>(
          future: pastInvitationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              List<Map<String, dynamic>> pastInvitations = snapshot.data!;
              return _buildInvitationsSection("Past", pastInvitations);
            } else {
              return SizedBox(); // No past invitations
            }
          },
        ),
      ],
    );
  }

  Widget _buildInvitationsSection(
      String sectionTitle, List<Map<String, dynamic>> invitations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
          child: Text(
            sectionTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Divider(),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: invitations.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> invitation = invitations[index];
            // Build invitation card here
            return ListTile(
              title: Text(invitation['eventName']),
              subtitle: Text(
                "Date: ${DateFormat('yyyy-MM-dd').format(invitation['date'].toDate())}",
              ),
              onTap: () {
                // Handle tap on invitation
              },
            );
          },
        ),
      ],
    );
  }
}

