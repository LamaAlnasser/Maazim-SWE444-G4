import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:maazim/layout.dart';
import 'package:pin_code_fields/pin_code_fields.dart';


void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure the Flutter binding is initialized
  await Firebase.initializeApp(); // Initialize Firebase
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

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword(String email) async {
  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Password reset link has been sent to your email.'),
      ),
    );
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      setState(() {
        _userNotFound = true; // Flag to trigger the UI error message
      });
    } else {
         setState(() {
      _userNotFound = false; });// Resets the error state when any other error occurs.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: ${e.message}'),
        ),
      );
    }
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       body: Stack(
        children: [
    CustomPage(
      pageTitle: '',
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 80),
            const SizedBox(height: 60,
            child: Text('Forget Passwort',
              textAlign: TextAlign.center,
              style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
            ),
            ),
              const SizedBox(height: 40,
                child: Text(
                'Please enter your email address',
              textAlign: TextAlign.center,
              style: TextStyle(
              color: Colors.black54,
              ),
               ),),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: TextFormField(
                cursorColor: const Color(0xFF9a85a4),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
  if (_userNotFound) {
    setState(() {
      _userNotFound = false;
    });
  }
},

                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                   filled: true, // Needed for fillColor to take effect
                   fillColor: Color(0xFF9a85a4).withOpacity(0.1), // Background color of the field
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: const Color(0xFF9a85a4).withOpacity(0.0))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide:  BorderSide(color: const Color(0xFF9a85a4).withOpacity(0.6))),
                    errorBorder: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(18),
                         borderSide: const BorderSide(color: Colors.red),),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Colors.red),),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                   prefixIcon: const Icon(Icons.email),
                ),
                validator: (value) {
  if (_userNotFound) {
    return 'No user found for this email address';
  }
  if (value == null || value.isEmpty || !value.contains('@')) {
    return 'Please enter a valid email';
  }
  return null;
},

              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _resetPassword(_emailController.text);
                }
              },
               style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 100),
                      backgroundColor: const Color(0xFF9a85a4), // Button background color
                    elevation: 1, // Removes shadow
                    ),
                    child: const Text('Reset Password',
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255))
                    ),
                  ),
          ],
        ),
      ),
    ),
      Positioned(
          bottom: 25.0,
          left: 15, // Distance from the bottom
          child: ElevatedButton(
            onPressed: () {
              // The action you want to perform when the button is pressed
              // For example, navigate to the welcome screen:
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 154, 133, 164), // Background color
              shape: const CircleBorder(), // Circular shape
              elevation: 0,
              minimumSize:const Size(50, 50),
            ),
            child: const Icon(
              Icons.arrow_back, // The icon for the button
              color: Color.fromARGB(255, 255, 255, 255),
              size: 30, // Icon color
                 ),
          ),
        ),
        ],
    ),
    );
  }
}
