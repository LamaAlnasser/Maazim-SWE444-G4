import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:maazim/main.dart'; 
import 'package:maazim/limited_functionality_page.dart'; // Create this file for limited functionality

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure the Flutter binding is initialized
  Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maazim Welcome Page',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      debugShowCheckedModeBanner: false,
      home: const GuestLogIn(),
    );
  }
}

class GuestLogIn extends StatefulWidget {
  const GuestLogIn({Key? key}) : super(key: key);

  @override
  State<GuestLogIn> createState() => _GuestSignInPageState();
}

class _GuestSignInPageState extends State<GuestLogIn> {
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _verifyPhoneNumber() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: _phoneNumberController.text,
      verificationCompleted: (PhoneAuthCredential credential) async {
        _signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        _showSnackbar('Failed to Verify Phone Number: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        _showSnackbar('Please check your phone for the verification code.');
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  void _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      if (userCredential.user != null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const LimitedFunctionalityPage(),
        ));
      }
    } on FirebaseAuthException catch (e) {
      _showSnackbar('Failed to sign in: ${e.message}');
    }
  }

  void _signInWithPhoneNumber() async {
    if (_verificationId != null) {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text,
      );
      _signInWithCredential(credential);
    } else {
      _showSnackbar('Verification ID not found');
    }
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Guest OTP Verification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_verificationId == null) ...[
              TextField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefix: Text('+'),
                ),
                keyboardType: TextInputType.phone,
              ),
              ElevatedButton(
                onPressed: _verifyPhoneNumber,
                child: const Text('Send OTP'),
              ),
            ] else ...[
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: 'OTP',
                ),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: _signInWithPhoneNumber,
                child: const Text('Verify OTP'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LimitedFunctionalityPage extends StatelessWidget {
  const LimitedFunctionalityPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Limited Functionality'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const GuestLogIn(),
              ));
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome, Guest!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
