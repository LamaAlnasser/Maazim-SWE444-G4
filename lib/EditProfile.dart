import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maazim/Home_Host.dart';
import 'package:maazim/logIn.dart';
import 'package:maazim/ChangePass.dart';



class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
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


  void updateProfile() async {
  if (_formKey.currentState!.validate()) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Map<String, dynamic> updatedFields = {};

      if (firstName != firstNameController.text) {
        updatedFields['firstName'] = firstNameController.text;
      }

      if (lastName != lastNameController.text) {
        updatedFields['lastName'] = lastNameController.text;
      }

      if (email != emailController.text) {
        updatedFields['email'] = emailController.text;
      }

      if (updatedFields.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update(updatedFields);

        setState(() {
          if (updatedFields.containsKey('firstName')) {
            firstName = updatedFields['firstName']!;
          }
          if (updatedFields.containsKey('lastName')) {
            lastName = updatedFields['lastName']!;
          }
          if (updatedFields.containsKey('email')) {
            email = updatedFields['email']!;
          }
        });

        // Show dialog for success
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Success", textAlign: TextAlign.center,),
              
              
              content: Column(
                mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10),
             Text(
                "Profile updated successfully!",
                style: TextStyle(fontSize: 17.0),
                 textAlign: TextAlign.center,
              ),
        ],
              ),
              
              actions: <Widget>[
                Center(child: 
                TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                
                ),
                ),
              ],
            );
          },
        );
      } else {
        // Show dialog for no changes
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(""),
              content: Text(
                "No changes were made.",
                style: TextStyle(fontSize: 20.0),
              ),
              actions: <Widget>[
                Center(
                child: TextButton(
                  child: Text("OK"),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
                ),
              ],
            );
          },
        );
      }
    }
  }
}
  @override
  Widget build(BuildContext context) {
      return Scaffold(
      appBar: AppBar(
  title: Padding(
    padding: const EdgeInsets.fromLTRB(
                        0, 0, 0, 0),
    child: Row(
      mainAxisSize: MainAxisSize.min, // Use this to make sure the children of the Row are at the center.
      children: [
        Image.asset(
          'assets/Logo.PNG', // Replace 'your_image.png' with your image asset path
          height: 30, // Adjust the height as needed
        ),
        const SizedBox(width: 8), // Add some space between the image and the title
        const Text(
          'Maazim',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  ),
  centerTitle: true,
  elevation: 0,
),

 

     body: SingleChildScrollView(
        padding:const EdgeInsets.all(24.0),
         child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,

   
          children: [
            const Text(
                      "Edit Profile",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),

              Row(
                children: [
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 5, 0),
                      child: TextFormField(
                        controller: firstNameController,
                        cursorColor: Color(0xFF9a85a4),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required First Name.';
                          }
                          if (!RegExp(r'^[a-zA-Z\u0621-\u064A]+$').hasMatch(value)) {
                            return 'Note: only letters.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "First Name",
                          labelStyle: TextStyle(color: Color(0xFF9a85a4), fontSize: 14),
                          errorStyle: TextStyle(fontSize: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: Color(0xFF9a85a4).withOpacity(0.6),
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          prefixIcon: Icon(Icons.person),
                        ),
                      
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 16, 0),
                      child: TextFormField(
                        controller: lastNameController,
                        cursorColor: Color(0xFF9a85a4),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required Last Name.';
                          }
                          if (!RegExp(r'^[a-zA-Z\u0621-\u064A]+$').hasMatch(value)) {
                            return 'Note: only letters.';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: "Last Name",
                          labelStyle: TextStyle(color: Color(0xFF9a85a4), fontSize: 14),
                          errorStyle: TextStyle(fontSize: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: Color(0xFF9a85a4).withOpacity(0.6),
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          prefixIcon: Icon(Icons.person),
                        ),
                        onChanged: (value) {
                          // Handle state update here if needed
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),

              child: TextFormField(
                controller: emailController,
                cursorColor: Color(0xFF9a85a4),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required email.';
                  }
                  // Check if the entered value is a valid email address
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                      .hasMatch(value)) {
                    return 'Please enter a valid email address.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Color(0xFF9a85a4), fontSize: 14),
                  errorStyle: TextStyle(fontSize: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: Color(0xFF9a85a4).withOpacity(0.6),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  prefixIcon: Icon(Icons.email),
                ),
                onChanged: (value) {
                  // Handle state update here if needed
                },
              ),
              ),
                  SizedBox(height: 20),
                  

                   
     
                  Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
                 child: TextFormField(
                
                controller: phoneNumberController,
                cursorColor: Color(0xFF9a85a4),
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Phone number',
                  labelStyle: TextStyle(color: Color(0xFF9a85a4), fontSize: 14),
                  errorStyle: TextStyle(fontSize: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                 
                  filled: true,
                  
                  fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(
                      color: Color(0xFF9a85a4).withOpacity(0.6),
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  prefixIcon: Icon(Icons.phone),
                  
                ),
               
              ),
            
                   ),
                
                SizedBox(height: 20),
              Padding(
  padding: const EdgeInsets.symmetric(horizontal: 70),
     child:  ElevatedButton(
              onPressed: updateProfile,
              style: ElevatedButton.styleFrom(
                 shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF9a85a4).withOpacity(0.9),
              ),
                
                child: const Text('Update', style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),),
      ),
              ),

     SizedBox(height: 0), // Add some space between the buttons




           
            ],
          
          ),
          
        ),
        
        
      ),
      
    );
    
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }
  
}