/*
import 'package:flutter/material.dart';

class MyInvitationsPage extends StatelessWidget {
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
                    // Navigate to Upcoming Events
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF9a85a4),
                    fixedSize: Size(170, 30),

                    
                    //padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    'Upcoming',
                    style: TextStyle(color: Colors.white , fontSize: 15 ,fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Past Events
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF9a85a4),
                    fixedSize: Size(170, 30),
                    //padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    'Past Invitations',
                    style: TextStyle(color: Colors.white , fontSize: 15 ,fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16), // Add some space between buttons and other content
          Center(
            child: Text('This is the My Invitations Page'),
          ),
        ],
      ),
    );
    
  }
}
*/

import 'package:flutter/material.dart';

class guestInvitationsPage extends StatefulWidget {
  @override
  _guestInvitationsPageState createState() => _guestInvitationsPageState();
}


class _guestInvitationsPageState extends State<guestInvitationsPage> {
  bool _showUpcomingInvitations = true;

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
                    primary: _showUpcomingInvitations ?  Color(0xFF9a85a4) : Color(0xFF9a85a4).withOpacity(0.2),
                    fixedSize: Size(171, 30),
                  ),
                  child: Text(
                    'Upcoming',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showUpcomingInvitations = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: _showUpcomingInvitations ? Color(0xFF9a85a4).withOpacity(0.2) : Color(0xFF9a85a4),
                    fixedSize: Size(171, 30),
                  ),
                  child: Text(
                    ' Past Invitations',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16), // Add some space between buttons and other content
          Center(
            child: _showUpcomingInvitations ? UpcomingInvitations() : PastInvitations(),
          ),
        ],
      ),
    );
  }
}


class UpcomingInvitations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Upcoming Invitations'),
    );
  }
}

class PastInvitations extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Past Invitations'),
    );
  }
}

