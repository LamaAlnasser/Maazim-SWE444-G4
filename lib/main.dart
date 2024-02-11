import 'package:flutter/material.dart';
import 'package:maazim/logIn.dart';
import 'package:maazim/signUp.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maazim Welcome Page',
      home: WelcomePage(),
    );
  }
}

class WelcomePage extends StatelessWidget {
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
              height: 100, // Fixed height for the pattern
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('/Users/hoorrml/Documents/GitHub/Maazim-SWE444-G4/assets/images/boarder/white.png'), // Replace with your asset name
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16), // Space between buttons
            // The rest of the content in a white rounded box
            Expanded(
              child: Stack(
                clipBehavior: Clip.none, // Allows overflow of children outside the box
                alignment: Alignment.topCenter,
                children: [
                  Container(
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
                        const SizedBox(height: 80), // Space for the logo to overlay
                        const Text(
                          'Welcome to Maazim',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32), // Space between text and buttons
                        // Login Button
                        SizedBox(
                          width: 160, // Button width
                          height: 40, // Button height
                          child: ElevatedButton(
                            onPressed: () {
                             Navigator.push(
                               context,
                               MaterialPageRoute(builder: (context) => LogIn()),
                                 );
                            },
                            child: const Text(
                              'Login',
                               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                              ),
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF9a85a4), // Button background color
                              onPrimary: Colors.white, // Button text color
                              shape: const StadiumBorder(), // Rounded edges
                            ),
                          ),
                        ),
                        const SizedBox(height: 16), // Space between buttons
                        // Signup Button
                        SizedBox(
                          width: 160, // Button width
                          height: 40, // Button height
                          child: ElevatedButton(
                            onPressed: () {
                               Navigator.push(
                               context,
                               MaterialPageRoute(builder: (context) => SignUp()),
                                 );
                            },
                            child: const Text(
                              'Signup',
                               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                              ),
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF9a85a4), // Button background color
                              onPrimary: Colors.white, // Button text color
                              shape: const StadiumBorder(), // Rounded edges
                            ),
                          ),
                        ),
                        const SizedBox(height: 16), // Space between buttons
                        // Continue as a guest Button
                        TextButton(
                          onPressed: () {
                            // TODO: Handle Continue as Guest navigation
                          },
                          child: const Text('Continue as a guest', style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 20, // Negative value to position it above the white box
                    child: Image.asset('/Users/hoorrml/Documents/GitHub/Maazim-SWE444-G4/assets/Logo.PNG', width: 160), // Your logo here
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
