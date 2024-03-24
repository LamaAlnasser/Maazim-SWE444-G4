import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maazim/main.dart';
import 'package:maazim/EditProfile.dart';
import 'package:maazim/ChangePass.dart';
import 'package:maazim/Home_Host.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneNumberController;

  String firstName = "";
  String lastName = "";
  String email = "";
  String phoneNumber = "";

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    phoneNumberController = TextEditingController();
  }

  void fetchUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        firstName = doc['firstName'];
        lastName = doc['lastName'];
        email = doc['email'];
        phoneNumber = doc['phoneNumber']; // Fetch phone number from Firestore
        firstNameController.text = firstName;
        lastNameController.text = lastName;
        emailController.text = email;
        phoneNumberController.text = phoneNumber;
      });
    }
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
    crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start (left)
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 50, top: 0), // Add space at the bottom
        child: const Text(
          "Profile",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
           
                  Center(
                  child: Text(
                    'Hello, $firstName $lastName', // Display first name and last name
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 30 ),
                  ),
                  ),
                  SizedBox(height: 50),
            InkWell(
              
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfile()),
                );
              },
              child: ListTile(
                leading: Icon(Icons.person, color: Color.fromARGB(255, 154, 133, 164)), // Icon for Edit Profile
                title: Text('Edit Profile'),
              ),
            ),
            Divider(), // Add a line
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePass()),
                );
              },
              child: ListTile(
                leading: Icon(Icons.lock, color: Color.fromARGB(255, 154, 133, 164)), // Icon for Change Password
                title: Text('Change Password'),
              ),
            ),
            Divider(), // Add a line
            InkWell(
              onTap: () async {
                bool confirmLogout = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Center(child: Text("Logout")), // Centered title
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Are you trying to log out?", textAlign: TextAlign.center), // Centered message
                          SizedBox(height: 12), // Spacer
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center, // Center buttons
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false); // Return false if user chooses "No"
                                },
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), // Make "Cancel" bold
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true); // Return true if user chooses "Yes"
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
                    builder: (context) => MyApp(), // Ensure WelcomePage is defined
                  ));
                }
              },
              child: ListTile(
                leading: Icon(Icons.logout, color: Color.fromARGB(255, 154, 133, 164)), // Icon for Log Out
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
