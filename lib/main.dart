import 'package:flutter/material.dart';
import 'package:maazim/guestLogIn.dart';
import 'package:maazim/logIn.dart';
import 'package:maazim/signUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:maazim/layoutpage.dart';

Future<void> main() async {
   WidgetsFlutterBinding
      .ensureInitialized(); // Ensure the Flutter binding is initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maazim',
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPage(
      pageTitle: "",
      content: Column(
        children: [
          Image.asset(
            'assets/Logo.PNG',
            width: 160.0,
            height: 160.0,
          ),
          const SizedBox(height: 20),
          const Text(
            'Welcome to Maazim',
            style: TextStyle(fontSize: 50, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
              ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LogIn()),
              ),
               style: ElevatedButton.styleFrom(
                 padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 140),
                 shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                 backgroundColor: const Color(0xFF9a85a4), // Button background color
                 elevation: 0, // Removes shadow
              ),
              child: const Text(
                'Login',
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255))
              ),
            ),

          const SizedBox(height: 20),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GuestLogIn()),
            ),
            child: const Text(
              'Continue as a "Guest"',
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
