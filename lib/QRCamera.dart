import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';

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
  String? displayMessage; // Changed to hold the display message directly

  @override
  void dispose() {
    controller?.dispose();
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
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        var parts = scanData.code!.split('|');
        if (parts.isNotEmpty) {
          var eventId = parts[0];
          displayMessage = eventId == widget.coordinatorUsername
              ? "A guest can enter."
              : "Not a guest.";
        } else {
          displayMessage =
              "Invalid QR Code"; // Default message if not a valid code
        }
      });
    });
  }
}
