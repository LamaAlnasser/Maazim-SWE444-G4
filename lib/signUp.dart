import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'layout.dart';
import 'package:maazim/main.dart'; 
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SignUp());
}

class CustomPage extends StatelessWidget {
  final String pageTitle; // Change the type to String
  final Widget content;
  final double fontSize;

  const CustomPage({
    Key? key,
    required this.pageTitle,
    required this.content,
    required this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          pageTitle,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: content,
    );
  }
}

class SignUp extends StatelessWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      content: SignUpContent(),
      fontSize: 24,
      pageTitle: 'Sign up', 
    );
  }
}






class SignUpContent extends StatefulWidget {
  const SignUpContent({Key? key}) : super(key: key);

  @override
  State<SignUpContent> createState() => _SignUpContentState();
}

class _SignUpContentState extends State<SignUpContent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Your existing sign-up logic here
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to register user: ${e.message}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  hintText: 'Enter your first name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => _validateName(value, 'first name'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  hintText: 'Enter your last name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => _validateName(value, 'last name'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: _validateEmail,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  hintText: 'Enter your phone number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: _validatePhoneNumber,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) =>
                    value != null && value.length < 6 ? 'Password must be at least 6 characters long' : null,
              ),
            ),
            const SizedBox(height: 20),
            
  
       
Container(
  height: 50,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(10),
    color: const Color(0xFF9a85a4).withOpacity(0.9),
  ),
  child: ElevatedButton(
    onPressed: _signUp,
    style: ElevatedButton.styleFrom(
      primary: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
    child: const Text('Sign Up', style: TextStyle(fontSize: 18, color: Colors.white)),
  ),
),


 

          ],
        ),
      ),
    );
  }

  String? _validateName(String? value, String fieldName) {
    if (value != null && value.isEmpty) {
      return 'Enter your $fieldName';
    } else if (value != null && !RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return 'Enter a valid $fieldName (only characters)';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value != null && value.isEmpty) {
      return 'Enter a valid email';
    } else if (value != null && !RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(value)) {
      return 'Enter a valid email format';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value != null && value.isEmpty) {
      return 'Enter your phone number';
    } else if (value != null &&
        (!((value.startsWith('05') && value.length == 10) || (value.startsWith('966') && value.length == 12)))) {
      return 'Enter a valid phone number';
    }
    return null;
  }
}
