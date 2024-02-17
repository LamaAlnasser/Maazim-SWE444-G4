//import 'package:maazim/home.dart';
//import 'package:maazim/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:flutter/material.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return await auth.currentUser;
  }
}
