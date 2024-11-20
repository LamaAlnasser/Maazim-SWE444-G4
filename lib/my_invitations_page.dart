import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:maazim/notification.dart';
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Text(
              'My Invitations',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
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
                    backgroundColor: _showUpcomingInvitations
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
                    backgroundColor: !_showUpcomingInvitations
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
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);
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
          // Use the `.where` clause to compare the endTime with the current time
          .get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> invitation = doc.data() as Map<String, dynamic>;
        invitation['id'] = doc.id;

        // Calculate the endTime
        DateTime eventDateTime =
            (invitation['eventDateTime'] as Timestamp).toDate();
        DateTime endTime =
            eventDateTime.add(Duration(hours: invitation['duration']));

        // Print the event name and endTime for debugging
        print('Event "${invitation['eventName']}" endTime: $endTime');

        // Compare endTime with the current time
        if (endTime.isAfter(DateTime.now())) {
          invitations.add(invitation);
          // Check if notification has already been scheduled
          if (invitation['notificationScheduled'] == false) {
            scheduleReminder(invitation);
            // Update Firestore to indicate that a notification has been scheduled
            firestore
                .collection('events')
                .doc(invitation['id'])
                .update({'notificationScheduled': true});
          }
        }
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

  Future<void> scheduleReminder(Map<String, dynamic> invitation) async {
    DateTime eventDateTime =
        (invitation['eventDateTime'] as Timestamp).toDate();
    DateTime reminderTime = eventDateTime.subtract(Duration(days: 2));

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .remainder(100000), // Unique ID for the notification
        channelKey: 'basic_channel',
        title: 'Reminder: ${invitation['eventName']}',
        body: 'Your event is in two days. Don\'t forget to attend it!',
        payload: {'invitationId': '123'},
        notificationLayout: NotificationLayout.Default,
        displayOnForeground: true,
        displayOnBackground: true,
      ),
      schedule: NotificationCalendar.fromDate(date: reminderTime),
    );
    print("notification created");
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
                  // Store the result of the navigation in a variable
                  final updateNeeded = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InvitationDetailPage(
                          invitation: invitation, phoneNumber: phoneNumber!),
                    ),
                  );

                  // Check if the result indicates that an update is needed
                  if (updateNeeded == true) {
                    refreshInvitations(); // Refresh only if an update is needed
                  }
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
          return Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center the children vertically
              children: [
                Opacity(
                  opacity: 0.5,
                  child: Image.asset(
                    'assets/teapot.png', // Replace with your asset image path
                    width: 300, // Set your width accordingly
                    height: 250, // Set your height accordingly
                  ),
                ),
                SizedBox(
                    height:
                        20), // Add some space between the image and the text
                Text(
                  "No Upcoming Invitations",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                    height:
                        10), // Add some space between the image and the text
                Text(
                  "You have to be invited to an event",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),
              ],
            ),
          );
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
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);
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

    bool inPast;
    var now = Timestamp.fromDate(DateTime.now());

    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('events')
          .where('inviteesPhoneNumbers', arrayContains: phoneNumber)
          .get();

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> invitation = doc.data() as Map<String, dynamic>;
        invitation['id'] = doc.id;

        DateTime eventDateTime =
            (invitation['eventDateTime'] as Timestamp).toDate();
        DateTime endTime =
            eventDateTime.add(Duration(hours: invitation['duration']));

        if (endTime.isBefore(now.toDate()) ||
            endTime.isAtSameMomentAs(now.toDate())) {
          inPast = true;
        } else {
          inPast = false;
        }
        if (inPast == true) {
          invitations.add(invitation);
        }
      }

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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: 0.5,
                  child: Image.asset(
                    'assets/teapot.png', // Replace with your asset image path
                    width: 300, // Set your width accordingly
                    height: 250, // Set your height accordingly
                  ),
                ),
                Text(
                  "No Past Invitaions",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  "Looks like there are no invitations in the past.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 24),
              ],
            ),
          );
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
  late bool changed = false;

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
    String inviterName = widget.invitation['inviterName'];
    String eventType = widget.invitation['eventType'];
    String eventImage =
        getEventImage(eventType); // Function to get the image path

    //Display Accept&Reject buttons only with upcoming
    DateTime eventDateTime =
        (widget.invitation['eventDateTime'] as Timestamp).toDate();
    int duration = widget.invitation['duration']; //'duration' is in hours
    DateTime endTime = eventDateTime.add(Duration(hours: duration));
    DateTime now = DateTime.now();

    double fem = MediaQuery.of(context).size.width / 400;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // This will pop the current route and pass the 'changed' variable back to the previous screen
            Navigator.pop(context, changed);
          },
        ),
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(
            mainAxisSize:
                MainAxisSize.min, // Keep the children of the Row centered
            children: [
              Image.asset(
                'assets/Logo.PNG', // Your image asset path
                height: 30, // Adjust the height as needed
              ),
              const SizedBox(width: 8), // Space between the image and the title
              const Text(
                'Maazim',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor:
            Colors.white, // Set the app bar background color to white
      ),
      backgroundColor: Colors.white, // Set the background color to white
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 240.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(eventImage),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                ListTile(
                  title: Padding(
                    padding: const EdgeInsets.only(left: 20.0, top: 9),
                    child: hasRejected
                        ? Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.invitation['eventName'],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  "Rejected",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Text(
                            widget.invitation['eventName'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text("Invited by $inviterName"),
                  ),
                ),

                ListTile(
                  contentPadding: EdgeInsets.only(
                    left: 25.0,
                    top: 5,
                  ),
                  leading: Icon(
                    Icons.calendar_today,
                    size: 25.0, // Smaller icon size
                  ),
                  title: Text(
                    "Date & Time",
                    style: TextStyle(
                      fontSize: 14.0, // Smaller font size
                    ),
                  ),
                  subtitle: Text(
                    formattedDate + ', ' + formattedTime,
                    style: TextStyle(
                      fontSize: 12.0, // Smaller font size
                    ),
                  ),
                ),
                //Location
                ListTile(
                  contentPadding: EdgeInsets.only(left: 25.0),
                  leading: Icon(
                    Icons.location_on,
                    size: 25.0,
                  ),
                  title: Text(
                    "Location",
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                  subtitle: Text(
                    widget.invitation['address'],
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                  trailing: widget.invitation['eventLocation'] != null &&
                          widget.invitation['eventLocation'].isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(
                              right: 15), // Adjust the padding as needed
                          child: IconButton(
                            icon: Icon(Icons.map),
                            onPressed: () async {
                              var url = widget.invitation['eventLocation'];
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                throw 'Could not launch $url';
                              }
                            },
                            color: _getLabelColor(
                                eventType), // Set the icon color to match your theme
                          ),
                        )
                      : null,
                ),

                Divider(),
                _buildAdditionalDetails(),
                Divider(),

                //Buttons in UI
                if (!hasAccepted && !hasRejected && now.isBefore(endTime)) ...[
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
        ],
      ),
    );
  }

  // Helper function to select the appropriate image based on the event type
  String getEventImage(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'conference':
        return 'assets/conference_event.jpg'; // Path to your conference event image in assets
      case 'wedding':
        return 'assets/wedding_event.jpg'; // Path to your wedding event image in assets
      case 'graduation':
        return 'assets/graduation_event.jpg'; // Path to your graduation event image in assets
      case 'exhibition':
        return 'assets/exhibition_event.jpg'; // Path to your exhibition event image in assets
      case 'birthday':
        return 'assets/birthday_event.jpg'; // Path to your birthday event image in assets
      case 'party':
        return 'assets/party_event.jpg'; // Path to your party event image in assets
      default:
        return 'assets/party_event.jpg'; // Path to a default image in case the event type does not match
    }
  }

