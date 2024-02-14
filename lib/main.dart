import 'package:flutter/material.dart';
import 'package:maazim/guestLogIn.dart';
import 'package:maazim/firebase_options.dart';
import 'package:maazim/logIn.dart';
import 'package:maazim/signUp.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.ios
    // FirebaseOptions(
    //   apiKey: "AIzaSyCsszdmqCBqfrGtUN-IPaXvJ0TVnGgOcBQ",
    //   //authDomain: "your-auth-domain", // Replace with your actual authDomain
    //   projectId: "maazim-8c3ef",
    //   storageBucket: "your-storage-bucket", // Replace with your actual storageBucket if applicable
    //   messagingSenderId: "your-messaging-sender-id", // Replace with your actual messagingSenderId if applicable
    //   appId: "your-app-id", // Replace with your actual appId if applicable
    //   measurementId: "your-measurement-id", // Replace with your actual measurementId if applicable
    // ),
  );

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
      backgroundColor: const Color(0xFF9a85a4),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/boarder/white.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: SizedBox(
              height: MediaQuery.of(context).padding.top + 40,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(120.0),
                  bottom: Radius.circular(0.0),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
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
                    SizedBox(
                      width: 180,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LogIn()),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF9a85a4),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 180,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUp()),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF9a85a4),
                          shape: const StadiumBorder(),
                        ),
                        child: const Text(
                          'Signup',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
