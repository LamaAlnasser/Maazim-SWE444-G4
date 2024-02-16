import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:maazim/logIn.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

}

class homePage extends StatelessWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const LogIn(),
              ));
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome !',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}