// Helper function to select the label color based on the event type
  Color _getLabelColor(String eventType) {
    switch (eventType.toLowerCase()) {
      //colors just for now going to change them
      case 'conference':
        return Color(0xFFD9C8C7);
      case 'wedding':
        return Color(0xFFDBD6CF);
      case 'graduation':
        return Color(0xFFFB8ACBA);
      case 'exhibition':
        return Color(0xFFF8D9E9C);
      case 'birthday':
        return Color(0xFFF7FC8AB);
      case 'party':
        return Color(0xFFFADC0AB);
      default:
        return Colors.grey;
    }
  }

// Builds a widget displaying detailed information with dynamic color based on the event type
  Widget _buildAdditionalDetails() {
    Color labelColor = _getLabelColor(widget.invitation[
        'eventType']); // Determine the color once based on the event type

    return Container(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: <Widget>[
          _buildDetailExpanded(
              'Event Type', widget.invitation['eventType'], labelColor),
          Container(
            height: 24,
            child: VerticalDivider(color: Theme.of(context).dividerColor),
          ),
          _buildDetailExpanded('Dress Code',
              widget.invitation['dressCode'] ?? 'None', labelColor),
          Container(
            height: 24,
            child: VerticalDivider(color: Theme.of(context).dividerColor),
          ),
          _buildDetailExpanded(
              'Theme', widget.invitation['theme'] ?? 'None', labelColor),
        ],
      ),
    );
  }

  Widget _buildDetailExpanded(String label, String value, Color labelColor) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(label,
              style: TextStyle(color: labelColor, fontWeight: FontWeight.bold)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  //Buttons for reject/accept
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

//Logic and QR code style
  Widget _responseStatus() {
    String eventID = widget.invitation['id'];
    String guestIdentifier = widget.phoneNumber;
    String qrData = '$eventID|$guestIdentifier';

    //Display QR code when End Time for events didn;t come yet
    DateTime eventDateTime =
        (widget.invitation['eventDateTime'] as Timestamp).toDate();
    int duration = widget.invitation['duration']; //'duration' is in hours
    DateTime endTime = eventDateTime.add(Duration(hours: duration));
    DateTime now = DateTime.now();
    Color labelColor = _getLabelColor(widget.invitation[
        'eventType']); // Determine the color once based on the event type

    if (hasAccepted && now.isBefore(endTime)) {
      // Event date is in the future, display QR code
      return Column(
        children: [
          //SizedBox(height: 0), // Space between text and QR code
          // Text(
          //   "",
          //   textAlign: TextAlign.center,
          //   style: TextStyle(
          //       color: Colors.black, fontSize: 14, fontWeight: FontWeight.w700),
          // ),
          //  SizedBox(height: 11), // Space between instruction text and QR code
          Center(
            // Center the QR code horizontally
            child: QrImageView(
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
              backgroundColor: labelColor, // Set the background color
            ),
          ), // Other UI elements as needed
        ],
      );
    } else if (hasRejected) {
      return Center(
          // Center the text horizontally
          child: Text(
        " ",
        style: TextStyle(
            color: Colors.red, fontSize: 16, fontWeight: FontWeight.w700),
      ));
    } else if (hasAccepted &&
        (now.isAfter(endTime) || now.isAtSameMomentAs(endTime))) {
      // Event date is in the past, do not display QR code
      return Center(
          // Center the text horizontally
          child: Text(
        "You have accepted this invitation.",
        style: TextStyle(
            color: Colors.green, fontSize: 16, fontWeight: FontWeight.w700),
      ));
    }

    return SizedBox
        .shrink(); // Returns an empty widget for better conditional rendering
  }

//Logic
  Future<void> respondToInvitation(bool isAccepted) async {
    // Confirmation dialog
    bool confirm = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                'Confirm Your Response',
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Are you sure you want to ${isAccepted ? 'accept' : 'reject'} this invitation?',
                textAlign: TextAlign.left,
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      backgroundColor: Color(0xFF9a85a4).withOpacity(0.9),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      backgroundColor: Color(0xFF9a85a4).withOpacity(0.9),
                    ),
                    child: Text(isAccepted ? 'Accept' : 'Reject',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ],
            );
          },
        ) ??
        false; // Handling null (tap outside the dialog or pressing the back button returns false)

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
          changed = true;
        }
        rejectedInvitees.remove(phoneNumber);
      } else {
        if (!rejectedInvitees.contains(phoneNumber)) {
          rejectedInvitees.add(phoneNumber);
          changed = true;
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
