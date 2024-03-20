// TODO Implement this library.
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
