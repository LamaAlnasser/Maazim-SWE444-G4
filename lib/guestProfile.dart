import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maazim/main.dart';
import 'package:maazim/guestHomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maazim/signUp.dart';

class guestProfilePage extends StatefulWidget {
  @override
  guestProfilePageState createState() => guestProfilePageState();
}

class guestProfilePageState extends State<guestProfilePage> {
  late String phoneNumber = ""; // Declare a variable to store the phone number

  @override
  void initState() {
    super.initState();
    fetchPhoneNumber(); // Call the function to fetch the phone number
  }

  Future<void> fetchPhoneNumber() async {
    String? number = await getCurrentUserPhoneNumber();
    if (number != null) {
      setState(() {
        phoneNumber = number;
      });
    }
  }

  Future<String?> getCurrentUserPhoneNumber() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Try to get the phone number from the users collection first
        DocumentSnapshot userDoc =
            await firestore.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;
          if (userData != null && userData.containsKey('phoneNumber')) {
            String? phoneNumber = userData['phoneNumber'] as String?;
            return phoneNumber; // Assuming it's stored without the country code
          }
        } else {
          // If phone number is not available in the users collection, use the one from Authentication
          String? authPhoneNumber = user.phoneNumber;
          if (authPhoneNumber != null && authPhoneNumber.isNotEmpty) {
            // Remove the country code if present
            return authPhoneNumber.replaceFirst(RegExp(r'^\+966'), '');
          }
        }
      }
    } catch (error) {
      print('Error getting current user phone number: $error');
    }
    return null; // Return null if user is not signed in or phone number is not found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 50, top: 0),
              child: const Text(
                "Profile",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: Text(
                'Hello, $phoneNumber', // Display phone number
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 27),
              ),
            ),
            SizedBox(height: 50),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUp()),
                );
              },
              child: ListTile(
                leading: Icon(Icons.account_box, color: Color.fromARGB(255, 154, 133, 164)),
                title: Text('Upgrade Your Profile'),
              ),
            ),
            Divider(),
            InkWell(
              onTap: () async {
                bool confirmLogout = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Center(child: Text("Logout")),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Are you trying to log out?", textAlign: TextAlign.center),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: Text("OK", style: TextStyle(fontSize: 16)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );

                if (confirmLogout == true) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => MyApp(),
                  ));
                }
              },
              child: ListTile(
                leading: Icon(Icons.logout, color: Color.fromARGB(255, 154, 133, 164)),
                title: Text('Log Out'),
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
