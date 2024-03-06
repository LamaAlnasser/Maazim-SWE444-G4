import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CombinedInvitationServiceAndUI extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> _findUserIdByEmail(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot
            .docs.first.id; // Assuming user ID is the document ID
      } else {
        print("No user found with email $email");
        return null;
      }
    } catch (e) {
      print("Error finding user by email: $e");
      return null;
    }
  }

  Future<void> createInvitation({
    required String eventName,
    required String eventType,
    required String nameOfInviter,
    required DateTime date,
    required String time,
    required String eventLocationAddress,
    required List<String> guestEmails,
  }) async {
    List<String> guestUserIds = [];

    for (var email in guestEmails) {
      final userId = await _findUserIdByEmail(email);
      if (userId != null) {
        guestUserIds.add(userId);
      } else {
        print("No userID found for email: $email");
      }
    }

    if (guestUserIds.isEmpty) {
      print("No valid guests to invite. Exiting...");
      return;
    }

    try {
      await _firestore.collection('Invitations').add({
        'eventName': eventName,
        'eventType': eventType,
        'nameOfInviter': nameOfInviter,
        'date': Timestamp.fromDate(date),
        'time': time,
        'eventLocationAddress': eventLocationAddress,
        'guestUserIds': guestUserIds,
        'acceptedUserIds': [], // Initialize as empty list
        'rejectedUserIds': [], // Initialize as empty list
      });
      print("Invitation created successfully for $eventName.");
    } catch (e) {
      print("Error creating invitation: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Invitation'), // Provide a title for your AppBar
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => createInvitation(
            eventName: "Hello World.",
            eventType: "Charity Ball",
            nameOfInviter: "Mrs. Java laplap",
            date: DateTime(2024, 12, 20), // December 20, 2024
            time: "7:30 PM",
            eventLocationAddress: "The Grand Ballroom",
            guestEmails: [
              "gege0@gmail.com",
              "lulu0@gmail.com",
              "ranoom0@gmail.com",
              "lama0@gmail.com",
              "nony0@gmail.com",
            ],
          ),
          child: Text('Send Invitation!'),
        ),
      ),
    );
  }
}
