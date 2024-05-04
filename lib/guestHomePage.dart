import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:maazim/CreateEventPage.dart';
import 'package:maazim/guestEvents.dart';
import 'package:maazim/guestInvitations.dart';
import 'package:maazim/guestProfile.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'profile_page.dart'; // Import your profile page file
import 'my_events_page.dart'; // Import your my events page file
import 'my_invitations_page.dart'; // Import your my invitations page file

class guestHomePage extends StatefulWidget {
  const guestHomePage({Key? key}) : super(key: key);

  @override
  _guestHomePageState createState() => _guestHomePageState();
}

class _guestHomePageState extends State<guestHomePage> {
  late PageController _pageController;
  int _selectedIndex = 2; // Set My Events as the initial tab

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
    _requestPermissions();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _requestPermissions() {
    // Optionally, prompt the user with a custom dialog before calling requestPermissionToSendNotifications
    AwesomeNotifications().requestPermissionToSendNotifications();
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
         showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Permission Required"),
          content:
              Text("This app requires notification access to function properly."),
          actions: <Widget>[
                   ElevatedButton(
                 style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    backgroundColor: const Color(0xFF9a85a4)
                        .withOpacity(0.9), // Rounded corners
                  ),
                  child: const Text('cancel',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255))),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Dismiss the dialog but do nothing
              },
            ),
            ElevatedButton(
                 style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    backgroundColor: const Color(0xFF9a85a4)
                        .withOpacity(0.9), // Rounded corners
                  ),
                  child: const Text('Open Settings',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 255, 255, 255))),
              onPressed: () {
                openAppSettings(); // Open app settings
              },
            ),
          ],
        );
      },
    );
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back button
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/Logo.PNG', // Replace 'your_image.png' with your image asset path
              height: 30, // Adjust the height as needed
            ),
            const SizedBox(
                width: 8), // Add some space between the image and the title
            Text(
              'Maazim',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: <Widget>[
          guestProfilePage(), // Your profile page widget
          guestEventsPage(), // Your my events page widget
          guestInvitationsPage(), // Your my invitations page widget
        ],
      ),
      bottomNavigationBar: MotionTabBar(
        labels: const ["Profile", "Events", "Invitations"],
        initialSelectedTab: "Invitations",
        tabIconColor: const Color(0xFF9a85a4),
        tabSelectedColor: const Color(0xFF9a85a4),
        onTabItemSelected: (int index) {
          setState(() {
            _selectedIndex = index;
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        icons: const [Icons.person, Icons.event, Icons.mail],
        textStyle: const TextStyle(color: const Color(0xFF9a85a4)),
      ),
    );
  }
}
