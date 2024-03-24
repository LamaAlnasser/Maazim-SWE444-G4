// TODO Implement this library.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:maazim/main.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
             Positioned(
            bottom: 25.0,
            right: 15,
            child: ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => WelcomePage(), // Ensure WelcomePage is defined
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 154, 133, 164),
                shape: const CircleBorder(),
                elevation: 0,
                minimumSize: const Size(50, 50),
              ),
              child: const Icon(
                Icons.logout,
                color: Color.fromARGB(255, 255, 255, 255),
                size: 30,
              ),
            ),
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
