import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:maazim/CreateEventPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maazim/Home_Host.dart';
import 'package:maazim/EventAttendancePage.dart';
import 'package:maazim/notification.dart';
import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:collection/collection.dart';

class MyEventsPage extends StatefulWidget {
  @override
  _MyEventsPageState createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  bool _showUpcomingEvents = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Text(
              'My Events',
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
                      _showUpcomingEvents = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showUpcomingEvents
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
                    backgroundColor: _showUpcomingEvents
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
          onPressed: () async {
            // Navigates to the CreateEventPage and waits for a result
            final bool eventCreated = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateEventPage()),
                ) ??
                false;

            // If an event was created, refresh the events list
            if (eventCreated) {
              setState(() {
                // This will cause the widgets to rebuild and fetch new events data
              });
            }
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

class UpcomingEvents extends StatefulWidget {
  @override
  _UpcomingEventsState createState() => _UpcomingEventsState();
}

class _UpcomingEventsState extends State<UpcomingEvents> {
  late Future<List<Map<String, dynamic>>> eventsFuture;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

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
            .get();

        var now = Timestamp.now();
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> event = doc.data() as Map<String, dynamic>;
          event['id'] = doc.id;

          // Calculate the event end time by adding the duration to the event start time
          Timestamp startTime = event['eventDateTime'];
          int durationHours = event['duration'] ?? 1; // default to 0 if not set
          DateTime endTime =
              startTime.toDate().add(Duration(hours: durationHours));

