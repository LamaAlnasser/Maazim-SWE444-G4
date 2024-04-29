import 'package:flutter/material.dart';
import 'package:maazim/QRResult.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QRScanner extends StatefulWidget {
  @override
  _QRScanner createState() => _QRScanner();
}

class _QRScanner extends State<QRScanner> {
  TextEditingController controller = TextEditingController(); //i wont use it
  String? guestIdentifier;
  bool isGuestAllowed = false; // New variable to track guest permission
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  var qrstr = "let's Scan it";
  var coordinatorUsername = "EC_AMzdxjkXU18nclSmWO5E";

  Future<void> scanQr() async {
    print('Scan QR button was pressed.'); // Log that the button was pressed

    // Check the camera permission status
    var cameraStatus = await Permission.camera.status;
    print(
        'Current camera permission status: $cameraStatus'); // Log the current permission status

    // If the permission is not granted, request it
    if (!cameraStatus.isGranted) {
      print('Requesting camera permission...');
      cameraStatus = await Permission.camera.request();
      print(
          'Camera permission status after requesting: $cameraStatus'); // Log the status after requesting
    }

    // If the permission is granted, proceed to scan
    if (cameraStatus.isGranted) {
      try {
        print('Starting QR scan...');
        String? qrdata = await scanner.scan();
        print('QR scan completed. Data: $qrdata'); // Log the scanned data

        // Process the QR data
        if (qrdata != null) {
          List<String> dataParts = qrdata.split('|');
          if (dataParts.length == 2) {
            String eventID = dataParts[0];
            guestIdentifier = dataParts[1];
            bool allowedStatus = eventID ==
                coordinatorUsername
                    .split('_')[1]; // Replace with your actual logic

            setState(() {
              isGuestAllowed = allowedStatus;
            });

            print(
                'Guest allowed status: $isGuestAllowed'); // Log the result of the check
          } else {
            print(
                'QR data format is invalid.'); // Log if the data format doesn't meet the expected format
          }
        } else {
          print('No data received from QR scan.'); // Log if no data is received
        }
      } on PlatformException catch (e) {
        print(
            'An error occurred while scanning: $e'); // Log if there's an error during scanning
      }
    } else {
      print(
          'Camera permission is not granted. Cannot start QR scan.'); // Log if the permission is not granted
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            // Your leading icon action goes here
          },
          icon: const Icon(Icons.qr_code_scanner),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Tap the camera icon to scan QR code",
              style: TextStyle(
                color: Colors.black54,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            IconButton(
              icon: Icon(Icons.camera_alt),
              iconSize: 50.0, // You can adjust the size of the icon as needed
              onPressed: scanQr,
              color: Theme.of(context).primaryColor,
            ),
            if (guestIdentifier != null) // Display check-in status
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  isGuestAllowed
                      ? 'Guest can enter the event.'
                      : 'Guest cannot enter the event.',
                  style: TextStyle(
                    color: isGuestAllowed ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            // ... Other UI elements as needed
            if (guestIdentifier !=
                null) // Conditional rendering for Check in button
              ElevatedButton(
                onPressed: isGuestAllowed
                    ? () {
                        // Replace 'coordinatorDocumentID' with the actual document ID
                        checkInGuest(
                            'EC_AMzdxjkXU18nclSmWO5E', guestIdentifier!);
                      }
                    : null, // Button is disabled if the guest is not allowed
                child: const Text('Check in'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> checkInGuest(
      String coordinatorID, String guestIdentifier) async {
    // Reference to the coordinator's document in Firestore
    DocumentReference coordinatorDoc =
        _firestore.collection('coordinators').doc(coordinatorID);

    return _firestore.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot snapshot = await transaction.get(coordinatorDoc);
      if (!snapshot.exists) {
        throw Exception("Coordinator does not exist!");
      }

      // Check if guest is already checked in
      List<dynamic> checkedInGuests = snapshot['Checkedin'] ?? [];
      if (!checkedInGuests.contains(guestIdentifier)) {
        // Add guest identifier to the 'Checkedin' array in the document
        transaction.update(coordinatorDoc, {
          'Checkedin': FieldValue.arrayUnion([guestIdentifier])
        });
      } else {
        throw Exception("Guest already checked in!");
      }
    }).then((value) {
      // Handle successful check-in, such as updating UI or showing confirmation
    }).catchError((error) {
      // Handle errors, such as showing an error message
      print("Failed to check in guest: $error");
    });
  }
}
//   String? result =
//       "Hello World...!"; // Made result nullable by adding a question mark

//   Future _scanQR() async {
//     try {
//       // The result of scan() is nullable, so we capture it into a nullable String
//       String? cameraScanResult = await scanner.scan();
//       setState(() {
//         // Use the result if it's not null, otherwise keep the current value
//         result = cameraScanResult ?? result;
//       });
//     } on PlatformException catch (e) {
//       print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("QR Scanner Example In Flutter"),
//       ),
//       body: Center(
//         // Handle displaying the result even if it's null
//         child:
//             Text(result ?? 'No result'), // Show 'No result' if result is null
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         icon: Icon(Icons.camera_alt),
//         onPressed: () {
//           _scanQR(); // calling a function when user clicks on button
//         },
//         label: Text("Scan"),
//       ),
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//     );
//   }
// }

// class QRScanner extends StatefulWidget {
//   const QRScanner({Key? key}) : super(key: key);

//   @override
//   State<QRScanner> createState() => _QRScannerState();
// }

// class _QRScannerState extends State<QRScanner> {
//   bool isFlashOn = false;
//   bool isFrontCamera = false;
//   bool isScanCompleted = false;
//   MobileScannerController cameraController = MobileScannerController();

//   @override
//   void initState() {
//     super.initState();
//     cameraController.onBarcodeScanned.listen((barcode) {
//       if (!isScanCompleted) {
//         isScanCompleted = true;
//         String code = barcode.rawValue ?? "---";
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) {
//             return QRResult(
//               code: code,
//               closeScreen: closeScreen,
//             );
//           }),
//         );
//       }
//     });
//   }

//   void closeScreen() {
//     setState(() {
//       isScanCompleted = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: const Color.fromARGB(255, 255, 255, 255),
//         leading:
//             IconButton(onPressed: () {}, icon: Icon(Icons.qr_code_scanner)),
//         centerTitle: true,
//         title: Text(
//           "QR Scanner",
//           style: TextStyle(
//               color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
//         ),
//         actions: [
//           IconButton(
//             onPressed: () {
//               setState(() {
//                 isFlashOn = !isFlashOn;
//               });
//               cameraController.toggleTorch();
//             },
//             icon: Icon(
//               Icons.flash_on,
//               color: isFlashOn ? Colors.white : Colors.black,
//             ),
//           ),
//           IconButton(
//               onPressed: () {
//                 setState(() {
//                   isFrontCamera = !isFrontCamera;
//                 });
//                 cameraController.switchCamera();
//               },
//               icon: Icon(
//                 Icons.flip_camera_android,
//                 color: isFrontCamera ? Colors.white : Colors.black,
//               )),
//         ],
//       ),
//       body: Container(
//         width: double.infinity,
//         padding: EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Expanded(
//                 child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   "Place the QR code in designated area",
//                   style: TextStyle(
//                       color: Colors.black,
//                       fontSize: 15,
//                       fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   "Let the scan do the magic - It starts on its own!",
//                   style: TextStyle(color: Colors.black54, fontSize: 12),
//                 )
//               ],
//             )),
//             SizedBox(
//               height: 20,
//             ),
//             Expanded(
//                 flex: 2,
//                 child: Stack(
//                   //children: [
//                   //   MobileScanner(
//                   //     controller: cameraController,
//                   //   ),
//                   //   QRScannerOverlay(
//                   //     overlayColor: Colors.black26,
//                   //     borderColor: Color.fromARGB(255, 120, 79, 118),
//                   //     borderRadius: 20,
//                   //     borderStrokeWidth: 10,
//                   //     scanAreaWidth: 250,
//                   //     scanAreaHeight: 250,
//                   //   )
//                   // ],
//                 )),
//             Expanded(
//                 child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   "| Scan properly to see results |",
//                   style: TextStyle(
//                       color: Color.fromARGB(255, 120, 79, 118),
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ],
//             )),
//           ],
//         ),
//       ),
//     );
//   }
// }
