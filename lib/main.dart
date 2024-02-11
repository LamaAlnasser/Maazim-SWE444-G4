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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF9a85a4), // Purple background color
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Container for the top patterned border
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('/Users/hoorrml/Documents/GitHub/Maazim-SWE444-G4/assets/images/boarder/white.png'), // replace with your asset name
                  fit: BoxFit.cover )
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0), // Add padding if necessary
                child: Column(
                  children: <Widget>[
                    Image.asset('/Users/hoorrml/Documents/GitHub/Maazim-SWE444-G4/assets/images/Logo.PNG', width: 100), // Your logo here
                    SizedBox(height: 24), // Space between logo and text
                  ],
                ),
              ),
            ),
            Expanded(
              // This Container is the white rounded rectangle in the center of the screen
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(36.0),
                    topRight: Radius.circular(36.0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Welcome to Maazim',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24), // Space between text and buttons
                    ElevatedButton(
                      onPressed: () {
                        // Handle Login navigation
                      },
                      child: Text('Login'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.deepPurple, // Button background color
                        onPrimary: Colors.white, // Button text color
                        shape: StadiumBorder(), // Rounded edges
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Handle Signup navigation
                      },
                      child: Text('Signup'),
                      style: TextButton.styleFrom(
                        primary: Colors.deepPurple, // Text color
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Handle Continue as a guest navigation
                      },
                      child: Text('Continue as a guest'),
                      style: TextButton.styleFrom(
                        primary: Colors.deepPurple, // Text color
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
