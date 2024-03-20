/*
import 'package:flutter/material.dart';
import 'package:maazim/CreateEventPage.dart';

class MyEventsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
     automaticallyImplyLeading: false, // Remove the back button
        title: Text('My Events'),
      ),
      body: Center(
        child: Text('This is the My Events Page'),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateEventPage(),
              ),
            );
          },
          child: Icon(Icons.add),
          backgroundColor: Color(0xFFC8D4C0),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

*/
/*
import 'package:flutter/material.dart';
import 'package:maazim/CreateEventPage.dart';

class MyEventsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       automaticallyImplyLeading: false, // Remove the back button
        title: Text(
              'My Events',
              style: TextStyle(fontWeight: FontWeight.bold ,fontSize:30),
            ),
      ),
      body: Center(
        child: Text('This is the My Events Page'),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateEventPage(),
              ),
            );
          },
          child: Icon(
            Icons.add,
            size: 36,
            color: Colors.white,
          ),
          backgroundColor: Color(0xFFC8D4C0),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
*/

/*
import 'package:flutter/material.dart';
import 'package:maazim/CreateEventPage.dart';

class MyEventsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back button
        title: Row(
          children: [
            SizedBox(width: 8), // Add space between the icon and the title
            Text(
              'My Events',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('This is the My Events Page'),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateEventPage(),
              ),
            );
          },
          child: Icon(
            Icons.add,
            size: 36,
            color: Colors.white,
          ),
          backgroundColor: Color(0xFFC8D4C0),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
*/
/*
import 'package:flutter/material.dart';
import 'package:maazim/CreateEventPage.dart';

class MyEventsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back button
        title: Row(
          children: [
            SizedBox(width: 8), // Add space between the icon and the title
            Text(
              'My Events',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Upcoming Events
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF9a85a4),
                    fixedSize: Size(170, 30),
                    //padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    'Upcoming',
                    style: TextStyle(color: Colors.white , fontSize: 15 ,fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to Past Events
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF9a85a4),
                    fixedSize: Size(170, 30),
                    //padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    'Past Events',
                    style: TextStyle(color: Colors.white , fontSize: 15 ,fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16), // Add some space between buttons and other content
          Center(
            child: Text('This is the My Events Page'),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateEventPage(),
              ),
            );
          },
          child: Icon(
            Icons.add,
            size: 36,
            color: Colors.white,
          ),
          backgroundColor: Color(0xFFC8D4C0),
          
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
*/


import 'package:flutter/material.dart';
import 'package:maazim/CreateEventPage.dart';

class MyEventsPage extends StatefulWidget {
  @override
  _MyEventsPageState createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  bool _showUpcomingEvents = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove the back button
        title: Row(
          children: [
            SizedBox(width: 8), // Add space between the icon and the title
            Text(
              'My Events',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showUpcomingEvents = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: _showUpcomingEvents ?  Color(0xFF9a85a4) : Color(0xFF9a85a4).withOpacity(0.2),
                    fixedSize: Size(171, 30),
                  ),
                  child: Text(
                    'Upcoming',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showUpcomingEvents = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: _showUpcomingEvents ? Color(0xFF9a85a4).withOpacity(0.2) : Color(0xFF9a85a4),
                    fixedSize: Size(171, 30),
                  ),
                  child: Text(
                    'Past Events',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16), // Add some space between buttons and other content
          Center(
            child: _showUpcomingEvents ? UpcomingEvents() : PastEvents(),
          ),
        ],
      ),
      //add button 
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateEventPage(),
              ),
            );
          },
          child: Icon(
            Icons.add,
            size: 36,
            color: Colors.white,
          ),
          backgroundColor: Color(0xFF586258),
           shape: CircleBorder(), // Make the button circular

        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class UpcomingEvents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Upcoming Events'),
    );
  }
}

class PastEvents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Past Events'),
    );
  }
}
