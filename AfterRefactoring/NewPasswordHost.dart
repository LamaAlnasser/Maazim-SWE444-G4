import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maazim/Home_Host.dart';
import 'package:maazim/profile_page.dart';

class NewPasswordHost extends StatefulWidget {
 


  @override
  _NewPasswordHostState createState() => _NewPasswordHostState();
}

class _NewPasswordHostState extends State<NewPasswordHost> {

final _formKey = GlobalKey<FormState>();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String? errorMessage;
  bool obscureNewPassword = false;
  bool obscureConfirmPassword = false;

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required field.';
    }
    // Custom password strength check
    if (value.length < 8) {
      return 'Password must be at least 8 characters long.';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter.';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one digit.';
    }
    // Add more checks as needed, such as special characters

    return null;
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        automaticallyImplyLeading: true,
        leading: Padding(
           padding: const EdgeInsets.only(left: 16.0, top: 30),
      child: IconButton(
      onPressed: () {
        // Navigate to another page
      Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => homePage()),
            );
      },
      icon: Icon(Icons.arrow_back),
      tooltip: 'Go to Another Page',
    ), ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
         
          children: [
            Image.asset(
              'assets/Logo.PNG',
              height: 30,
            ),
            const SizedBox(width: 8),
            const Text(
              'Maazim',
              style: TextStyle(fontWeight: FontWeight.bold),
              
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey, // Use _formKey here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Change Password",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              // New password field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: TextFormField(
                  controller: newPasswordController,
                  obscureText: obscureNewPassword,
                  cursorColor: Color(0xFF9a85a4),
                  validator: validatePassword,
                  decoration: InputDecoration(
                    labelText: ' New Password',
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
                      borderSide: BorderSide(color: Color(0xFF9a85a4).withOpacity(0.6)),
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
                          obscureNewPassword = !obscureNewPassword;
                        });
                      },
                      icon: Icon(
                        obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              // Confirm Password field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: TextFormField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  cursorColor: Color(0xFF9a85a4),
                    validator: (value) {
                     if (value == null || value.isEmpty) {
                            return 'Required field.';
                                                         }
                      if (value != newPasswordController.text) {
                          return 'Passwords do not match.';
                                                         }
                            return null;
                                        },
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
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
                      borderSide: BorderSide(color: Color(0xFF9a85a4).withOpacity(0.6)),
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
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                      icon: Icon(
                          obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
                SizedBox(height: 20),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60),
              
             child:  ElevatedButton(
                
          onPressed: () {
  if (_formKey.currentState!.validate()) {
    // Validation passed, proceed with password update
    FirebaseAuth.instance.currentUser?.updatePassword(newPasswordController.text).then((_) {
      // Password update successful
      setState(() {
        errorMessage = null;
      });

      // Show success AlertDialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
          backgroundColor:  Color.fromARGB(255, 255, 255, 255),
            title: Text("Success",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
            content: Text(
              "Password updated successfully!" ),
            actions:[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: ElevatedButton(
                  onPressed: () {
                     Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => homePage()),
                );
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
    }).catchError((error) {
      // Password update failed
      setState(() {
        errorMessage = error.toString();
      });
    });
  }
},

                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(), backgroundColor: Color(0xFF9a85a4).withOpacity(0.9),
                  padding: EdgeInsets.symmetric(vertical: 10), ),

                child: Text('Update Password',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),),
              ), ),
              SizedBox(height: 16),
              Center(
                child: errorMessage != null ? Text(errorMessage!, style: TextStyle(color: Colors.red)) : Container(),
              ),

              
            ],
          ),
        ),
      ),
    );
  }
}