          // Only add to upcoming events if the current time is before the event end time
          if (endTime.isAfter(now.toDate())) {
            events.add(event);
            // Check if notification has already been scheduled
            if (event['notificationScheduled'] == false) {
              scheduleReminder(event);
              // Update Firestore to indicate that a notification has been scheduled
              firestore
                  .collection('events')
                  .doc(event['id'])
                  .update({'notificationScheduled': true});
            }
          }
        }
      } else {
        print('User is not logged in.');
      }
    } catch (e) {
      print("Error getting events: $e");
    }
    return events;
  }

  Future<void> scheduleReminder(Map<String, dynamic> event) async {
    DateTime eventDateTime = (event['eventDateTime'] as Timestamp).toDate();
    DateTime reminderTime = eventDateTime.subtract(Duration(days: 2));

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now()
            .millisecondsSinceEpoch
            .remainder(100000), // Unique ID for the notification
        channelKey: 'basic_channel',
        title: 'Reminder: ${event['eventName']}',
        body: 'Your event is in two days. Don\'t forget to prepare for it!',
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
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      key: scaffoldKey,
      body: FutureBuilder<List<Map<String, dynamic>>>(
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
                String formattedDate =
                    DateFormat('EEEE, MMMM d, yyyy, h:mm a').format(eventDate);

                String eventName = event['eventName'];
                String inviterName = event['inviterName'];
                int numberOfInvitees = event['numberOfInvitees'];

                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EventAttendancePage(eventId: event['id']),
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
                            width: MediaQuery.of(context).size.width - 100,
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
                                          color: Colors.grey, fontSize: 14),
                                      maxLines: 1,
                                    )),
                                Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    child: Text(
                                      eventName,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                    )),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
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
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(22),
                                        topRight: Radius.circular(22)),
                                  ),
                                  child: Text(
                                    "Invitees: $numberOfInvitees",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Positioned(
                        //   right: 28,
                        //   bottom: 10,
                        //   child: Container(
                        //     child: IconButton(
                        //       icon: Stack(
                        //         alignment: Alignment.center,
                        //         children: <Widget>[
                        //           Icon(
                        //             Icons.event, // Calendar icon as the base
                        //             color: index.isEven
                        //                 ? Color.fromARGB(255, 154, 133, 164)
                        //                 : Color.fromARGB(255, 84, 73, 89),
                        //             size:
                        //                 30, // Appropriate size for the calendar icon
                        //           ),
                        //           Positioned(
                        //             top:
                        //                 0, // Positioning the circle with the plus sign
                        //             right: 0,
                        //             child: Container(
                        //               decoration: BoxDecoration(
                        //                 color: Colors
                        //                     .white, // Background color of the circle
                        //                 shape: BoxShape
                        //                     .circle, // Making the background a circle
                        //               ),
                        //               child: Icon(
                        //                 Icons.add, // Plus icon
                        //                 color: index.isEven
                        //                     ? Color.fromARGB(255, 154, 133, 164)
                        //                     : Color.fromARGB(255, 84, 73,
                        //                         89), // Matching icon color for visibility
                        //                 size:
                        //                     15, // Smaller size for the plus sign
                        //               ),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //       onPressed: () {
                        //         // Show the confirmation dialog
                        //         showDialog(
                        //           context: context,
                        //           builder: (BuildContext context) {
                        //             return AlertDialog(
                        //               backgroundColor:
                        //                   Color.fromARGB(255, 255, 255, 255),
                        //               title: Text(
                        //                 'Add to Calendar',
                        //                 style: TextStyle(
                        //                     fontSize: 20,
                        //                     fontWeight: FontWeight.bold),
                        //               ),
                        //               content: Text(
                        //                 'Do you want to add "${eventName}" event to your calendar?',
                        //               ),
                        //               actions: <Widget>[
                        //                 Padding(
                        //                   padding: const EdgeInsets.symmetric(
                        //                       horizontal: 5),
                        //                   child: ElevatedButton(
                        //                     onPressed: () {
                        //                       Navigator.of(context)
                        //                           .pop(); // Close the dialog
                        //                     },
                        //                     style: ElevatedButton.styleFrom(
                        //                       shape: const StadiumBorder(),
                        //                       padding:
                        //                           const EdgeInsets.symmetric(
                        //                               vertical: 10,
                        //                               horizontal: 16),
                        //                       backgroundColor: const Color(
                        //                               0xFF9a85a4)
                        //                           .withOpacity(
                        //                               0.9), // Rounded corners
                        //                     ),
                        //                     child: const Text('Cancel',
                        //                         style: TextStyle(
                        //                             fontSize: 12,
                        //                             fontWeight: FontWeight.bold,
                        //                             color: Color.fromARGB(
                        //                                 255, 255, 255, 255))),
                        //                   ),
                        //                 ),
                        //                 Padding(
                        //                   padding: const EdgeInsets.symmetric(
                        //                       horizontal: 5),
                        //                   child: ElevatedButton(
                        //                     onPressed: () async {
                        //                       Navigator.of(context)
                        //                           .pop(); // Close the dialog

                        //                       // Use a parent context that is still valid
                        //                       final parentContext =
                        //                           scaffoldKey.currentContext!;
                        //                       // Prepare event data to pass to the addToCalendar method
                        //                       Map<String, dynamic> eventData = {
                        //                         'id': event[
                        //                             'id'], // Assuming 'id' is necessary
                        //                         'eventName': event['eventName'],
                        //                         'eventDateTime':
                        //                             event['eventDateTime'],
                        //                         'duration': event['duration'],
                        //                         // Include other necessary event fields
                        //                       };
                        //                       // Call addToCalendar method
                        //                       bool eventAdded =
                        //                           await addToCalendar(
                        //                               eventData, parentContext);
                        //                       if (eventAdded) {
                        //                         showDialog(
                        //                           context: parentContext,
                        //                           builder:
                        //                               (BuildContext context) {
                        //                             return AlertDialog(
                        //                               backgroundColor:
                        //                                   Color.fromARGB(255,
                        //                                       255, 255, 255),
                        //                               title: Text(
                        //                                 'Success',
                        //                                 style: TextStyle(
                        //                                     fontSize: 20,
                        //                                     fontWeight:
                        //                                         FontWeight
                        //                                             .bold),
                        //                               ),
                        //                               content: Text(
                        //                                   "Event has been added to your calendar."),
                        //                               actions: <Widget>[
                        //                                 Padding(
                        //                                   padding:
                        //                                       const EdgeInsets
                        //                                           .symmetric(
                        //                                           horizontal:
                        //                                               5),
                        //                                   child: ElevatedButton(
                        //                                     onPressed: () {
                        //                                       Navigator.of(
                        //                                               context)
                        //                                           .pop(); // Close the dialog
                        //                                     },
                        //                                     style:
                        //                                         ElevatedButton
                        //                                             .styleFrom(
                        //                                       shape:
                        //                                           const StadiumBorder(),
                        //                                       padding:
                        //                                           const EdgeInsets
                        //                                               .symmetric(
                        //                                               vertical:
                        //                                                   10,
                        //                                               horizontal:
                        //                                                   16),
                        //                                       backgroundColor: const Color(
                        //                                               0xFF9a85a4)
                        //                                           .withOpacity(
                        //                                               0.9), // Rounded corners
                        //                                     ),
                        //                                     child: const Text(
                        //                                         'OK',
                        //                                         style: TextStyle(
                        //                                             fontSize:
                        //                                                 12,
                        //                                             fontWeight:
                        //                                                 FontWeight
                        //                                                     .bold,
                        //                                             color: Color
                        //                                                 .fromARGB(
                        //                                                     255,
                        //                                                     255,
                        //                                                     255,
                        //                                                     255))),
                        //                                   ),
                        //                                 ),
                        //                               ],
                        //                             );
                        //                           },
                        //                         );
                        //                       } else {
                        //                         showDialog(
                        //                           context: parentContext,
                        //                           builder:
                        //                               (BuildContext context) {
                        //                             return AlertDialog(
                        //                               backgroundColor:
                        //                                   Color.fromARGB(255,
                        //                                       255, 255, 255),
                        //                               title: Row(
                        //                                 mainAxisAlignment:
                        //                                     MainAxisAlignment
                        //                                         .start,
                        //                                 children: [
                        //                                   Stack(
                        //                                     alignment: Alignment
                        //                                         .center,
                        //                                     children: [
                        //                                       Icon(
                        //                                         Icons.circle,
                        //                                         color: Colors
                        //                                             .red
                        //                                             .withOpacity(
                        //                                                 0.2),
                        //                                         size: 40,
                        //                                       ),
                        //                                       Text(
                        //                                         "!",
                        //                                         style:
                        //                                             TextStyle(
                        //                                           color: Colors
                        //                                               .red,
                        //                                           fontSize: 24,
                        //                                           fontWeight:
                        //                                               FontWeight
                        //                                                   .bold,
                        //                                         ),
                        //                                       ),
                        //                                     ],
                        //                                   ),
                        //                                   const SizedBox(
                        //                                       width: 8),
                        //                                   Text(
                        //                                     'Error',
                        //                                     style: TextStyle(
                        //                                         fontWeight:
                        //                                             FontWeight
                        //                                                 .bold),
                        //                                   ),
                        //                                 ],
                        //                               ),
                        //                               content: Text(
                        //                                   "Event already exists in the calendar."),
                        //                               actions: <Widget>[
                        //                                 Padding(
                        //                                   padding:
                        //                                       const EdgeInsets
                        //                                           .symmetric(
                        //                                           horizontal:
                        //                                               5),
                        //                                   child: ElevatedButton(
                        //                                     onPressed: () {
                        //                                       Navigator.of(
                        //                                               context)
                        //                                           .pop(); // Close the dialog
                        //                                     },
                        //                                     style:
                        //                                         ElevatedButton
                        //                                             .styleFrom(
                        //                                       shape:
                        //                                           const StadiumBorder(),
                        //                                       padding:
                        //                                           const EdgeInsets
                        //                                               .symmetric(
                        //                                               vertical:
                        //                                                   10,
                        //                                               horizontal:
                        //                                                   16),
                        //                                       backgroundColor: const Color(
                        //                                               0xFF9a85a4)
                        //                                           .withOpacity(
                        //                                               0.9), // Rounded corners
                        //                                     ),
                        //                                     child: const Text(
                        //                                         'OK',
                        //                                         style: TextStyle(
                        //                                             fontSize:
                        //                                                 12,
                        //                                             fontWeight:
                        //                                                 FontWeight
                        //                                                     .bold,
                        //                                             color: Color
                        //                                                 .fromARGB(
                        //                                                     255,
                        //                                                     255,
                        //                                                     255,
                        //                                                     255))),
                        //                                   ),
                        //                                 ),
                        //                               ],
                        //                             );
                        //                           },
                        //                         );
                        //                       }
                        //                     },
                        //                     style: ElevatedButton.styleFrom(
                        //                       shape: const StadiumBorder(),
                        //                       padding:
                        //                           const EdgeInsets.symmetric(
                        //                               vertical: 10,
                        //                               horizontal: 16),
                        //                       backgroundColor: const Color(
                        //                               0xFF9a85a4)
                        //                           .withOpacity(
                        //                               0.9), // Rounded corners
                        //                     ),
                        //                     child: const Text('Yes',
                        //                         style: TextStyle(
                        //                             fontSize: 12,
                        //                             fontWeight: FontWeight.bold,
                        //                             color: Color.fromARGB(
                        //                                 255, 255, 255, 255))),
                        //                   ),
                        //                 ),
                        //               ],
                        //             );
                        //           },
                        //         );
                        //       },
                        //     ),
                        //   ),
                        //),
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
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center the children vertically
                children: [
                  Opacity(
                    opacity: 0.5,
                    child: Image.asset(
                      'assets/lavender.png', // Replace with your asset image path
                      width: 300, // Set your width accordingly
                      height: 250, // Set your height accordingly
                    ),
                  ),
                  SizedBox(
                      height:
                          20), // Add some space between the image and the text
                  Text(
                    "No Upcoming Events",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                      height:
                          10), // Add some space between the image and the text
                  Text(
                    "To create new events press the + button",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  static final DeviceCalendarPlugin _deviceCalendarPlugin =
      DeviceCalendarPlugin();

  // Retrieve and show available calendars
  static Future<List<Calendar>> retrieveCalendars() async {
    try {
      var result = await _deviceCalendarPlugin.retrieveCalendars();
      print('Retrieved calendars successfully');
      if (result.isSuccess && result.data != null) {
        print('Number of calendars found: ${result.data!.length}');
        return result.data!;
      }
      print('No calendars found or access not granted');
      return [];
    } catch (e) {
      print('Error retrieving calendars: $e');
      return [];
    }
  }

  // Function to present user with a choice of calendars
  static Future<String?> selectCalendar(BuildContext context) async {
    List<Calendar> calendars = await retrieveCalendars();
    if (calendars.isEmpty) {
      print('No calendars available to select');
      return null;
    }

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          title: Text(
            'Choose a Calendar',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: calendars.map((calendar) {
                return SimpleDialogOption(
                  onPressed: () {
                    // Only proceed if ID is not null
                    if (calendar.id != null) {
                      Navigator.pop(context, calendar.id);
                    } else {
                      print("Selected calendar ID is null, cannot proceed.");
                    }
                  },
                  child: Text(calendar.name ?? 'Unnamed Calendar'),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  // Method to check if the event already exists in the calendar
  static Future<bool> isEventAlreadyInCalendar(
      String calendarId, Map<String, dynamic> event) async {
    final tz.TZDateTime startOriginal = tz.TZDateTime.from(
        (event['eventDateTime'] as Timestamp).toDate(), tz.getLocation('UTC'));
    final tz.TZDateTime start = tz.TZDateTime(
        startOriginal.location,
        startOriginal.year,
        startOriginal.month,
        startOriginal.day,
        startOriginal.hour,
        startOriginal.minute); // Strip seconds and milliseconds

    final int duration = event['duration'];
    final tz.TZDateTime end = start.add(Duration(hours: duration));

    print('Checking if event already exists in calendar...');
    print(
        'Event details - Title: ${event['eventName']}, Start: $start, End: $end');

    var retrieveEventsParams = RetrieveEventsParams(
      startDate: start,
      endDate: end,
    );

    var result = await _deviceCalendarPlugin.retrieveEvents(
        calendarId, retrieveEventsParams);

    if (result.isSuccess && result.data != null) {
      for (var existingEvent in result.data!) {
        tz.TZDateTime existingStart = tz.TZDateTime(
            existingEvent.start!.location,
            existingEvent.start!.year,
            existingEvent.start!.month,
            existingEvent.start!.day,
            existingEvent.start!.hour,
            existingEvent.start!.minute);
        tz.TZDateTime existingEnd = tz.TZDateTime(
            existingEvent.end!.location,
            existingEvent.end!.year,
            existingEvent.end!.month,
            existingEvent.end!.day,
            existingEvent.end!.hour,
            existingEvent.end!.minute);

        if (existingEvent.title == event['eventName'] &&
            existingStart.isAtSameMomentAs(start) &&
            existingEnd.isAtSameMomentAs(end)) {
          print('Event already exists in the calendar');
          return true;
        }
      }
    }

    print('Event does not exist in the calendar');
    return false;
  }

  // Method to add an event to the chosen calendar
  static Future<bool> addToCalendar(
      Map<String, dynamic> event, BuildContext context) async {
    print('Attempting to add event to calendar...');
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
      print('Permissions not granted. Requesting permissions...');
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      if (!permissionsGranted.isSuccess || !permissionsGranted.data!) {
        print('Permissions denied');
        return false;
      }
    }
    print('Permissions granted');

    String? calendarId = await selectCalendar(context);
    if (calendarId == null) {
      print("No calendar selected to add events");
      return false;
    }

    // Check if the event already exists
    bool eventExists = await isEventAlreadyInCalendar(calendarId, event);
    if (eventExists) {
      print('Event already exists in the calendar');
      return false;
    }

    print('Calendar selected, adding event');
    final tz.TZDateTime start = tz.TZDateTime.from(
        (event['eventDateTime'] as Timestamp).toDate(), tz.getLocation('UTC'));
    final tz.TZDateTime end =
        start.add(Duration(hours: event['duration'] ?? 2));

    final Event calendarEvent = Event(
      calendarId,
      title: event['eventName'],
      start: start,
      end: end,
    );

    try {
      await _deviceCalendarPlugin.createOrUpdateEvent(calendarEvent);
      print('Event added/updated successfully');
      return true;
    } catch (e) {
      print('Error creating/updating event: $e');
      return false;
    }
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
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: NotificationController.onActionReceivedMethod,
        onNotificationDisplayedMethod:
            NotificationController.onNotificationDisplayedMethod,
        onNotificationCreatedMethod:
            NotificationController.onNotificationCreatedMethod,
        onDismissActionReceivedMethod:
            NotificationController.onDismissActionReceivedMethod);
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
            .get();

        var now = Timestamp.now();
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> event = doc.data() as Map<String, dynamic>;
          event['id'] = doc.id;

          // Calculate the event end time by adding the duration to the event start time
          Timestamp startTime = event['eventDateTime'];
          int durationHours = event['duration'] ?? 0; // default to 0 if not set
          DateTime endTime =
              startTime.toDate().add(Duration(hours: durationHours));

          // Only add to past events if the current time is after the event end time
          if (endTime.isBefore(now.toDate())) {
            events.add(event);
          }
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
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EventAttendancePage(eventId: event['id']),
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
                    height: 250, // Set your height accordingly
                  ),
                ),
                Text(
                  "No Past Events",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  "Looks like there are no events in the past.",
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
