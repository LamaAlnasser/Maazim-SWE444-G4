import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maazim/limited_functionality_page.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:maazim/layout.dart';
import 'package:maazim/main.dart'; //use it to go back
import 'package:maazim/limited_functionality_page.dart'; // Create this file for limited functionality

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
   bool _isOtpInvalid = false;


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
   if (_verificationId != null && _otpController.text.length == 6) {
    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: _otpController.text,
    );
    try {
       _signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      // Check for specific error codes here if needed e.g. e.code == 'invalid-verification-code'
      setState(() {
        _isOtpInvalid = true; // Set this to true if the OTP is wrong
      });
    }
  } else {
    setState(() {
      _isOtpInvalid = true; // This will show the error if the verification ID is null or OTP length is not 6
    });
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
    return Scaffold(
      body: Stack(
        children: [
    CustomPage(
      pageTitle: '', // Set the page title
      content: 
      Padding(
        padding: const EdgeInsets.all(24.0),
      child: Form( // Wrap content with a Form widget
        key: _formKey, // Associate the key with the form
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             const SizedBox(height: 80),
            if (_verificationId == null) ...[
              const SizedBox(height: 60,
              child: Text('Verification',
               textAlign: TextAlign.center,
              style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),),
              SizedBox(height: 40,
                child: Text(
                'Please enter a 9 digit phone number',
              textAlign: TextAlign.center,
               style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
               ),),

              Padding(padding: const EdgeInsets.symmetric(horizontal: 16,),
             child: TextFormField(
                cursorColor: const Color(0xFF9a85a4),
                controller: _phoneNumberController,
                keyboardType: TextInputType.number, // Set keyboard type to number
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
               ],
                decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(color:Color(0xFF9a85a4)),
                    filled: true, // Needed for fillColor to take effect
              fillColor: const Color(0xFF9a85a4).withOpacity(0.1),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: Color(0xFF9a85a4).withOpacity(0.0))),
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
                        color: Color.fromARGB(255, 113, 113, 113),
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
              const SizedBox(height: 30),
               Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton(
                 onPressed: _attemptPhoneNumberVerification,
                 style: ElevatedButton.styleFrom(
                 shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 16),
    backgroundColor: const Color(0xFF9a85a4), // Button background color
  ),
  child: const Text(
    'Send OTP',
    style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
  ),
              ),),
            ] else ...[
               Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  
                  const Text(
               'Verification',
               textAlign: TextAlign.center,
              style: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    ),
    const SizedBox(height: 8,width: 8),
    const Padding(padding: EdgeInsets.symmetric(horizontal: 6),
    child: Text(
      'Please enter the 6-digit OTP code sent by SMS to your phone number',
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
    ),),

                  const SizedBox(height: 30),
                     Padding(padding: EdgeInsets.symmetric(horizontal: 16),
                   child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    onChanged: (String value) {
                            // Reset the error state when user starts typing again
                    if (_isOtpInvalid) {
                     setState(() {
                    _isOtpInvalid = false;
                    });
                    }
                    },
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                     borderRadius: BorderRadius.circular(5),
                     fieldHeight: 40,
                     fieldWidth: 30,
                     inactiveFillColor: _isOtpInvalid ? Colors.red.shade50 : Color.fromARGB(255, 76, 0, 111).withOpacity(0.1),
                     activeFillColor: _isOtpInvalid ? Colors.red.shade50 : Color.fromARGB(255, 103, 15, 144).withOpacity(0.1),
                     selectedFillColor: _isOtpInvalid ? Colors.red.shade50 : const Color(0xFF9a85a4).withOpacity(0.1),
                     inactiveColor: _isOtpInvalid ? Colors.red : Colors.grey.withOpacity(0.1),
                     activeColor: _isOtpInvalid ? Colors.red : const Color(0xFF9a85a4),
                     selectedColor: _isOtpInvalid ? Colors.red : const Color(0xFF9a85a4),
                        fieldOuterPadding: const EdgeInsets.symmetric(horizontal: 8), // Adjust the space between fields
                    ),
                    keyboardType: TextInputType.number,
                    onCompleted: (value) async {
                     final credential = PhoneAuthProvider.credential(
                      verificationId: _verificationId!,
                       smsCode: value,
                        );
                        try {
                       _signInWithCredential(credential);
                       } catch (e) {
                       setState(() {
                      _isOtpInvalid = true;
                      });
                      }
                      },
                     ),  
                  ), 
                   if (_isOtpInvalid) ...[
                  const Padding(
                  padding: EdgeInsets.only(top: 10,left: 18),
                  
                  child: Text(
                 'Invalid OTP entered, please try again.',
                  style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                   ),
                   ],
              

                  const SizedBox(height: 30), 
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                    onPressed: _signInWithPhoneNumber,
                      style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: const Color(0xFF9a85a4).withOpacity(0.9),// Rounded corners
                    ),
                    child: const Text('Confirm',
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255))
                    ),
                  ),
                  ),
                ],
               ),
            ],
          ],
        ),
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
              backgroundColor: Color.fromARGB(255, 154, 133, 164), // Background color
              shape: CircleBorder(), // Circular shape
              elevation: 0,
              minimumSize:Size(50, 50),
            ),
            child: Icon(
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
