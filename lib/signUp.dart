import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const SignUp());
}

class SignUp extends StatelessWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPage(
      pageTitle: 'Sign Up',
      content: SignUpContent(),
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
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'phoneNumber': _phoneNumberController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User registered successfully')));
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to register user: ${e.message}')));
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              width:10,
        
            child: TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
    labelText: 'First Name',
    
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0), // Adjust the border radius
    ),
    filled: true,
    fillColor: Colors.grey[200], // Adjust the background color
    contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Adjust the content padding
  ),
              validator: (value) => _validateName(value, 'first name'),
            ),
            ),
                    
                    SizedBox(height: 20.0), // to add a space between text fields
              Container (

            child :TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Last Name',
               border: OutlineInputBorder(
          
                    borderRadius: BorderRadius.circular(10.0), // Adjust the border radius
                  ),
                    filled: true,
                    fillColor: Colors.grey[200], // Adjust the background color
                    contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0), // Adjust the content padding
                   ),
             
              validator: (value) => _validateName(value, 'last name'),
            ),
              ),
           
           
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: _validateEmail,
            ),
            TextFormField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
              validator: _validatePhoneNumber,
            ),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) =>
                  value != null && value.length < 6 ? 'Password must be at least 6 characters long' : null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
