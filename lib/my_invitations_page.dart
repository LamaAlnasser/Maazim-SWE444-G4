import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MyInvitationsPage extends StatefulWidget {
  @override
  _MyInvitationsPageState createState() => _MyInvitationsPageState();
}

class _MyInvitationsPageState extends State<MyInvitationsPage> {
  bool _showUpcomingInvitations = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            SizedBox(width: 8),
            Text(
              'My Invitations',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ],
        ),
      ),
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
                    setState(() {
                      _showUpcomingInvitations = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: _showUpcomingInvitations
                        ? Color(0xFF9a85a4)
                        : Color(0xFF9a85a4).withOpacity(0.2),
                    fixedSize: Size(171, 30),
                  ),
                  child: Text(
                    'Upcoming',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showUpcomingInvitations = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: !_showUpcomingInvitations
                        ? Color(0xFF9a85a4)
                        : Color(0xFF9a85a4).withOpacity(0.2),
                    fixedSize: Size(171, 30),
                  ),
                  child: Text(
                    'Past Invitations',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: _showUpcomingInvitations
                ? UpcomingInvitations()
                : PastInvitations(),
          ),
        ],
      ),
    );
  }
}

//Here start Upcoming Invitations
class UpcomingInvitations extends StatefulWidget {
  @override
  _UpcomingInvitationsState createState() => _UpcomingInvitationsState();
}

class _UpcomingInvitationsState extends State<UpcomingInvitations> {
  Future<List<Map<String, dynamic>>> invitationsFuture = Future.value([]);

  String? phoneNumber; // Declare phoneNumber here

  @override
  void initState() {
    super.initState();
    getCurrentUserPhoneNumber().then((phone) {
      if (phone != null && mounted) {
        setState(() {
          // Assign the retrieved phone number to the state variable
          phoneNumber = phone;
        });
        // Now refresh invitations to load the initial data
        refreshInvitations();
      }
    });
  }

  void refreshInvitations() async {
    // Check if phoneNumber is not null
    if (phoneNumber != null) {
      try {
        // Fetch updated invitations from the database
        List<Map<String, dynamic>> updatedInvitations =
            await getInvitationsForUser(phoneNumber!);
        // Update the state to reflect the new data
        setState(() {
          invitationsFuture = Future.value(updatedInvitations);
        });
      } catch (e) {
        print("Error refreshing invitations: $e");
      }
    }
  }

//Get current phone number
  Future<String?> getCurrentUserPhoneNumber() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Try to get the phone number from the users collection first
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String? phoneNumber = userData['phoneNumber'];
        return phoneNumber; // Assuming it's stored without the country code
      } else {
        // If phone number is not available in the users collection, use the one from Authentication
        String? authPhoneNumber = user.phoneNumber;
        if (authPhoneNumber != null && authPhoneNumber.isNotEmpty) {
          // Remove the country code if present
          return authPhoneNumber.replaceFirst(RegExp(r'^\+966'), '');
        }
      }
    }
    return null; // Return null if user is not signed in or phone number is not found
  }

  Future<List<Map<String, dynamic>>> getInvitationsForUser(
      String phoneNumber) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> invitations = [];

    // Current timestamp
    var now = Timestamp.fromDate(DateTime.now());

    print('Getting invitations for phone number: $phoneNumber'); // Debug log

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('events')
          .where('inviteesPhoneNumbers', arrayContains: phoneNumber)
          .where('eventDateTime', isGreaterThan: now) // Only future events
          .get();

      print(
          'Number of upcoming invitations found: ${querySnapshot.docs.length}'); // Debug log

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> invitation = doc.data() as Map<String, dynamic>;
        invitation['id'] = doc.id;
        invitations.add(invitation);
      }

      // Sort invitations: pending first, then accepted, and rejected last
      invitations.sort((a, b) {
        bool aAccepted = a['acceptedInvitees'].contains(phoneNumber);
        bool aRejected = a['rejectedInvitees'].contains(phoneNumber);
        bool bAccepted = b['acceptedInvitees'].contains(phoneNumber);
        bool bRejected = b['rejectedInvitees'].contains(phoneNumber);

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
    // You no longer rely on 'invitationsFuture' being late-initialized.
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
              Timestamp timestamp = invitation['eventDateTime'] as Timestamp;
              DateTime eventDate = timestamp.toDate();
              // Use DateFormat to format the DateTime object
              String formattedDate =
                  DateFormat('EEEE, MMMM d, yyyy, h:mm a').format(eventDate);

              String eventName = invitation['eventName'];
              String inviterName = invitation[
                  'inviterName']; // The name of the person who created the event

              return InkWell(
                onTap: () async {
                  // Navigate to InvitationDetailPage and wait for it to pop off the navigation stack
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InvitationDetailPage(
                          invitation: invitation, phoneNumber: phoneNumber!),
                    ),
                  );

                  // After returning from InvitationDetailPage, refresh the invitations list
                  refreshInvitations();
                },
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
                                    "$formattedDate",
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
                                    "$eventName",
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
                                  "Hosted by: $inviterName",
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
                                  color: invitation['acceptedInvitees']
                                          .contains(phoneNumber)
                                      ? Colors.green
                                      : invitation['rejectedInvitees']
                                              .contains(phoneNumber)
                                          ? Colors.red // Color for Rejected
                                          : Colors
                                              .grey, // Default color for Pending
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(22),
                                      topRight: Radius.circular(22)),
                                ),
                                child: Text(
                                  invitation['acceptedInvitees']
                                          .contains(phoneNumber)
                                      ? "Accepted"
                                      : invitation['rejectedInvitees']
                                              .contains(phoneNumber)
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
          return Center(child: Text("No upcoming invitations at the moment."));
        }
      },
    );
  }
}
//Until here upcoming invitations

