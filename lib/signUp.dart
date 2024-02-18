import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maazim/logIn.dart';
import 'layout.dart';
import 'package:maazim/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maazim/Home_Host.dart';
import 'package:country_picker/country_picker.dart';

class SignUp extends StatelessWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPage(
            pageTitle: '',
            content: SignUpContent(),
          ),

          // Centered Heading
          Positioned(
            top: 220.0, // Adjust this value to position vertically
            left: MediaQuery.of(context).size.width / 2 -
                100.0, // Adjust this value to center horizontally
            child: Text(
              "Join Maazim!",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),

          Positioned(
            top: 60.0,
            left: 30.0,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: Color(0xFF9a85a4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SignUpContent extends StatefulWidget {
  const SignUpContent({Key? key}) : super(key: key);

  @override
  State<SignUpContent> createState() => _SignUpContentState();
}

class _SignUpContentState extends State<SignUpContent> {
  String email = "";
  String password = "";
  String firstName = "";
  String lastName = "";
  String phoneNumber = "";
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
  TextEditingController passwordController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool showError = false; // Add a boolean to track error visibility

  void registration() async {
    if (password.isNotEmpty &&
        firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        mailController.text.isNotEmpty &&
        phoneNumber.isNotEmpty) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Storing additional user information in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'firstName': firstName,
          'lastName': lastName,
          'phoneNumber': phoneNumber,
          'email': email,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Registered Successfully!",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        );
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => homePage()));
      } on FirebaseAuthException catch (e) {
        if (e.code == "email-already-in-use") {
          setState(() {
            showError =
                true; // Set showError to true to display the error message
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            //First
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name.';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: "First Name",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide:
                      BorderSide(color: Color(0xFF9a85a4).withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide:
                      BorderSide(color: Color(0xFF9a85a4).withOpacity(0.6)),
                ),
                fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                filled: true,
              ),
              onChanged: (value) => setState(() => firstName = value),
            ),
            SizedBox(height: 10.0),

            //Last Name
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name.';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: "Last Name",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide:
                      BorderSide(color: Color(0xFF9a85a4).withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide:
                      BorderSide(color: Color(0xFF9a85a4).withOpacity(0.6)),
                ),
                fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                filled: true,
              ),
              onChanged: (value) => setState(() => lastName = value),
            ),
            SizedBox(height: 2.0),

            // Phone number
            Container(
              height: 65,
              padding: EdgeInsets.symmetric(horizontal: 20), // Adjust padding
              margin:
                  EdgeInsets.symmetric(vertical: 10), // Add margin for spacing
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  // Add Border.all to set border color
                  color: Color(0xFF9a85a4)
                      .withOpacity(0.1), // Set the border color
                ),
                color: Color(0xFF9a85a4).withOpacity(0.1),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        countryListTheme: const CountryListThemeData(
                          bottomSheetHeight: 500,
                        ),
                        onSelect: (value) {
                          setState(() {
                            selectedCountry = value;
                          });
                        },
                      );
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
                          '+${selectedCountry.phoneCode} |',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: // Phone number
                        TextFormField(
                      keyboardType: TextInputType.phone,
                      maxLength: 9, // Set maximum length to 9
                      decoration: InputDecoration(
                        hintText: 'Phone number',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none, // Remove the underline
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number.';
                        }
                        if (value.length < 9) {
                          return 'Please enter a valid phone number.';
                        }
                        // Check if country is United Arab Emirates and phone number starts with '5'
                        if (selectedCountry.countryCode == 'AE' &&
                            !value.startsWith('5')) {
                          return "Please enter a valid phone number.";
                        }
                        // Check if country is Saudi Arabia and phone number starts with '5'
                        if (selectedCountry.countryCode == 'SA' &&
                            !value.startsWith('5')) {
                          return "Please enter a valid phone number.";
                        }

                        return null;
                      },
                      onChanged: (value) {
                        // Handle phone number input
                        phoneNumber = value;
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 2.0),

            //Email
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email.';
                }
                // Check if the entered value is a valid email address
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'Please enter a valid email address.';
                }
                return null;
              },
              controller: mailController,
              decoration: InputDecoration(
                hintText: "Email",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide:
                      BorderSide(color: Color(0xFF9a85a4).withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide:
                      BorderSide(color: Color(0xFF9a85a4).withOpacity(0.6)),
                ),
                fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                filled: true,
              ),
              onChanged: (value) => setState(() => email = value),
            ),
            SizedBox(height: 10.0),

            // Password
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password.';
                }
                // Custom password strength check
                if (value.length < 8) {
                  return 'Password must be at least 8 characters long.';
                }
                if (!value.contains(RegExp(r'[A-Z]'))) {
                  return 'Password must contain at least one uppercase letter.';
                }
                if (!value.contains(RegExp(r'[a-z]'))) {
                  return 'Password must contain at least one lowercase letter.';
                }
                if (!value.contains(RegExp(r'[0-9]'))) {
                  return 'Password must contain at least one digit.';
                }
                // Add more checks as needed, such as special characters

                return null;
              },
              controller: passwordController,
              decoration: InputDecoration(
                hintText: "Password",
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide:
                      BorderSide(color: Color(0xFF9a85a4).withOpacity(0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide:
                      BorderSide(color: Color(0xFF9a85a4).withOpacity(0.6)),
                ),
                fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                filled: true,
              ),
              obscureText: true,
              onChanged: (value) => setState(() => password = value),
            ),

            SizedBox(height: 10.0),

            // Show error message if account already exists
            Visibility(
              visible: showError, // Show only if showError is true
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9.0),
                child: Text(
                  "Account Already exists.",
                  style: TextStyle(
                    fontSize: 17.0,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  registration();
                }
              },
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                padding: EdgeInsets.symmetric(vertical: 16),
                primary: Color(0xFF9a85a4).withOpacity(0.9),
              ),
              child: Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Already have an account? ",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LogIn()),
                    );
                  },
                  child: Text(
                    "Log In",
                    style: TextStyle(
                      color: Color(0xFF9a85a4),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
