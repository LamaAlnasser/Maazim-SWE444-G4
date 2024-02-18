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

  void showCustomCountryPicker(BuildContext context) {
   showCountryPicker(
    context: context,
    countryFilter: <String>['SA', 'US', 'AE'],
    onSelect: (Country country) {
      setState(() {
        selectedCountry = country;
      });
    },
    countryListTheme: CountryListThemeData(
      bottomSheetHeight: 500
    ),
  );
}

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
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
              const SizedBox(height: 60,
              child: Text('Join Maazim',
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
               ),),
              const SizedBox(height: 25,
                child: Text(
                'Please enter your info',
              textAlign: TextAlign.center,
               style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
               ),),


              Padding(padding: const EdgeInsets.symmetric(horizontal: 16,),
            //First
            child: TextFormField(
            cursorColor:Color(0xFF9a85a4) ,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your first name.';
                }
                return null;
              },
              decoration: InputDecoration(
                          labelText: "First Name",
                          labelStyle: TextStyle(color: Color(0xFF9a85a4)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Color(0xFF9a85a4).withOpacity(0.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Color(0xFF9a85a4).withOpacity(0.6)),
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
            ),),
            SizedBox(height: 10.0),

              Padding(padding: const EdgeInsets.symmetric(horizontal: 16,),

            //Last Name
            child: TextFormField(
             cursorColor:Color(0xFF9a85a4) ,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your last name.';
                }
                return null;
              },
              decoration: InputDecoration(
                          labelText: "Last Name",
                          labelStyle: TextStyle(color: Color(0xFF9a85a4)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Color(0xFF9a85a4).withOpacity(0.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Color(0xFF9a85a4).withOpacity(0.6)),
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
            ),),
            SizedBox(height: 10),

           
                 
                  const SizedBox(width: 8),

                     Padding(padding: const EdgeInsets.symmetric(horizontal: 16,),

                    child: TextFormField(
                      cursorColor:Color(0xFF9a85a4) ,
                      keyboardType: TextInputType.phone,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
               ],
                     decoration: InputDecoration(
                          labelText: "Phone Number",
                          labelStyle: TextStyle(color: Color(0xFF9a85a4)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Color(0xFF9a85a4).withOpacity(0.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Color(0xFF9a85a4).withOpacity(0.6)),
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
               )
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
                        if (selectedCountry.countryCode == 'U' &&
                            !value.startsWith('5')) {
                          return "Please enter a valid phone number.";
                        }

                        return null;
                      },
                      onChanged: (value) {
                        // Handle phone number input
                        phoneNumber = value;
                      },
                    ),),
        
            SizedBox(height: 10.0),

              Padding(padding: const EdgeInsets.symmetric(horizontal: 16,),

            //Email
            child: TextFormField(
         cursorColor:Color(0xFF9a85a4) ,
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
                          labelText: "Email",
                          labelStyle: TextStyle(color: Color(0xFF9a85a4)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Color(0xFF9a85a4).withOpacity(0.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Color(0xFF9a85a4).withOpacity(0.6)),
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
            ),),
            SizedBox(height: 10.0),

              Padding(padding: const EdgeInsets.symmetric(horizontal: 16,),
            // Password
            child: TextFormField(
                   cursorColor:Color(0xFF9a85a4) ,
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
                          labelText: "Password",
                          labelStyle: TextStyle(color: Color(0xFF9a85a4)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Color(0xFF9a85a4).withOpacity(0.0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Color(0xFF9a85a4).withOpacity(0.6)),
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
            ),),

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

            SizedBox(height: 10.0),
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16,),

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
                'Sign Up',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),),

            SizedBox(height: 15.0),
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
