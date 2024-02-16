import 'package:flutter/material.dart';
import 'package:maazim/guestLogIn.dart';
import 'package:maazim/logIn.dart';
import 'package:maazim/signUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:maazim/layout.dart';

Future<void> main() async {
   WidgetsFlutterBinding
      .ensureInitialized(); // Ensure the Flutter binding is initialized
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            width: 180.0,
            height: 180.0,
          ),
          const SizedBox(height: 15),
          const Text(
            'Get Started with Maazim',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
              ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LogIn()),
              ),
               style: ElevatedButton.styleFrom(
                 padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 135),
                 shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                 backgroundColor: const Color(0xFF9a85a4), // Button background color
                 elevation: 2, // Removes shadow
              ),
              child: const Text(
                'Login',
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255))
              ),
            ),

                    const SizedBox(height: 20),
                    // Signup Button
                    ElevatedButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUp())),
                          
                       style: ElevatedButton.styleFrom(
                 padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 128),
                 shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), 
                side: const BorderSide(style: BorderStyle.solid,
                color: Color(0xFF9a85a4),
                ),
                // Rounded corners
                ),
                 backgroundColor: Color.fromARGB(255, 254, 250, 255), // Button background color
                 elevation: 2 // Removes shadow
                        ),
                        child: const Text('Signup',
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color: Color(0xFF9a85a4))
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
              style: TextStyle(fontSize: 15, color: Color(0xFF6D476E)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
