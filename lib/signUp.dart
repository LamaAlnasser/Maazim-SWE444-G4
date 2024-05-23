import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:maazim/logIn.dart';
import 'layout.dart';
import 'package:maazim/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maazim/Home_Host.dart';
import 'package:maazim/OTP_afterSignUp.dart';

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
                  builder: (context) => WelcomePage(),
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
  TextEditingController passwordController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool showError = false; // Add a boolean to track error visibility
  String errorMessage = ''; // Add a string to store the error message

  bool _obscureText =
      true; // Define the _obscureText variable and initialize it to true

  // Getter method for _obscureText
  bool get obscureText => _obscureText;

  // Setter method for _obscureText
  set obscureText(bool value) {
    setState(() {
      _obscureText = value;
    });
  }

  void registration() async {
    if (_formKey.currentState!.validate()) {
      // Show a loading indicator or disable the button to prevent multiple submissions
      // For example:
      // setState(() => _isLoading = true);

      final email = mailController.text;
      if (password.isNotEmpty &&
          firstName.isNotEmpty &&
          lastName.isNotEmpty &&
          email.isNotEmpty) {
        try {
          // Check if the email is already in the users collection
          final querySnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

          // If the query returns any documents, the email is already in use
          if (querySnapshot.docs.isNotEmpty) {
            setState(() {
              showError = true;
              errorMessage =
                  'The email is already in use.\nPlease try another one.';
              // _isLoading = false; // Re-enable the button or hide loading indicator
            });
            return; // Stop further execution
          }

          // If email is not in use, proceed to navigate to OTP_afterSignUp
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => OTP_afterSignUp(
              email: email,
              password: password,
              firstName: firstName,
              lastName: lastName,
            ),
          ));
        } on FirebaseAuthException catch (e) {
          if (e.code == "email-already-in-use") {
            setState(() {
              showError = true;
              errorMessage =
                  'The email already in use.\nPlease try another one.';
              // _isLoading = false; // Re-enable the button or hide loading indicator
            });
          }
        } catch (e) {
          // Handle any other errors that might occur
          setState(() {
            showError = true;
            errorMessage = 'An error occurred. Please try again later.';
            // _isLoading = false; // Re-enable the button or hide loading indicator
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
                        if (!RegExp(r'^[a-zA-Z\u0621-\u064A]+$')
                            .hasMatch(value)) {
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
                        if (!RegExp(r'^[a-zA-Z\u0621-\u064A]+$')
                            .hasMatch(value)) {
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

           // SizedBox(height: 10),

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
                    return 'Password requires an uppercase letter.';
                  }
                  if (!value.contains(RegExp(r'[a-z]'))) {
                    return 'Password requires a lowercase letter.';
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
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
  onPressed: () {
    setState(() {
      _obscureText = !_obscureText; // Toggle the visibility of the password
    });
  },
  icon: Icon(
    _obscureText ? Icons.visibility_off : Icons.visibility,
    // Use Icons.visibility when password is obscured (_obscureText is true)
    // Use Icons.visibility_off when password is visible (_obscureText is false)
    color: Colors.grey, // Adjust the color of the icon if needed
  ),
),

                        ),
                        obscureText:
                            _obscureText, // Use the _obscureText variable to determine whether to obscure the text

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
                  shape: StadiumBorder(), backgroundColor: Color(0xFF9a85a4).withOpacity(0.9),
                  padding: EdgeInsets.symmetric(vertical: 16),
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
