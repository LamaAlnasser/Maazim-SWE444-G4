// TODO Implement this library.
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back button
        title: Row(
          children: [
            SizedBox(width: 8), // Add space between the icon and the title
            Text(
              'Profile',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('This is the Profile Page'),
      ),
    );
  }
}
