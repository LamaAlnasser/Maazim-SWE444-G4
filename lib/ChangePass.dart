import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maazim/Home_Host.dart';
import 'package:maazim/logIn.dart';
import 'package:maazim/profile_page.dart';

class ChangePass extends StatefulWidget {
  const ChangePass({Key? key}) : super(key: key);

  @override
  _ChangePassState createState() => _ChangePassState();
}

class _ChangePassState extends State<ChangePass> {
  late TextEditingController currentPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  String? errorMessage;

   bool obscureCurrentPassword = true;
  bool obscureNewPassword = true;
  bool obscureConfirmPassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    currentPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

Future<void> changePassword() async {
  // Reset error message
  setState(() {
    errorMessage = null;
  });

  // Check if current password matches user's current password
  String currentPassword = currentPasswordController.text;
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    AuthCredential credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    // Validate new password
    String? newPasswordError = validateNewPassword(newPasswordController.text);
    if (newPasswordError != null) {
      setState(() {
        errorMessage = newPasswordError;
      });
      return;
    }

    try {
      // Attempt to re-authenticate user with current password
      await user.reauthenticateWithCredential(credential);

      // Re-authentication successful, proceed with password change

      // Change password to the new one
      String newPassword = newPasswordController.text;
      await user.updatePassword(newPassword);

      // Show success message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Password changed successfully.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );

      // Clear text fields
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
    } on FirebaseAuthException catch (error) {
      if (error.code == 'wrong-password') {
        // Handle incorrect current password
        setState(() {
          errorMessage = "Current password is incorrect.";
        });
      } else {
        // Handle other authentication errors
        setState(() {
          errorMessage = error.message!;
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
      });
    }
  }
}

String? validateNewPassword(String password) {
  if (password.isEmpty) {
    return 'New password is required.';
  }
  // Custom password strength check
  if (password.length < 8) {
    return 'Password must be at least 8 characters long.';
  }
  if (!password.contains(RegExp(r'[A-Z]'))) {
    return 'Password must contain at least one uppercase letter.';
  }
  if (!password.contains(RegExp(r'[a-z]'))) {
    return 'Password must contain at least one lowercase letter.';
  }
  if (!password.contains(RegExp(r'[0-9]'))) {
    return 'Password must contain at least one digit.';
  }
  return null;
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
                      "Change Password",
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 15),

 Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
              ),
            //  Current Password field
               child: TextFormField(
  controller: currentPasswordController,
  obscureText: !obscureCurrentPassword, 
  cursorColor: Color(0xFF9a85a4),
  decoration: InputDecoration(
    labelText: ' Current Password',
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
          // Toggle password visibility
          obscureCurrentPassword = !obscureCurrentPassword;
        });
      },
      icon: Icon(
       obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
        color: Colors.grey, 
      ),
    ),
  ),
),
 ),
              

            SizedBox(height: 10),

Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
              ),
            //New password field
          child: TextFormField(
  controller: newPasswordController,
  obscureText: !obscureNewPassword, 
  cursorColor: Color(0xFF9a85a4),

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
          // Toggle password visibility
          obscureNewPassword = !obscureNewPassword;
        });
      },
      icon: Icon(
        obscureNewPassword ? Icons.visibility : Icons.visibility_off,
        color: Colors.grey, 
      ),
    ),
  ),
),
),

              
            SizedBox(height: 10),
            
            //confirm Password field
           Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
              ),
             child: TextFormField(
  
  controller: confirmPasswordController,
  obscureText: !obscureConfirmPassword, 
  cursorColor: Color(0xFF9a85a4),
  
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
          // Toggle password visibility
          obscureConfirmPassword = !obscureConfirmPassword;
        });
      },
      icon: Icon(
        obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
        color: Colors.grey, // Adjust color as needed
      ),
    ),
  ),
),
           ),


           
            SizedBox(height: 16),
    
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 70),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ElevatedButton(
        onPressed: changePassword,
        style: ElevatedButton.styleFrom(
          shape: StadiumBorder(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFF9a85a4).withOpacity(0.9),
        ),
        
        child: const Text('Save', style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),),
      ),
      if (errorMessage != null)
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            errorMessage!,
            style: TextStyle(color: Colors.red),
          ),
        ),
    ],
  ),
),


          ],
        ),
      ),
      ),
    );
  }
}