//Here start Past Invitations
class PastInvitations extends StatefulWidget {
  @override
  _PastInvitationsState createState() => _PastInvitationsState();
}

class _PastInvitationsState extends State<PastInvitations> {
  Future<List<Map<String, dynamic>>> invitationsFuture = Future.value([]);

  String? phoneNumber; // Declare phoneNumber here

  @override
  void initState() {
    super.initState();
    getCurrentUserPhoneNumber().then((phone) {
      // Make sure to check if the widget is still mounted before calling setState
      if (phone != null && mounted) {
        setState(() {
          // Assign the retrieved phone number to the state variable
          phoneNumber = phone;
          invitationsFuture = getInvitationsForUser(phoneNumber!);
        });
      }
    });
  }

//Get current phone number
  Future<String?> getCurrentUserPhoneNumber() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Try to get the phone number from the users collection first
      DocumentSnapshot userDoc =
          await firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        String? phoneNumber = userData['phoneNumber'];
        return phoneNumber; // Assuming it's stored without the country code
      } else {
        // If phone number is not available in the users collection, use the one from Authentication
        String? authPhoneNumber = user.phoneNumber;
        if (authPhoneNumber != null && authPhoneNumber.isNotEmpty) {
          // Remove the country code if present
          return authPhoneNumber.replaceFirst(RegExp(r'^\+966'), '');
        }
      }
    }
    return null; // Return null if user is not signed in or phone number is not found
  }

  Future<List<Map<String, dynamic>>> getInvitationsForUser(
      String phoneNumber) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> invitations = [];

    // Current timestamp
    var now = Timestamp.fromDate(DateTime.now());

    print('Getting invitations for phone number: $phoneNumber'); // Debug log

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('events')
          .where('inviteesPhoneNumbers', arrayContains: phoneNumber)
          .where('eventDateTime', isLessThan: now) // Only past events
          .get();

      print(
          'Number of past invitations found: ${querySnapshot.docs.length}'); // Debug log

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> invitation = doc.data() as Map<String, dynamic>;
        invitation['id'] = doc.id;
        invitations.add(invitation);
      }

      // Sort invitations: pending first, then accepted, and rejected last
      invitations.sort((a, b) {
        bool aAccepted = a['acceptedInvitees'].contains(phoneNumber);
        bool aRejected = a['rejectedInvitees'].contains(phoneNumber);
        bool bAccepted = b['acceptedInvitees'].contains(phoneNumber);
        bool bRejected = b['rejectedInvitees'].contains(phoneNumber);

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
              Timestamp timestamp = invitation['eventDateTime'] as Timestamp;
              DateTime eventDate = timestamp.toDate();
              // Use DateFormat to format the DateTime object
              String formattedDate =
                  DateFormat('EEEE, MMMM d, yyyy, h:mm a').format(eventDate);

              String eventName = invitation['eventName'];
              String inviterName = invitation[
                  'inviterName']; // The name of the person who created the event

              return InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InvitationDetailPage(
                      invitation: invitation,
                      phoneNumber:
                          phoneNumber!, // Assuming phoneNumber is not null here
                    ),
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
                                    "$formattedDate",
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
                                    "$eventName",
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
                                  "Hosted by: $inviterName",
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
                                  color: invitation['acceptedInvitees']
                                          .contains(phoneNumber)
                                      ? Colors.green
                                      : invitation['rejectedInvitees']
                                              .contains(phoneNumber)
                                          ? Colors.red // Color for Rejected
                                          : Colors
                                              .grey, // Default color for Pending
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(22),
                                      topRight: Radius.circular(22)),
                                ),
                                child: Text(
                                  invitation['acceptedInvitees']
                                          .contains(phoneNumber)
                                      ? "Accepted"
                                      : invitation['rejectedInvitees']
                                              .contains(phoneNumber)
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
          return Center(child: Text("No past invitations at the moment."));
        }
      },
    );
  }
}
//Until here  past invitations

