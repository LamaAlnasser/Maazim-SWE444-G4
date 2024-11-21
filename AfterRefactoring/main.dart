import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:maazim/guestLogIn.dart';
import 'package:maazim/logIn.dart';
import 'package:maazim/notification.dart';
import 'package:maazim/signUp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:maazim/layout.dart';
import 'package:maazim/splashScreen.dart';


Future<void> main() async {
   WidgetsFlutterBinding
      .ensureInitialized(); // Ensure the Flutter binding is initialized
  await Firebase.initializeApp(); // Initialize Firebase
  await AwesomeNotifications().initialize(
    null, // Ensure you have an app icon in your Android and iOS project
    [
      NotificationChannel(
        channelGroupKey: "basic_channel_group",
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Color(0xFF9a85a4),
        importance: NotificationImportance.High,
        ledColor: Colors.white,
        playSound: true,
        enableVibration: true,
      )
    ],
    channelGroups: [
     NotificationChannelGroup(channelGroupKey: 'basic_channel_group', channelGroupName: 'basic_group')
    ],
    debug: true
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: NotificationController.navigatorKey, // Use the static GlobalKey
      title: 'Maazim',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    body: Stack(
      children: [
    CustomPage(
      pageTitle: "",
      content: Padding(
        padding: const EdgeInsets.all(24.0),
      child: Column(
       crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.asset( 
            'assets/Logo.PNG',
            width: 160.0,
            height: 160.0,
          ),
          const SizedBox(height: 15),
          const Text(
            'Maazim',
            style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold,),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 22,
          child: Text('Crafting your perfect event journey.',
             style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                textAlign: TextAlign.center,
          ),
          ),
          const SizedBox(height: 20),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LogIn()),
              ),
                style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF9a85a4).withOpacity(0.9),          
              ),
              child: const Text(
                'Login',
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255))
              ),
            ),),

                    const SizedBox(height: 20),
                    // Signup Button
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignUp())),
                          
                       style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(style: BorderStyle.solid, width: 2,
                color: Color(0xFF9a85a4),
                ),// Rounded corners
                 backgroundColor: Color(0xFFFFFFFF), // Button background color
                        ),
                        child: const Text('Sign up',
                    style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold, color: Color(0xFF9a85a4))
                      ),
                    ),),

          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GuestLogIn()),
            ),
            child: const Text("Continue as Guest",
                              style: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
      ),
    ),
      ],
    ),
    );
  }
}

