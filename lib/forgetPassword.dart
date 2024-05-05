import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:maazim/layout.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maazim Guest',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      debugShowCheckedModeBanner: false,
      home: const ForgotPasswordPage(),
    );
  }
}

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _userNotFound = false;
  String _errorMessage = '';
  bool _isButtonEnabled = true;
  int _timerSeconds = 30;
  bool _isMaazimTeamEmail = false;

  void _startTimer() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timerSeconds == 0) {
        setState(() {
          _isButtonEnabled = true;
          _errorMessage = ''; // Reset the error message
          timer.cancel();
        });
      } else {
        setState(() {
          _timerSeconds--;
        });
      }
    });
  }

  Future<void> _resetPassword(String email) async {
    // Check if email exists in Firestore
  final usersCollection = FirebaseFirestore.instance.collection('users');
  final querySnapshot = await usersCollection.where('email', isEqualTo: email).get();

  if (querySnapshot.docs.isEmpty) {
    // Email not found in Firestore, showing error message
    setState(() {
      _errorMessage = 'Email not found. Please sign up first.';
    });
    return; // Stop execution if email not found
  }

  // If email exists in Firestore, proceed to send password reset email
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    // Show the success message
    setState(() {
      _errorMessage = 'A reset password link has been sent to your email address. Please check your inbox.';
    });
  } on FirebaseAuthException catch (e) {
    // Handle other FirebaseAuth errors if necessary
    setState(() {
      _errorMessage = 'An error occurred: ${e.message}';
    });
  }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle errorMessageStyle =
        TextStyle(color:  Color(0xFFAD331E),); // Style for error messages
    TextStyle successMessageStyle =
        TextStyle(color: Colors.green); // Style for success messages

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
                  children: <Widget>[
                    const SizedBox(height: 80),
                    const SizedBox(
                      height: 60,
                      child: Text(
                        'Forget Password',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(
                      height: 40,
                      child: Text(
                        'Please enter your email address',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextFormField(
                        cursorColor: const Color(0xFF9a85a4),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
  // Convert the email to lowercase before checking
  if (value.toLowerCase().contains('@maazim.com')) {
    setState(() {
      _isMaazimTeamEmail = true;
      _errorMessage = "It looks like you're an entry coordinator! This feature isn’t available for your account. Please get in touch with our support team";
    });
  } else {
    setState(() {
      _isMaazimTeamEmail = false;
      _errorMessage = '';
    });
  }
},
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Color(0xFF9a85a4)),
                          filled: true,
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
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: const Icon(Icons.email),
                        ),
                        validator: (value) {
                          if (_userNotFound) {
                            return 'No user found for this email address';
                          }
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
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ElevatedButton(
                        onPressed: _isButtonEnabled
                            ? () {
                                if (_formKey.currentState!.validate()) {
                                  _resetPassword(_emailController.text);
                                  setState(() {
                                    _isButtonEnabled = false;
                                    _timerSeconds = 30;
                                  });
                                  _startTimer();
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor:
                              const Color(0xFF9a85a4).withOpacity(0.9),
                        ),
                        child: Text(
                          _isButtonEnabled
                              ? 'Reset Password'
                              : 'Resend in $_timerSeconds seconds',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      ),
                    ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: SizedBox(
                          child: Text(
                            _errorMessage,
                            style: _errorMessage.contains('reset password link')
                                ? successMessageStyle
                                : errorMessageStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 25.0,
            left: 15,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
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