// After tap on the invitation card [Event details+ accept or reject an invitation]
class InvitationDetailPage extends StatefulWidget {
  final Map<String, dynamic> invitation;
  final String phoneNumber; // Add this line

  const InvitationDetailPage({
    Key? key,
    required this.invitation,
    required this.phoneNumber, // Modify the constructor to require a phoneNumber
  }) : super(key: key);

  @override
  _InvitationDetailPageState createState() => _InvitationDetailPageState();
}

class _InvitationDetailPageState extends State<InvitationDetailPage> {
  late bool hasAccepted;
  late bool hasRejected;
  Widget _buildLocationWidget(String location, double fem) {
    Uri? uri = Uri.tryParse(location);
    bool isUrl = uri != null && (uri.scheme == 'http' || uri.scheme == 'https');

    if (isUrl && uri != null) {
      // It's a URL, let's make it tappable
      return CircleAvatar(
        radius: 25 * fem, // Adjust the size to fit your design
        backgroundColor: Color(0xFF9a85a4), // Background color
        child: IconButton(
          icon:
              Icon(Icons.location_on, size: 24 * fem), // Icon inside the button
          color: Colors.white, // Icon color
          onPressed: () async {
            if (await canLaunch(uri.toString())) {
              await launch(uri.toString());
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not launch $location')),
              );
            }
          },
        ),
      );
    } else {
      // It's not a URL, just display it as text
      return Text(
        location,
        style: TextStyle(
            fontSize: 18 * fem,
            color: Color(0xff9a85a4),
            fontWeight: FontWeight.w700),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // No need to fetch the phone number here since it's passed directly
    hasAccepted =
        widget.invitation['acceptedInvitees'].contains(widget.phoneNumber);
    hasRejected =
        widget.invitation['rejectedInvitees'].contains(widget.phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    // Convert the Timestamp to a DateTime object
    DateTime eventDate =
        (widget.invitation['eventDateTime'] as Timestamp).toDate();

    // Format the date and time using DateFormat
    String formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(eventDate);
    String formattedTime = DateFormat('h:mm a')
        .format(eventDate); // Formats to a 12-hour format with AM/PM

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
                      bottomRight: Radius.circular(50 * fem),
                      bottomLeft: Radius.circular(50 * fem),
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
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 30), // Add symmetric horizontal padding
                        child: Text(
                          widget.invitation['eventName'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30 * fem,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
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
                  padding: EdgeInsets.only(
                      top: 35 * fem,
                      left: 16,
                      right: 16), // Added horizontal padding
                  child: Text(
                    "${widget.invitation['inviterName']} \nInvites you to ${widget.invitation['eventName']}!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20 * fem,
                      color: Color(0xff9a85a4),
                      fontWeight: FontWeight.w700,
                    ),
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
                        fontSize: 20 * fem,
                        color: Color(0xff9a85a4),
                        fontWeight: FontWeight.w700),
                  ),
                ),
                //Location:
                // Location Display Handling
                Padding(
                  padding: EdgeInsets.only(top: 6 * fem),
                  child: _buildLocationWidget(
                      widget.invitation['eventLocation'], fem),
                ),

                //end location
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
                //back to?
                Navigator.of(context).pop();
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
    String eventID = widget.invitation['id'];
    String guestIdentifier = widget.phoneNumber;
    String qrData = '$eventID|$guestIdentifier';
    DateTime eventDate =
        (widget.invitation['eventDateTime'] as Timestamp).toDate();
    DateTime now = DateTime.now();

    if (hasAccepted && eventDate.isAfter(now)) {
      // Event date is in the future, display QR code
      return Column(
        children: [
          Text(
            "You have accepted this invitation.",
            style: TextStyle(
                color: Colors.green, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 10), // Space between text and QR code
          Text(
            "Scan this QR code at the event entrance.",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.black, fontSize: 14, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 11), // Space between instruction text and QR code
          QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: 150.0,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square, // Set the eye shape to square
              color: Color.fromARGB(
                  255, 255, 255, 255), // Set the color of the QR code eyes
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape
                  .square, // Set the data module shape to square
              color: Color.fromARGB(255, 255, 255,
                  255), // Set the color of the QR code data modules
            ),
            backgroundColor: Color(0xff9a85a4), // Set the background color
          ),
          // Other UI elements as needed
        ],
      );
    } else if (hasRejected) {
      return Text(
        "You have rejected this invitation.",
        style: TextStyle(
            color: Colors.red, fontSize: 16, fontWeight: FontWeight.w700),
      );
    } else if (hasAccepted && eventDate.isBefore(now)) {
      // Event date is in the past, do not display QR code
      return Text(
        "You have accepted this invitation.",
        style: TextStyle(
            color: Colors.green, fontSize: 16, fontWeight: FontWeight.w700),
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
            fontSize: 23,
            fontWeight: FontWeight.w700,
          ),
        ),
        _verticalDivider(),
        Text(day,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w700,
            )),
        _verticalDivider(),
        Text(monthYear,
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w700,
            )),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 27,
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

    String phoneNumber =
        widget.phoneNumber; // This is the phoneNumber passed to the widget
    String documentId = widget.invitation['id'];

    DocumentReference eventRef =
        FirebaseFirestore.instance.collection('events').doc(documentId);

    // Transaction to update the invitation response
    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(eventRef);

      if (!snapshot.exists) {
        throw Exception("Document does not exist!");
      }
      List<dynamic> acceptedInvitees =
          List.from(snapshot['acceptedInvitees'] ?? []);
      List<dynamic> rejectedInvitees =
          List.from(snapshot['rejectedInvitees'] ?? []);

      if (isAccepted) {
        if (!acceptedInvitees.contains(phoneNumber)) {
          acceptedInvitees.add(phoneNumber);
        }
        rejectedInvitees.remove(phoneNumber);
      } else {
        if (!rejectedInvitees.contains(phoneNumber)) {
          rejectedInvitees.add(phoneNumber);
        }
        acceptedInvitees.remove(phoneNumber);
      }

      transaction.update(eventRef, {
        'acceptedInvitees': acceptedInvitees,
        'rejectedInvitees': rejectedInvitees,
      });
    }).then((value) {
      setState(() {
        hasAccepted = isAccepted;
        hasRejected = !isAccepted;
      });
    });
  }
}
