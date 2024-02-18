/*import 'package:firebase_core/firebase_core.dart';
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
}*/

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:maazim/logIn.dart';
import 'firebase_options.dart';
import 'package:maazim/layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maazim Guest',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      debugShowCheckedModeBanner: false,
      home: const homePage(),
    );
  }
}

class homePage extends StatelessWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomPage(
            pageTitle: '',
            content: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Welcome!",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Positioned(
        bottom: 25.0,
        left: 15,
        child: ElevatedButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => const LogIn(),
            ));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 154, 133, 164),
            shape: const CircleBorder(),
            elevation: 0,
            minimumSize: const Size(50, 50),
          ),
          child: const Icon(
            Icons.logout,
            color: Color.fromARGB(255, 255, 255, 255),
            size: 30,
          ),
        ),
      ),
    );
  }
}
