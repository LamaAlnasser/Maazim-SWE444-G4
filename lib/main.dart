import 'package:flutter/material.dart';
import 'package:maazim/guestLogIn.dart';
import 'package:maazim/logIn.dart';
import 'package:maazim/signUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

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
      title: 'Maazim Welcome Page',
      debugShowCheckedModeBanner: false,
      home: WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor:
          const Color(0xFF9a85a4), // Background color of the entire page
      body: Column(
        children: [
          // Container for the decorative top border image
          const SizedBox(height: 50),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
               image: AssetImage(
              'assets/images/boarder/white.png'), // Ensure the correct path
                fit: BoxFit.cover,
              ),
            ),
            child: SizedBox(
              height: MediaQuery.of(context).padding.top +
                  40, // Adjust the top space based on status bar height
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(120.0), bottom: Radius.circular(0.0)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(
                        height: 70), // Space for the top inside the white box
                    Image.asset(
                      'assets/Logo.PNG', // Ensure the correct path
                      width: 200.0, // Logo width
                      height: 200.0, // Logo height
                    ),
                    
                  
                    const SizedBox(height: 20),
                    const Text(
                      'Welcome to Maazim',
                      style:
                          TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 20),
                    // Login Button
                    SizedBox(
                      width: 180,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LogIn())),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF9a85a4),
                          shape: const StadiumBorder(),

                        ),
                        child: const Text('Login',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),

/*
                    const SizedBox(height: 20),
                    // Signup Button
                    SizedBox(
                      width: 180,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUp())),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF9a85a4),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text('Signup',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ),*/

                    const SizedBox(height: 20),
                    // Continue as a guest Button
                    TextButton(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const GuestLogIn())),
                      child: const Text('Continue as a "Guest"',
                          style: TextStyle(fontSize: 15, color: Colors.black)),
                    ),
                    const SizedBox(
                        height: 40), // Additional space at the bottom
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
