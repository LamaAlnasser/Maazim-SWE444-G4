import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:maazim/guestLogIn.dart';
import 'package:maazim/layout.dart';
import 'package:maazim/signUp.dart';
import 'firebase_options.dart';
import 'package:maazim/main.dart'; //use it to go back
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
        runApp(LogIn());
}

class LogIn extends StatelessWidget {
  const LogIn({super.key});

  @override
  //> createState() => _HostLogInPageState();

  @override
  Widget build(BuildContext context) {
    // Using CustomPage to provide consistent layout for the login screen
    return CustomPage(
      pageTitle: '',
      content: _loginContent(context),
      //margin: const EdgeInsets.all(24),
    );
  }
}

Widget _loginContent(BuildContext context) {
  // This method creates the content for the login page
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      const SizedBox(height: 20), // Adjust the space as needed
      _header(context),
      _inputField(context),
      _forgotPassword(context),
      _signup(context),
    ],
  );
}

Widget _header(BuildContext context) {
  return Column(
    children: [
      Text(
        "Welcome Back",
        style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
      ),
      Text("Enter your information to login"),
    ],
  );
}


Widget _inputField(BuildContext context) {
  final _formKey = GlobalKey<FormState>();

  return Form(
    key: _formKey,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: "Email",
               labelStyle: TextStyle(color:Color(0xFF9a85a4)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              fillColor: const Color(0xFF9a85a4).withOpacity(0.1),
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
                          contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Adjust the content padding

              filled: true,
              prefixIcon: const Icon(Icons.email),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your email';
              } /*else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value!)) {
                return 'Please enter a valid email';
              }*/
              return null;
            },
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextFormField(
            decoration: InputDecoration(
              labelText: "Password",
               labelStyle: TextStyle(color:Color(0xFF9a85a4)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              fillColor: const Color(0xFF9a85a4).withOpacity(0.1),
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
                         contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Adjust the content padding

              filled: true,
              prefixIcon: const Icon(Icons.password),
            ),
            obscureText: true,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Please enter your password';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                // Form is valid, perform login action
              }
            },
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF9a85a4).withOpacity(0.9),
            ),
            child: const Text(
              "Login",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        )
      ],
    ),
  );
}

Widget _forgotPassword(BuildContext context) {
  return TextButton(
    onPressed: () => Navigator.push(
        context, MaterialPageRoute(builder: (context) => const GuestLogIn())),
    child: const Text(
      "Forgot password?",
      style: TextStyle(
          color: const Color(0xFF9a85a4), fontWeight: FontWeight.bold),
    ),
  );
}

Widget _signup(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Dont have an account? "),
      TextButton(
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (context) => const SignUp())),
          child: const Text(
            "Sign Up",
            style: TextStyle(
                color: const Color(0xFF9a85a4), fontWeight: FontWeight.bold),
          ))
    ],
  );
}