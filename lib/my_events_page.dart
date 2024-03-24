import 'package:flutter/material.dart';
import 'package:maazim/CreateEventPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maazim/Home_Host.dart';
import 'package:maazim/EventAttendancePage.dart';

class MyEventsPage extends StatefulWidget {
  @override
  _MyEventsPageState createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  bool _showUpcomingEvents = true;

  @override
  Widget build(BuildContext context) {
   return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Padding(padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            child:Text(
            'My Events',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30 ),
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
                      _showUpcomingEvents = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: _showUpcomingEvents
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
                      _showUpcomingEvents = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: _showUpcomingEvents
                        ? Color(0xFF9a85a4).withOpacity(0.2)
                        : Color(0xFF9a85a4),
                    fixedSize: Size(171, 30),
                  ),
                  child: Text(
                    'Past Events',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
              height: 16), // Add some space between buttons and other content
          Expanded(
            // Use Expanded here to take up the remaining space
            child: _showUpcomingEvents ? UpcomingEvents() : PastEvents(),
          )
        ],
      ),
      //add button
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateEventPage(),
              ),
            );
          },
          child: Icon(
            Icons.add,
            size: 36,
            color: Colors.white,
          ),
          backgroundColor: Color(0xFF586258),
          shape: CircleBorder(), // Make the button circular
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

//from above i chancged line 84-85 only
class UpcomingEvents extends StatefulWidget {
  @override 
  _UpcomingEventsState createState() => _UpcomingEventsState();
}

class _UpcomingEventsState extends State<UpcomingEvents> {
  late Future<List<Map<String, dynamic>>> eventsFuture;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    eventsFuture = getHostedEvents();
  }

  Future<List<Map<String, dynamic>>> getHostedEvents() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> events = [];
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await firestore
            .collection('events')
            .where('userId', isEqualTo: user.uid)
            .where('eventDateTime', isGreaterThan: Timestamp.now())
            .get();

        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> event = doc.data() as Map<String, dynamic>;
          event['id'] = doc.id;
          events.add(event);
        }
      } else {
        print('User is not logged in.');
      }
    } catch (e) {
      print("Error getting events: $e");
    }
    return events;
  }
  //end getHostedEvents

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: eventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          List<Map<String, dynamic>> events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> event = events[index];

              Timestamp timestamp = event['eventDateTime'] as Timestamp;
              DateTime eventDate = timestamp.toDate();
              // Use DateFormat to format the DateTime object
              String formattedDate =
                  DateFormat('EEEE, MMMM d, yyyy, h:mm a').format(eventDate);

              String eventName = event['eventName'];
              String inviterName = event[
                  'inviterName']; // The name of the person who created the event
              int numberOfInvitees = event['numberOfInvitees'];

              return InkWell(
                onTap: () => Navigator.push(
                 context,
                 MaterialPageRoute(
                  builder: (context) => EventAttendancePage(
                     eventId: event['id'], // Pass the event ID here
                    eventName: event['eventName'], // Pass the event name here
                     ),
                  ),
                ),
                //Clicking on the card
                //  onTap: () => Navigator.push(
                //      context,
                //      MaterialPageRoute(
                ///       builder: (context) =>
                //          InvitationDetailPage(invitation: invitation),
                //      ),
                //   ),
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
                                    event['eventName'],
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
                                  "Hosted by: ${event['inviterName']}",
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
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(22),
                                      topRight: Radius.circular(22)),
                                ),
                                child: Text(
                                  "Invitees: ${event['numberOfInvitees']}", // Display the number of invitees
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 23),
                ),
              );
            },
          );
        } else {
          return Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center the children vertically
          children: [
            Opacity(opacity: 0.5,
            child: Image.asset(
              'assets/lavender.png', // Replace with your asset image path
              width: 300, // Set your width accordingly
              height: 250, // Set your height accordingly
            ),),
            SizedBox(height: 20), // Add some space between the image and the text
            Text(
              "No Upcoming Events",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10), // Add some space between the image and the text
            Text(
              "To create new events press the + button",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12,fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24), ],),);
        }
      },
    );
  }
}

class PastEvents extends StatefulWidget {
  @override 
  _PastEventsState createState() => _PastEventsState();
}

class _PastEventsState extends State<PastEvents> {
  late Future<List<Map<String, dynamic>>> eventsFuture;

  @override
  void initState() {
    super.initState();
    eventsFuture = getPastEvents();
  }

  Future<List<Map<String, dynamic>>> getPastEvents() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    List<Map<String, dynamic>> events = [];
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        QuerySnapshot querySnapshot = await firestore
            .collection('events')
            .where('userId', isEqualTo: user.uid)
            .where('eventDateTime', isLessThan: Timestamp.now())
            .get();

        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> event = doc.data() as Map<String, dynamic>;
          event['id'] = doc.id;
          events.add(event);
        }
      }
    } catch (e) {
      print("Error getting past events: $e");
    }
    return events;
  }

    @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: eventsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          List<Map<String, dynamic>> events = snapshot.data!;
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> event = events[index];

              Timestamp timestamp = event['eventDateTime'] as Timestamp;
              DateTime eventDate = timestamp.toDate();
              // Use DateFormat to format the DateTime object
              String formattedDate =
                  DateFormat('EEEE, MMMM d, yyyy, h:mm a').format(eventDate);

              String eventName = event['eventName'];
              String inviterName = event[
                  'inviterName']; // The name of the person who created the event
              int numberOfInvitees = event['numberOfInvitees'];

              return InkWell(
                //Clicking on the card
                //  onTap: () => Navigator.push(
                //      context,
                //      MaterialPageRoute(
                ///       builder: (context) =>
                //          InvitationDetailPage(invitation: invitation),
                //      ),
                //   ),
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
                                    event['eventName'],
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
                                  "Hosted by: ${event['inviterName']}",
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
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(22),
                                      topRight: Radius.circular(22)),
                                ),
                                child: Text(
                                  "Invitees: ${event['numberOfInvitees']}", // Display the number of invitees
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 23),
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
                    'assets/lavender.png', // Replace with your asset image path
                    width: 300, // Set your width accordingly
                    height: 200, // Set your height accordingly
                  ),
                ),
                Text(
                  "No Past Events",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  "Looks like there are no events in the past.",
                  style: TextStyle(fontSize: 18),
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