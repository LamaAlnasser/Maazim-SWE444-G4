import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:maazim/limited_functionality_page.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:maazim/layoutpage.dart';
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
      title: 'Maazim Guest',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
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
     String completePhoneNumber = '+${selectedCountry.phoneCode} ${_phoneNumberController.text.trim()}';

  await FirebaseAuth.instance.verifyPhoneNumber(
    phoneNumber: completePhoneNumber, // Use the complete phone number here
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
    return CustomPage(
      pageTitle: 'Guest Login', // Set the page title
      content: Column(
          children: [
             const SizedBox(height: 50),
            if (_verificationId == null) ...[
              Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
             child: TextFormField(
                cursorColor: const Color(0xFF9a85a4),
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                    hintText: 'Enter Phone Number',
                    hintStyle: const TextStyle(color: Colors.grey), // Hint text style
                    filled: true, // Needed for fillColor to take effect
                   fillColor: const Color(0xFF9a85a4).withOpacity(0.1), // Background color of the field
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Colors.black12)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Colors.black12)),
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      
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

                        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedCountry.flagEmoji,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 8),
            Text(
              '+${selectedCountry.phoneCode}',
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 157, 157, 157),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
                      ),
                    )),
              ),),
              const SizedBox(height: 32),
                  SizedBox(
                    width: 180,
                      height: 40,
              child: ElevatedButton(
                onPressed: _verifyPhoneNumber,
                style: ElevatedButton.styleFrom(
                       foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF9a85a4),
                          shape: const StadiumBorder(),
                    ),
                child: const Text('Send OTP'),
              ),
              ),
            ] else ...[
               Column(
                children: [
                  const SizedBox(height: 35),
                  const Text(
                    'Enter 6 digits verification code sent to your number',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 25),
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 25), // Adjust the side padding as needed
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    onChanged: (String value) {},
                     mainAxisAlignment: MainAxisAlignment.spaceBetween, // Add this line
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 40,
                      fieldWidth: 30,
                      inactiveFillColor: const Color(0xFF9a85a4).withOpacity(0.1),
                      activeFillColor: const Color(0xFF9a85a4).withOpacity(0.1),
                      selectedFillColor: const Color(0xFF9a85a4).withOpacity(0.1),
                      inactiveColor: Colors.black,
                      activeColor: const Color(0xFF9a85a4),
                      selectedColor: const Color(0xFF9a85a4),
                        fieldOuterPadding: const EdgeInsets.symmetric(horizontal: 10), // Adjust the space between fields
                    ),
                    keyboardType: TextInputType.number,
                    onCompleted: (value) {
                      _otpController.text = value; // Assign the value to the OTP controller
                    },
                  ),),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 120,
                      height: 50,
                  child: ElevatedButton(
                    onPressed: _signInWithPhoneNumber,
                    style: ElevatedButton.styleFrom(
                       foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF9a85a4),
                          shape: const StadiumBorder(),
                    ),
                    child: const Text('Confirm'),
                  ),
                  ),
                ],
               ),
            ],
          ],
        ),
      );
  }
}
