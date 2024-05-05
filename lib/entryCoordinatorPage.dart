import 'package:flutter/material.dart';
import 'package:maazim/layout.dart';
import 'package:maazim/main.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:maazim/CoordinatorWelcomePage.dart'; //Tab1 
import 'package:maazim/QRScannerPage.dart'; //Tab2

class EntityCoordinatorPage extends StatefulWidget {
  final String coordinatorUsername;

  const EntityCoordinatorPage({Key? key, required this.coordinatorUsername})
      : super(key: key);

  @override
  _EntityCoordinatorPageState createState() => _EntityCoordinatorPageState();
}

class _EntityCoordinatorPageState extends State<EntityCoordinatorPage> {
  late PageController _pageController;
  int _selectedIndex = 1; // Set My Events as the initial tab
  String get eventId => widget.coordinatorUsername;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        physics: NeverScrollableScrollPhysics(), // Disable page swiping
        children: <Widget>[
          cWelcomePage(eventID: eventId), // Pass the eventid to cWelcomePage
          QRScanner(coordinatorUsername: widget.coordinatorUsername),
        ],
      ),
      bottomNavigationBar: MotionTabBar(
        labels: const ["Event", "Scan"],
        initialSelectedTab: "Scan",
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
        icons: const [Icons.event, Icons.camera_alt],
        textStyle: const TextStyle(color: const Color(0xFF9a85a4)),
      ),
    );
  }
}
