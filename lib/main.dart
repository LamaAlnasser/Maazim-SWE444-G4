import 'package:flutter/material.dart';
import 'package:maazim/guestLogIn.dart';
import 'package:maazim/logIn.dart';
import 'package:maazim/signUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:maazim/layout.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

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
            width: 170.0,
            height: 170.0,
          ),
          const SizedBox(height: 10),
          Image.asset(
            'assets/name.png', // Replace 'name.png' with your image file name
            width: 250.0, // Adjust width as per your requirement
            height: 100.0, // Adjust height as per your requirement
          ),
          const SizedBox(height: 45),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LogIn()),
            ),
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(vertical: 14, horizontal: 135),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              backgroundColor: const Color(0xFF9a85a4),
              elevation: 0,
            ),
            child: const Text(
              'Log In',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255)),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignUp()),
            ),
            style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(vertical: 13, horizontal: 128),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
                side: const BorderSide(
                  style: BorderStyle.solid,
                  color: Color(0xFF9a85a4),
                ),
              ),
              backgroundColor: Color.fromARGB(255, 254, 250, 255),
              elevation: 2,
            ),
            child: const Text(
              'Sign Up',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9a85a4)),
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
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 109, 71, 110)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
