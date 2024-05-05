import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:maazim/QRCamera.dart';

class QRScanner extends StatefulWidget {
  final String coordinatorUsername;

  QRScanner({Key? key, required this.coordinatorUsername}) : super(key: key);

  @override
  _QRScanner createState() => _QRScanner();
}

class _QRScanner extends State<QRScanner> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0), // Add horizontal padding
                child: Text(
                  'Hello, you are responsible for event guest check-in.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0), // Add horizontal padding
                child: Text(
                  'Start by tapping the Scan QR Code button.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              // Example usage of the coordinatorUsername
              // Text('Coordinator: ${widget.coordinatorUsername}'),
              Image.asset(
                'assets/QRCode.png',
                width: 300,
                height: 300,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => QRScanPage(
                            coordinatorUsername: widget.coordinatorUsername)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  side: BorderSide(
                    style: BorderStyle.solid,
                    width: 2,
                    color: Color(0xFF9a85a4),
                  ),
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  'Scan QR',
                  style: TextStyle(
                    color: Color(0xFF9a85a4),
                    fontSize: 15,
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