import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:maazim/CreateEventPage.dart';
import 'package:maazim/notification.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'profile_page.dart'; // Import your profile page file
import 'my_events_page.dart'; // Import your my events page file
import 'my_invitations_page.dart'; // Import your my invitations page file

class homePage extends StatefulWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  late PageController _pageController;
  int _selectedIndex = 1; // Set My Events as the initial tab

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
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications().then((_) {
        AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
          if (!isAllowed) {
            // Show dialog here
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor:  Color.fromARGB(255, 255, 255, 255),
                  title: Text("Permission Required"),
                  content: Text(
                      "This app requires notification access to function properly."),
                  actions: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        backgroundColor: const Color(0xFF9a85a4).withOpacity(0.9),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255))),
                      onPressed: () {
                        Navigator.of(context).pop(); // Dismiss the dialog
                      },
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        backgroundColor: const Color(0xFF9a85a4).withOpacity(0.9),
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
      });
    }
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
        physics: NeverScrollableScrollPhysics(), // Disable page swiping
        children: <Widget>[
          ProfilePage(), // Your profile page widget
          MyEventsPage(), // Your my events page widget
          MyInvitationsPage(), // Your my invitations page widget
        ],
      ),
      bottomNavigationBar: MotionTabBar(
        labels: const ["Profile", "Events", "Invitations"],
        initialSelectedTab: "Events",
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
