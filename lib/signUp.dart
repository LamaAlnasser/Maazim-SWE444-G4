import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maazim/home.dart';
import 'package:maazim/logIn.dart';
import 'layout.dart';
import 'package:maazim/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp extends StatelessWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPage(
            pageTitle: 'Sign Up',
            content: SignUpContent(),
          ),
          Positioned(
            top: 45.0,
            left: 16.0,
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
  String email = "",
      password = "",
      firstName = "",
      lastName = "",
      phoneNumber = "";
  TextEditingController passwordController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
              "Registered Successfully",
              style: TextStyle(fontSize: 20.0),
            ),
          ),
        );
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Home()));
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Password Provided is too Weak",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
        } else if (e.code == "email-already-in-use") {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.orangeAccent,
              content: Text(
                "Account Already exists",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          );
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
            SizedBox(height: 10.0),

            //Phone
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number.';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: "Phone Number",
                prefixIcon: Icon(Icons.phone),
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
              onChanged: (value) => setState(() => phoneNumber = value),
            ),
            SizedBox(height: 10.0),

            //Email
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email.';
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

            //Password
            TextFormField(
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password.';
                }
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
            SizedBox(height: 20.0),
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
