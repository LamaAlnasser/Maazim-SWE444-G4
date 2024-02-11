import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maazim Welcome Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9a85a4), // Purple background color
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Container for the top patterned border
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('/Users/hoorrml/Documents/GitHub/Maazim-SWE444-G4/assets/images/boarder/white.png'), // replace with your asset name
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0), // Add padding if necessary
                child: Column(
                  children: <Widget>[
                    Image.asset('/Users/hoorrml/Documents/GitHub/Maazim-SWE444-G4/assets/Logo.PNG', width: 100), // Your logo here
                    const SizedBox(height: 24), // Space between logo and text
                  ],
                ),
              ),
            ),
             const SizedBox(height: 16),
            Expanded(
              // This Container is the white rounded rectangle in the center of the screen
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36.0),
                    topRight: Radius.circular(36.0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Welcome to Maazim',
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24), // Space between text and buttons
                    ElevatedButton(
                      onPressed: () {
                        // Handle Login navigation
                      },
                      child: const Text('Login'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Color(0xFF9a85a4), // Button text color
                        shape: const StadiumBorder(), // Rounded edges
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Handle Signup navigation
                      },
                      child: const Text('Signup'),
                      style: ElevatedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 255, 255, 255), 
                      backgroundColor: Color(0xFF9a85a4), // Text color
                      shape: const StadiumBorder(), // Rounded edges
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Handle Continue as a guest navigation
                      },
                      child: const Text('Continue as a guest'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 0, 0, 0), // Text color
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
