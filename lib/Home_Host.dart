/*import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:maazim/logIn.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

}

class homePage extends StatelessWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => const LogIn(),
              ));
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome !',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}*/

/*
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:maazim/logIn.dart';
import 'firebase_options.dart';
import 'package:maazim/layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maazim/CreateEventPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maazim Guest',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      debugShowCheckedModeBanner: false,
      home: const homePage(),
    );
  }
}

class homePage extends StatelessWidget {
  const homePage({Key? key}) : super(key: key);

  

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const CustomPage(
            pageTitle: '',
            content: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Welcome!",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 25.0,
            left: 15,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEventPage(), // Navigate to CreateEventPage
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 154, 133, 164),
                shape: const CircleBorder(),
                elevation: 0,
                minimumSize: const Size(50, 50),
              ),
              child: const Icon(
                Icons.add,
                color: Color.fromARGB(255, 255, 255, 255),
                size: 30,
              ),
            ),
          ),
          // Properly use Positioned within a Stack
          Positioned(
            bottom: 25.0,
            right: 15,
            child: ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const LogIn(),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 154, 133, 164),
                shape: const CircleBorder(),
                elevation: 0,
                minimumSize: const Size(50, 50),
              ),
              child: const Icon(
                Icons.logout,
                color: Color.fromARGB(255, 255, 255, 255),
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
this is it */
/*

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:maazim/logIn.dart';
import 'firebase_options.dart';
import 'package:maazim/layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maazim/CreateEventPage.dart'; // Import the CreateEventPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maazim Guest',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      debugShowCheckedModeBanner: false,
      home: const homepage(),
    );
  }
}

class homepage extends StatelessWidget {
  const homepage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const CustomPage(
            pageTitle: '',
            content: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Text(
                    "Welcome!",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          // Properly use Positioned within a Stack
          Positioned(
            bottom: 25.0,
            right: 15,
            child: ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const LogIn(),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 154, 133, 164),
                shape: const CircleBorder(),
                elevation: 0,
                minimumSize: const Size(50, 50),
              ),
              child: const Icon(
                Icons.logout,
                color: Color.fromARGB(255, 255, 255, 255),
                size: 30,
              ),
            ),
          ),
          Positioned(
            bottom: 25.0,
            left: 15,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEventPage(), // Navigate to CreateEventPage
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 154, 133, 164),
                shape: const CircleBorder(),
                elevation: 0,
                minimumSize: const Size(50, 50),
              ),
              child: const Icon(
                Icons.add,
                color: Color.fromARGB(255, 255, 255, 255),
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/
/*
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:maazim/logIn.dart';
import 'firebase_options.dart';
import 'package:maazim/layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maazim/CreateEventPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maazim Host',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      debugShowCheckedModeBanner: false,
      home: const homePage(),
    );
  }
}
class homePage extends StatefulWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Profile',
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    ),
    Text(
      'My Events',
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    ),
    Text(
      'My Invitations',
      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maazim Guest'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEventPage(),
                  ),
                );
              },
              child: const Icon(
                Icons.add,
                size: 30.0,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'My Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail),
            label: 'My Invitations',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
      ),
    );
  }
}
*/

/* this with bar 
import 'package:flutter/material.dart';
import 'package:maazim/CreateEventPage.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:maazim/CreateEventPage.dart';

class homePage extends StatefulWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  late PageController _pageController;
  int _selectedIndex = 0;

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
        title: const Text('Maazim'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEventPage(),
                  ),
                );
              },
              child: const Icon(
                Icons.add,
                size: 30.0,
              ),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const <Widget>[
          Center(
            child: Text(
              'Profile',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              'My Events',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              'My Invitations',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MotionTabBar(
        labels: const ["Profile", "My Events", "My Invitations"],
        initialSelectedTab: "Profile",
        tabIconColor:  const Color(0xFF9a85a4),
        tabSelectedColor:  const Color(0xFF9a85a4),
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
        textStyle: const TextStyle(color:  const Color(0xFF9a85a4)),
      ),
    );
  }
}
*/
/*
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:maazim/logIn.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maazim/CreateEventPage.dart';
import 'package:maazim/custom_tab_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maazim Guest',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      debugShowCheckedModeBanner: false,
      home: const homePage(),
    );
  }
}

class homePage extends StatefulWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<homePage> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = 0;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maazim Guest'),
      ),
      body: Stack(
        children: [
          // Your existing content
          CustomPage(
            pageTitle: '',
            content: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(height: 20),
                  Text(
                    "Welcome!",
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomTabBar(
        selectedIndex: _selectedIndex,
        onTabSelected: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEventPage(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
*/

/*
 import 'package:flutter/material.dart';
import 'package:maazim/CreateEventPage.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';

class homePage extends StatefulWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  late PageController _pageController;
  int _selectedIndex = 0;

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
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/Logo.PNG',), // Change the image path
            ),
            SizedBox(width: 10),
            Text('Maazim'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateEventPage(),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF9a85a4),
                child: Icon(
                  Icons.add,
                  size: 30.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: const <Widget>[
          Center(
            child: Text(
              'Profile',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              'My Events',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              'My Invitations',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      bottomNavigationBar: MotionTabBar(
        labels: const ["Profile", "My Events", "My Invitations"],
        initialSelectedTab: "My Events",
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
*/

/*
import 'package:flutter/material.dart';
import 'package:maazim/CreateEventPage.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';

class homePage extends StatefulWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  late PageController _pageController;
  int _selectedIndex = 0;

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
        title: Text('Maazim'),
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
        children: const <Widget>[
          Center(
            child: Text(
              'Profile',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              'My Events',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              'My Invitations',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateEventPage(),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: MotionTabBar(
        labels: const ["Profile", "My Events", "My Invitations"],
        initialSelectedTab: "Profile",
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
*/

/*
import 'package:flutter/material.dart';
import 'package:maazim/CreateEventPage.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';

class homePage extends StatefulWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  late PageController _pageController;
  int _selectedIndex = 0;

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
            const SizedBox(width: 8), // Add some space between the image and the title
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
        children: const <Widget>[
          Center(
            child: Text(
              'Profile',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              'My Events',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              'My Invitations',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateEventPage(),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Color.fromARGB(255, 33, 150, 243),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      bottomNavigationBar: MotionTabBar(
        labels: const ["Profile", "My Events", "My Invitations"],
        initialSelectedTab: "Profile",
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
*/
/* 
import 'package:flutter/material.dart';
import 'package:maazim/CreateEventPage.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
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
  int _selectedIndex = 0;

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
            const SizedBox(width: 8), // Add some space between the image and the title
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
*/

import 'package:flutter/material.dart';
import 'package:maazim/CreateEventPage.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
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
            const SizedBox(width: 8), // Add some space between the image and the title
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
