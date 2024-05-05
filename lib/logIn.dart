import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maazim/Home_Host.dart';
import 'package:maazim/forgetPassword.dart';
import 'package:maazim/layout.dart';
import 'package:maazim/guestLogIn.dart';
import 'package:maazim/main.dart';
import 'package:maazim/signUp.dart';

import 'package:maazim/entryCoordinatorPage.dart';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class LogIn extends StatelessWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _errorMessage;
  bool _obscureText =
      true; // Define the _obscureText variable and initialize it to true

  // Getter method for _obscureText
  bool get obscureText => _obscureText;

  // Setter method for _obscureText
  set obscureText(bool value) {
    setState(() {
      _obscureText = value;
    });
  }

  Future<void> _login(BuildContext context) async {
    try {
      setState(() {
        _errorMessage = null;
      });

      if (_formKey.currentState != null && _formKey.currentState!.validate()) {
        final email = _emailController.text.trim();
        final password = _passwordController.text.trim();

        if (email.isNotEmpty && password.isNotEmpty) {
          // Check if it's an entry coordinator
          if (email.toLowerCase().endsWith('@maazim.com')) {
            bool isValid = await verifyEntryCoordinator(email, password);
            if (isValid) {
              // Remove the "EC_" prefix
              String coordinatorUsername = email.toLowerCase().startsWith('ec_')
                  ? email.substring(3)
                  : email;
              // Remove the "@" symbol and everything after it
              coordinatorUsername = coordinatorUsername.split('@')[0];
              // Redirect to entry coordinator page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => EntityCoordinatorPage(
                        coordinatorUsername: coordinatorUsername)),
              );
            } else {
              // Invalid credentials for entry coordinator
              setState(() {
                _errorMessage =
                    'You have entered wrong email/password, please try again.';
              });
            }
          } else {
            // Host login process
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: password,
            );

            if (FirebaseAuth.instance.currentUser != null) {
              // Redirect to host's home page
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => homePage()),
              );
            } else {
              // User is not authenticated
              setState(() {
                _errorMessage =
                    'You have entered wrong email/password, please try again.';
              });
            }
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.code == 'invalid-credential'
            ? 'You have entered wrong email/password, please try again.'
            : e.message ?? 'An error occurred';
      });
    }
  }

  Future<bool> verifyEntryCoordinator(String email, String password) async {
    // Extract username from email
    String username = email.split('@')[0];

    // Query Firestore for the coordinator with matching username
    var querySnapshot = await FirebaseFirestore.instance
        .collection('coordinators')
        .where('CoordinatorUsername', isEqualTo: username)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return false; // No matching entry coordinator found
    }

    // Assuming there is exactly one match, get the first document
    var doc = querySnapshot.docs.first;
    String storedHashedPassword = doc['hashedPassword'];

    // Hash the entered password
    String enteredHashedPassword = generateHashedPassword(password);
    // Compare the hashed passwords
    return enteredHashedPassword == storedHashedPassword;
  }

  Future<String> fetchCoordinatorUsername(String email) async {
    // Extract username from email
    String username = email.split('@')[0];

    // Query Firestore for the coordinator with matching username
    var querySnapshot = await FirebaseFirestore.instance
        .collection('coordinators')
        .where('CoordinatorUsername', isEqualTo: username)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('No matching entry coordinator found');
    }

    // Assuming there is exactly one match, get the first document
    var doc = querySnapshot.docs.first;
    return doc['CoordinatorUsername'];
  }

  String generateHashedPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPage(
            pageTitle: '',
            content: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Heading
                    const SizedBox(height: 20),
                    Text(
                      "Welcome Back",
                      style:
                          TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Please enter your information to login",
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.normal),
                      textAlign: TextAlign.center,
                    ),

                    // Email
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        cursorColor: Color(0xFF9a85a4),
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(color: Color(0xFF9a85a4)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                                color: Color(0xFF9a85a4).withOpacity(0.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                                color: Color(0xFF9a85a4).withOpacity(0.6)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          filled: true,
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Required email.';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Please enter a valid email address.';
                          }
                          return null;
                        },
                      ),
                    ),

                    // Password
                    /*
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        cursorColor: Color(0xFF9a85a4),
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(color: Color(0xFF9a85a4)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                                color: Color(0xFF9a85a4).withOpacity(0.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                                color: Color(0xFF9a85a4).withOpacity(0.6)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          filled: true,
                          prefixIcon: Icon(Icons.lock),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Required password.';
                          } // Check if the entered value is a valid email address

                          return null;
                        },
                      ),
                    ),
*/
// Password
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextFormField(
                        cursorColor: Color(0xFF9a85a4),
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(color: Color(0xFF9a85a4)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                                color: Color(0xFF9a85a4).withOpacity(0.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                                color: Color(0xFF9a85a4).withOpacity(0.6)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          filled: true,
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
  onPressed: () {
    setState(() {
      _obscureText = !_obscureText; // Toggle the visibility of the password
    });
  },
  icon: Icon(
    _obscureText ? Icons.visibility_off : Icons.visibility,
    // Use Icons.visibility when password is obscured (_obscureText is true)
    // Use Icons.visibility_off when password is visible (_obscureText is false)
    color: Colors.grey, // Adjust the color of the icon if needed
  ),
),

                        ),
                        obscureText:
                            _obscureText, // Use the _obscureText variable to determine whether to obscure the text
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Required password.';
                          } // Check if the entered value is a valid email address

                          return null;
                        },
                      ),
                    ),

                    // Error Message
                    if (_errorMessage != null) ...[
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                              color: Color(0xFFAD331E),
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],

                    // Login Button
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        onPressed: () => _login(context),
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Color(0xFF9a85a4).withOpacity(0.9),
                        ),
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Forgot password
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ForgotPasswordPage()),
                        );
                      },
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(
                          color: Color(0xFF9a85a4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Sign up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("New to Maazim? "),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUp()),
                            );
                          },
                          child: const Text(
                            "Sign up",
                            style: TextStyle(
                              color: Color(0xFF9a85a4),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Back Button
          Positioned(
            bottom: 25.0,
            left: 15,
            child: ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) =>
                      WelcomePage(), // Ensure WelcomePage is defined
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 154, 133, 164),
                shape: const CircleBorder(),
                elevation: 0,
                minimumSize: const Size(50, 50),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color.fromARGB(255, 255, 255, 255),
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
