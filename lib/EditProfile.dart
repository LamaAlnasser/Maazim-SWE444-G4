import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maazim/Home_Host.dart';
import 'package:maazim/logIn.dart';
import 'package:maazim/ChangePass.dart';
import 'package:maazim/main.dart';



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
              backgroundColor:  Color.fromARGB(255, 255, 255, 255),
              title: Text("Success", 
               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              content: 
             Text(
                "Profile updated successfully!" ),
              actions:  [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    backgroundColor: const Color(0xFF9a85a4)
                        .withOpacity(0.9), // Rounded corners
                  ),
                  child: const Text('OK',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255))),
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
             backgroundColor:  Color.fromARGB(255, 255, 255, 255),
              title: Text("Editing", 
               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              content: Text(
                "No changes were made.",
              ),
              actions:  [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    backgroundColor: const Color(0xFF9a85a4)
                        .withOpacity(0.9), // Rounded corners
                  ),
                  child: const Text('OK',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255))),
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

   /*
     SizedBox(height: 225), // Add some space between the buttons
     Center(
     child: Text("_______________________________",
     style: TextStyle(
      fontSize: 18,
      color:  const Color(0xFF9a85a4).withOpacity(0.8),
      fontWeight: FontWeight.bold,
    ),),
    ),
*/
      SizedBox(height: 225), // Add some space between the buttons
      Divider(),       
      TextButton(
      onPressed: deleteAccount,
      style: ElevatedButton.styleFrom(
      shape: const StadiumBorder(),
      padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Text('Delete Account',
       style: TextStyle(
       fontSize: 18,
       color:  const Color(0xFF9a85a4).withOpacity(0.8),
       fontWeight: FontWeight.normal,
    ),
  ),
), 
           
            ],
          ),
        ),
      ),
    ); 
  }
  void deleteAccount() async {
  String? errorMessage;
  String? passwordErrorMessage;

  // Show a confirmation dialog
  bool confirmDelete = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
         backgroundColor:  Color.fromARGB(255, 255, 255, 255),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.circle,
                  color: Colors.red.withOpacity(0.2),
                  size: 40,
                ),
                Text(
                  "!",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8), // Add some space between the image and the title
            Text(
              'Delete Account',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Are you sure you want to delete your account?"),
            SizedBox(height: 16),
            Text(
              "By deleting your account:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text("- All your Events will be deleted."),
            Text("- Your invitations are saved on your phone number so you can use the app as a guest."),
            SizedBox(height: 16),
            Text("Note:",style: TextStyle(fontWeight: FontWeight.bold)),
            Text("if you want to delete your account because you are changing your phone number, make sure to contact us."),
          ],
        ),        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Return false to cancel deletion
            },
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              backgroundColor: const Color(0xFF9a85a4).withOpacity(0.9), // Rounded corners
            ),
            child: Text(
              "Cancel",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true); // Return true to confirm deletion
            },
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              backgroundColor: Colors.red.withOpacity(0.9), // Rounded corners
            ),
            child: Text(
              "Delete",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ),
        ],
      );
    },
  );

  // If deletion is confirmed, proceed to delete the account
  if (confirmDelete == true) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? password; // Password entered by the user

      if (password == null) {
        // Prompt user to enter password
        password = await _showPasswordInputDialog(context, passwordErrorMessage);
      }

      if (password != null) {
        try {
          // Reauthenticate the user
          String? email = user.email;
          if (email != null) {
            AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
            await user.reauthenticateWithCredential(credential);

            // Delete user document from Firestore
            await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();

            // Delete user from Firebase Authentication
            await user.delete();

            // Delete events associated with the user
            await deleteEventsForUser(user.uid);

            // Navigate to welcome page after successful deletion
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => WelcomePage()), // Replace WelcomePage() with your welcome screen widget
              (Route<dynamic> route) => false, // Prevent going back to previous screens
            );
          } else {
            // Handle case where email is null
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Failed to delete account. Please try again later."),
            ));
          }
        } on FirebaseAuthException catch (error) {
          // Check if the error is due to an invalid password
          setState(() {
            passwordErrorMessage = "Incorrect password. Please try again.";
          });
        } catch (error) {
          print("Error: $error");
        }
      }
    }
  }
}

Future<void> deleteEventsForUser(String userID) async {
  try {
    QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance.collection('events').where('userId', isEqualTo: userID).get();
    if (eventsSnapshot.size > 0) {
      // If there are events associated with the user
      for (QueryDocumentSnapshot eventDoc in eventsSnapshot.docs) {
        await eventDoc.reference.delete();
      }
      print('Events deleted successfully for user ID: $userID');
    } else {
      print('No events found for user ID: $userID');
    }
  } catch (error) {
    print('Error deleting events: $error');
  }
}

  Future<String?> _showPasswordInputDialog(BuildContext context, String? errorMessage) async {
  bool obscureCurrentPassword = true; // Set initial state for password visibility

  TextEditingController passwordController = TextEditingController();
  return await showDialog<String?>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
               return AlertDialog(
         backgroundColor:  Color.fromARGB(255, 255, 255, 255),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.circle,
                  color: Colors.red.withOpacity(0.2),
                  size: 40,
                ),
                Text(
                  "!",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8), // Add some space between the image and the title
            Text(
              'Confirmation',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               Text("Enter your password to confirm the account deletion"),
               SizedBox(height: 16),
                TextFormField(
                  cursorColor: Color(0xFF9a85a4),
                  controller: passwordController,
                  obscureText: obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
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
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscureCurrentPassword = !obscureCurrentPassword;
                        });
                      },
                      icon: Icon(
                        obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              if (errorMessage != null)
  Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      errorMessage ?? "", // Provide a default value if errorMessage is null
      style: TextStyle(color: Colors.red, fontSize: 12),
    ),
  ),

              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(null); // Return null to indicate cancellation
                },
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  backgroundColor: const Color(0xFF9a85a4).withOpacity(0.9), // Rounded corners
                ),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  String password = passwordController.text;
                  if (password.isEmpty) {
                    // Show error message if password field is empty
                    setState(() {
                      errorMessage = "Password cannot be empty.";
                    });
                  } else {
                    // Validate the password here
                    bool isPasswordValid = await validatePassword(password); // Replace validatePassword with your validation function
                    if (isPasswordValid) {
                      Navigator.of(context).pop(password); // Return entered password
                    } else {
                      // Show error message if password is incorrect
                      setState(() {
                        errorMessage = "Incorrect password. Please try again.";
                      });
                    }
                  }
                },
            style: ElevatedButton.styleFrom(
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              backgroundColor: Colors.red.withOpacity(0.9), // Rounded corners
            ),
            child: Text(
              "Confirm",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
          ),
            ],
          );
        },
      );
    },
  );
}



Future<bool> validatePassword(String password) async {
  // Check if the entered password matches the user's actual password
  try {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: password);
      await user.reauthenticateWithCredential(credential);
      // If reauthentication is successful, return true
      return true;
    }
  } catch (error) {
    // If reauthentication fails, return false
    return false;
  }
  // If user is null or reauthentication fails, return false
  return false;
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