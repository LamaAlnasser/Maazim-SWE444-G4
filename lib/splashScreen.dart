import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:maazim/main.dart';
import 'package:lottie/lottie.dart';


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(splash:
    Column(
      children: [
        Center(
          child:LottieBuilder.asset("assets/Maazim-Splash2.json")
            ,)])
    
    , nextScreen:  WelcomePage(),
    splashIconSize: 400,
    splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Color(0xFF9a85a4), // Set the background color

  );
  }
}


/* 
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:lottie/lottie.dart';
import 'package:maazim/main.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: LottieBuilder.asset(
              "assets/Maazim-Splash.json",
              width: 300, // Adjust size if necessary
              height: 300, // Adjust size if necessary
              fit: BoxFit.cover,
              onLoaded: (composition) {
                // Optionally, adjust animation speed or other properties
              },
            ),
          ),
        ],
      ),
      nextScreen: WelcomePage(),
      splashIconSize: 300, // Adjust to match the Lottie animation size
      duration: 1500,  //Set duration to 1 second
      splashTransition: SplashTransition.fadeTransition,
      backgroundColor: Colors.white, // Set the background color
    );
  }
}*/
