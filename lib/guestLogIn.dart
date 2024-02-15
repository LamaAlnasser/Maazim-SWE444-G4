import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

   final _formKey = GlobalKey<FormState>(); // Add a key for the form

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

  void _attemptPhoneNumberVerification() {
    if (_formKey.currentState!.validate()) {
      // If the form is valid, verify the phone number
      _verifyPhoneNumber();
    }
  }

      @override
  Widget build(BuildContext context) {
    return CustomPage(
      pageTitle: 'Guest Login', // Set the page title
      content: Form( // Wrap content with a Form widget
        key: _formKey, // Associate the key with the form
      child: Column(
          children: [
             const SizedBox(height: 50),
            if (_verificationId == null) ...[
              Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
             child: TextFormField(
                cursorColor: const Color(0xFF9a85a4),
                controller: _phoneNumberController,
                keyboardType: TextInputType.number, // Set keyboard type to number
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
               ],
                decoration: InputDecoration(
                    hintText: 'Enter Phone Number',
                    hintStyle: const TextStyle(color: Colors.grey), // Hint text style
                    filled: true, // Needed for fillColor to take effect
                   fillColor: const Color(0xFF9a85a4).withOpacity(0.1), // Background color of the field
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: Color(0xFF9a85a4).withOpacity(0.1))),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide:  BorderSide(color: Color(0xFF9a85a4).withOpacity(0.6))),
                    errorBorder: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(18),
                         borderSide: const BorderSide(color: Colors.red),),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(color: Colors.red),),
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
              validator: (value) {
                if (value == null || value.isEmpty || value.length != 9) {
                  return 'Please enter a 9-digit number'; // Error message
                }
                return null; // Return null to indicate the input is correct
              },
              ),),
              const SizedBox(height: 32),

                ElevatedButton(
                 onPressed: _attemptPhoneNumberVerification,
                 style: ElevatedButton.styleFrom(
                 padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 140),
                 shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30), // Rounded corners
    ),
    backgroundColor: const Color(0xFF9a85a4), // Button background color
    elevation: 0, // Removes shadow
  ),
  child: const Text(
    'Send OTP',
    style: TextStyle(
      fontSize: 16, // Font size
      fontWeight: FontWeight.bold,
      color: Colors.white, // Text color
    ),
  ),
              ),
            ] else ...[
               Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Enter 6 digits verification code sent to your number',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  const SizedBox(height: 32),
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
                      inactiveFillColor: Color.fromARGB(255, 76, 0, 111).withOpacity(0.1),
                      activeFillColor: Color.fromARGB(255, 103, 15, 144).withOpacity(0.1),
                      selectedFillColor: const Color(0xFF9a85a4).withOpacity(0.1),
                      inactiveColor: Colors.grey.withOpacity(0.1),
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
                    ElevatedButton(
                    onPressed: _signInWithPhoneNumber,
                      style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 140),
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Rounded corners
                      ),
                      backgroundColor: const Color(0xFF9a85a4), // Button background color
                    elevation: 0, // Removes shadow
                    ),
                    child: const Text('Confirm',
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255))
                    ),
                  ),
                ],
               ),
            ],
          ],
        ),
      ),
      );
  }
}
