import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
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
         Positioned(
            bottom: 25.0,
            left: 15,
            child: ElevatedButton(
               onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => WelcomePage(), // Ensure WelcomePage is defined
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
  String errorMessage = ''; // Add a string to store the error message

  void showCustomCountryPicker(BuildContext context) {
    showCountryPicker(
      context: context,
      countryFilter: <String>['SA', 'US', 'AE'],
      onSelect: (Country country) {
        setState(() {
          selectedCountry = country;
        });
      },
      countryListTheme: CountryListThemeData(bottomSheetHeight: 500),
    );
  }

  void registration() async {
    if (password.isNotEmpty &&
        firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        mailController.text.isNotEmpty &&
        phoneNumber.isNotEmpty) {
      try {
        // Check if the phone number already exists in Firestore
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('phoneNumber', isEqualTo: phoneNumber)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // Phone number already exists, set error message
          setState(() {
            showError = true;
            errorMessage =
                'The phone number already in use.\nPlease try another one.';
          });
        } else {
          showError = false;
          errorMessage = '';
          // Phone number doesn't exist, proceed with registration
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
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == "email-already-in-use") {
          // Email already exists, set error message
          setState(() {
            showError = true;
            errorMessage = 'The email already in use.\nPlease try another one.';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(
              height: 60,
              child: Text(
                'Join Maazim!',
                style: TextStyle(fontSize: 45, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 30,
              child: Text(
                'Create your account',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
              ),
            ),
            SizedBox(height: 10),

            Row(
              children: [
                Flexible(
                  flex: 3, // Adjust the flex value to control the width
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        16, 0, 5, 0), // 16 pixels left padding
                    //First
                    child: TextFormField(
                      cursorColor: Color(0xFF9a85a4),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required First Name.';
                        }
                        if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                          return 'Note: only letters.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "First Name",
                        labelStyle:
                            TextStyle(color: Color(0xFF9a85a4), fontSize: 14),
                        errorStyle: TextStyle(fontSize: 10),
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
                        prefixIcon: Icon(Icons.person),
                      ),
                      onChanged: (value) => setState(() => firstName = value),
                    ),
                  ),
                ),

                //Last Name
                SizedBox(width: 1), // Reduced space between the fields
                Flexible(
                  flex: 3, // Adjust the flex value to control the width
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 0, 16, 0),
                    child: TextFormField(
                      cursorColor: Color(0xFF9a85a4),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required Last Name.';
                        }
                        if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                          return 'Note: only letters.';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: "Last Name",
                        labelStyle:
                            TextStyle(color: Color(0xFF9a85a4), fontSize: 14),
                        errorStyle: TextStyle(fontSize: 10),
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
                        prefixIcon: Icon(Icons.person),
                      ),
                      onChanged: (value) => setState(() => lastName = value),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            //Phone number

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: TextFormField(
                cursorColor: Color(0xFF9a85a4),
                keyboardType: TextInputType.phone,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                    labelText: " Phone Number",
                    labelStyle: TextStyle(color: Color(0xFF9a85a4)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide:
                          BorderSide(color: Color(0xFF9a85a4).withOpacity(0.0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide:
                          BorderSide(color: Color(0xFF9a85a4).withOpacity(0.6)),
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
                    prefixIcon: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: InkWell(
                        onTap: () {
                          showCustomCountryPicker(context);
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
                  // Check if the value is empty
                  if (value == null || value.isEmpty) {
                    return 'Required phone number.';
                  }

                  // Specific checks for the UAE
                  if (selectedCountry.countryCode == 'AE' &&
                      !(value.startsWith('5') && value.length == 9)) {
                    return 'Please enter 9-digit number e.g. 5XXXXXXXX.';
                  }
                  // Specific checks for Saudi Arabia
                  if (selectedCountry.countryCode == 'SA' &&
                      !(value.startsWith('5') && value.length == 9)) {
                    return 'Please enter 9-digit number e.g. 5XXXXXXXX.';
                  }
                  // Specific checks for the USA
                  if (selectedCountry.countryCode == 'US' &&
                      value.length != 10) {
                    return 'Please enter 10-digit number.';
                  }
                  return null;
                },
                onChanged: (value) {
                  // Handle phone number input
                  phoneNumber = value;
                },
              ),
            ),

            SizedBox(height: 10.0),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              //Email
              child: TextFormField(
                cursorColor: Color(0xFF9a85a4),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required email.';
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
                  labelText: "Email",
                  labelStyle: TextStyle(color: Color(0xFF9a85a4)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide:
                        BorderSide(color: Color(0xFF9a85a4).withOpacity(0.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide:
                        BorderSide(color: Color(0xFF9a85a4).withOpacity(0.6)),
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
                onChanged: (value) => setState(() => email = value),
              ),
            ),
            SizedBox(height: 10.0),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              // Password
              child: TextFormField(
                cursorColor: Color(0xFF9a85a4),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required password.';
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
                  labelText: "Password",
                  labelStyle: TextStyle(color: Color(0xFF9a85a4)),
                  // errorStyle: TextStyle(fontSize: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide:
                        BorderSide(color: Color(0xFF9a85a4).withOpacity(0.0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide:
                        BorderSide(color: Color(0xFF9a85a4).withOpacity(0.6)),
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
                onChanged: (value) => setState(() => password = value),
              ),
            ),

            SizedBox(height: 10.0),

            // Show error message if account already exists
            Visibility(
              visible: showError, // Show only if showError is true
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 9.0),
                child: Text(
                  errorMessage, // Display the error message
                  style: TextStyle(
                      fontSize: 15.0,
                      color: Color(0xFFAD331E),
                      fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: ElevatedButton(
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
                  'Sign up',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 10),
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
                    "Login",
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
