
import 'package:flutter/material.dart';
import 'package:maazim/CreateEventPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maazim/Home_Host.dart';
import 'package:maazim/my_events_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
/*
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


import 'package:flutter/material.dart';

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
          Padding(padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            child:Text(
            'My Invitations',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30 ),
            ),),
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
*/
import 'package:flutter/material.dart';

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
                    primary: _showUpcomingInvitations
                        ? Color(0xFF9a85a4).withOpacity(0.2)
                        : Color(0xFF9a85a4),
                    fixedSize: Size(171, 30),
                  ),
                  child: Text(
                    ' Past Invitations',
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
          Center(
            child: _showUpcomingInvitations
                ? UpcomingInvitations()
                : PastInvitations(),
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

