import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maazim/Home_Host.dart';
import 'package:maazim/forgetPassword.dart';
import 'package:maazim/logIn.dart';
import 'package:maazim/profile_page.dart';
import 'package:maazim/NewPasswordHost.dart';

class ChangePass extends StatefulWidget {
  const ChangePass({Key? key}) : super(key: key);

  @override
  _ChangePassState createState() => _ChangePassState();
}

class _ChangePassState extends State<ChangePass> {
  late TextEditingController currentPasswordController;

  String? errorMessage;

  bool obscureCurrentPassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    currentPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    super.dispose();
  }

  void _validateCurrentPassword() async {
    String currentPassword = currentPasswordController.text;
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);

        // If the current password is correct, navigate to the page where user can change the password
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewPasswordHost() )
        );
      } on FirebaseAuthException catch (error) {
        // If the current password is incorrect, show an error message
        setState(() {
          errorMessage = "Current password is incorrect.";
        });
      } catch (error) {
        print("Error: $error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       
        title: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Row(
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
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Change Password",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 25),
              Center(
                child: Text(
                  'To set a new password, please enter your current password first',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: TextFormField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrentPassword,
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
                      obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Center(
  child: errorMessage != null ? Text(errorMessage!, style: TextStyle(color: Colors.red)) : Container(),
),

 SizedBox(height: 15),

      
          
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 85),
              
              child: ElevatedButton(
                onPressed: () {
                  _validateCurrentPassword();
               
                }, 
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(), backgroundColor: Color(0xFF9a85a4).withOpacity(0.9),
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text('Next',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),),
              
              ),),
           
       SizedBox(height: 10),
       
     
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 60),
  child: TextButton(
    onPressed: () {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
    },
    child: Text(
      'Forgot your password?',
      style: TextStyle(
        fontSize: 16,
        color: Colors.grey[600], // Customize color as needed
       
      ),
    ),
  ),
),
     
              
                         


              
            ],
            
          ),
        ),
      ),
    );
  }
}