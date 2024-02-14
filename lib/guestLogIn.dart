import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:maazim/limited_functionality_page.dart';
//import 'package:maazim/main.dart'; //use it to go back
//import 'package:maazim/limited_functionality_page.dart'; // Create this file for limited functionality

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

  Country selectedCountry = Country(
      phoneCode: "966",
      countryCode: "SA",
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: "SaudiArabia",
      example: "SaudiArabia",
      displayName: "SaudiArabia",
      displayNameNoCountryCode: "KSA",
      e164Key: "");

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
      
       backgroundColor:
          const Color(0xFF9a85a4), // Background color of the entire page
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
            if (_verificationId == null) ...[
              TextFormField(
                cursorColor: Colors.blue,
                controller: _phoneNumberController,
                decoration: InputDecoration(
                    hintText: 'Phone Number',
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black12)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.black12)),
                    prefixIcon: Container(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          showCountryPicker(
                              context: context,
                              countryListTheme: const CountryListThemeData(
                                bottomSheetHeight: 500
                              ),
                              onSelect: (value) {
                                setState(() {
                                  selectedCountry = value;
                                });
                              });
                        },
                        child: Text(
                          "${selectedCountry.flagEmoji} + ${selectedCountry.phoneCode}",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )),
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
      );
  }
}
