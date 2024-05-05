import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class QRScanPage extends StatefulWidget {
  final String coordinatorUsername;

  QRScanPage({Key? key, required this.coordinatorUsername}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  Barcode? barcode;
  Timer? _messageTimer; // Timer to manage display message duration

  String? displayMessage; // Changed to hold the display message directly
  Set<String> checkedInGuestIds =
      Set(); // This set will track checked-in guests
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    controller?.dispose();
    _messageTimer?.cancel(); // Cancel the timer if active
    super.dispose();
  }

  @override
  void reassemble() async {
    super.reassemble();
    if (Platform.isAndroid) {
      await controller?.pauseCamera();
    } else if (Platform.isIOS) {
      await controller?.pauseCamera();
      await Future.delayed(const Duration(milliseconds: 100));
    }
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: true,
            title: Row(
              children: [
                Image.asset('assets/Logo.PNG', height: 30),
                const SizedBox(width: 10),
                Text('QR Scanner',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            centerTitle: true,
            elevation: 0,
          ),
          body: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              buildQrView(context),
              Positioned(bottom: 10, child: buildResult()),
            ],
          ),
        ),
      );

  Widget buildQrView(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: const Color(0xFF9a85a4),
          borderRadius: 10,
          borderLength: 40,
          borderWidth: 10,
          cutOutSize: MediaQuery.of(context).size.width * 0.8,
        ),
      );

  Widget buildResult() {
    Color textColor;
    Color backgroundColor;

    switch (displayMessage) {
      case "A guest can enter.":
        textColor = Colors.green.shade800;
        backgroundColor = Colors.green.shade200;
        break;
      case "Not a guest.":
        textColor = Colors.red.shade800;
        backgroundColor = Colors.red.shade200;
        break;
      case "Guest has already checked in.":
        textColor = Colors.orange.shade800;
        backgroundColor = Colors.orange.shade200;
        break;
      default:
        textColor = Colors.black87;
        backgroundColor = Colors.white24;
        break;
    }

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: backgroundColor,
      ),
      child: Text(
        displayMessage ?? 'Scan a code!',
        maxLines: 3,
        style: TextStyle(
          fontSize: 16,
          color: textColor,
        ),
      ),
    );
  }

  void onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      _messageTimer?.cancel(); // Cancel any existing timer
      var parts = scanData.code!.split('|');
      if (parts.length == 2) {
        var eventId = parts[0].trim();
        var guestId = parts[1].trim();

        if (eventId == widget.coordinatorUsername) {
          if (checkedInGuestIds.contains(guestId)) {
            updateDisplay("Guest has already checked in.");
          } else {
            // Show the "A guest can enter." message immediately.
            updateDisplay("A guest can enter.",
                duration: 3); // Display this message for 10 seconds

            // Delay adding the guest ID to the set and updating Firestore
            await Future.delayed(Duration(seconds: 5), () {
              checkedInGuestIds
                  .add(guestId); // Add the guest ID to the set after the delay
              updateFirestore(
                  guestId); // Update Firestore after the message has been displayed
            });
          }
        } else {
          updateDisplay("Not a guest.");
        }
      } else {
        updateDisplay("Invalid QR Code");
      }
    });
  }

  void updateDisplay(String message, {int duration = 20}) {
    setState(() {
      displayMessage = message;
    });
    _messageTimer = Timer(Duration(seconds: duration), () {
      setState(() {
        displayMessage = null;
      });
    });
  }

  Future<void> updateFirestore(String guestId) async {
    try {
      var querySnapshot = await _firestore
          .collection('coordinators')
          .where('eventId', isEqualTo: widget.coordinatorUsername)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        var docRef = querySnapshot.docs.first.reference;
        await docRef.update({
          'checkedInGuestIds': FieldValue.arrayUnion([guestId])
        });
      } else {
        print(
            "No matching document found for event ID: ${widget.coordinatorUsername}");
      }
    } catch (e) {
      print('Error updating Firestore: $e');
    }
  }
}
