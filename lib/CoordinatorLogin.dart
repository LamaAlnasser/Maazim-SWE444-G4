import 'package:flutter/material.dart';
import 'package:maazim/entryCoordinatorPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class CoordinatorLoginPage extends StatefulWidget {
  @override
  _CoordinatorLoginPageState createState() => _CoordinatorLoginPageState();
}

class _CoordinatorLoginPageState extends State<CoordinatorLoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  void _login() async {
    if (_formKey.currentState!.validate()) {
      // Here you retrieve the credentials from Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('coordinators')
          .where('username', isEqualTo: _usernameController.text)
          .get();

      if (snapshot.docs.isEmpty) {
        // Username not found in database
        _showLoginFailed();
        return;
      }

      // Assuming you only have one entry per username
      final userDoc = snapshot.docs.first;
      final storedHashedPassword = userDoc['password'];
      final inputPassword = _passwordController.text;
      final usernamee = _usernameController.text;

      // Hash the input password to compare with stored hashed password
      final inputHashedPassword =
          sha256.convert(utf8.encode(inputPassword)).toString();
      if (storedHashedPassword == inputHashedPassword) {
        // Passwords match, navigate to EntityCoordinatorPage with the username
        // Debug log
        print('HEEREE: $usernamee');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => EntityCoordinatorPage(
                coordinatorUsername: _usernameController.text),
          ),
        );
      } else {
        // Passwords do not match
        _showLoginFailed();
      }
    }
  }

  void _showLoginFailed() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Login failed, please try again")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coordinator Login'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
