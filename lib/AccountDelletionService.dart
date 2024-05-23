import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:maazim/main.dart';
import 'package:maazim/notification.dart';


class AccountDeletionService {
  static Future<void> deleteAccount(BuildContext context) async {
    String? errorMessage;
    String? passwordErrorMessage;

    bool confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.circle,
                    color: Colors.red.withOpacity(0.2),
                    size: 40,
                  ),
                  Text(
                    "!",
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8), // Add some space between the image and the title
              Text(
                'Delete Account',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Are you sure you want to delete your account?"),
              SizedBox(height: 16),
              Text(
                "By deleting your account:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text("- All your Events will be deleted."),
              Text("- Your invitations are saved on your phone number so you can use the app as a guest."),
              SizedBox(height: 16),
              Text("Note:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("if you want to delete your account because you are changing your phone number, make sure to contact us."),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Return false to cancel deletion
              },
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                backgroundColor: const Color(0xFF9a85a4).withOpacity(0.9), // Rounded corners
              ),
              child: Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true); // Return true to confirm deletion
              },
              style: ElevatedButton.styleFrom(
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                backgroundColor: Colors.red.withOpacity(0.9), // Rounded corners
              ),
              child: Text(
                "Delete",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String? password;

        if (password == null) {
          password = await _showPasswordInputDialog(context, passwordErrorMessage);
        }

        if (password != null) {
          try {
            String? email = user.email;
            if (email != null) {
              AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
              await user.reauthenticateWithCredential(credential);

              await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
              await user.delete();
              await deleteEventsForUser(user.uid);

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => WelcomePage()),
                (Route<dynamic> route) => false,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text("Failed to delete account. Please try again later."),
              ));
            }
          } on FirebaseAuthException catch (error) {
            passwordErrorMessage = "Incorrect password. Please try again.";
          } catch (error) {
            print("Error: $error");
          }
        }
      }
    }
  }

  static Future<String?> _showPasswordInputDialog(BuildContext context, String? errorMessage) async {
    bool obscureCurrentPassword = true;

    TextEditingController passwordController = TextEditingController();
    return await showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.circle,
                        color: Colors.red.withOpacity(0.2),
                        size: 40,
                      ),
                      Text(
                        "!",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Confirmation',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Enter your password to confirm the account deletion"),
                  SizedBox(height: 16),
                  TextFormField(
                    cursorColor: Color(0xFF9a85a4),
                    controller: passwordController,
                    obscureText: obscureCurrentPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Color(0xFF9a85a4), fontSize: 14),
                      errorStyle: TextStyle(fontSize: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Color(0xFF9a85a4).withOpacity(0.1),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: Color(0xFF9a85a4).withOpacity(0.6),
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureCurrentPassword = !obscureCurrentPassword;
                          });
                        },
                        icon: Icon(
                          obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  if (errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        errorMessage ?? "",
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    backgroundColor: const Color(0xFF9a85a4).withOpacity(0.9),
                  ),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    String password = passwordController.text;
                    if (password.isEmpty) {
                      setState(() {
                        errorMessage = "Password cannot be empty.";
                      });
                    } else {
                      bool isPasswordValid = await validatePassword(password);
                      if (isPasswordValid) {
                        Navigator.of(context).pop(password);
                      } else {
                        setState(() {
                          errorMessage = "Incorrect password. Please try again.";
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    backgroundColor: Colors.red.withOpacity(0.9),
                  ),
                  child: Text(
                    "Confirm",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Future<bool> validatePassword(String password) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: password);
        await user.reauthenticateWithCredential(credential);
        return true;
      }
    } catch (error) {
      return false;
    }
    return false;
  }
/*
  static Future<void> deleteEventsForUser(String userID) async {
    try {
      QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance.collection('events').where('userId', isEqualTo: userID).get();
      for (QueryDocumentSnapshot eventDoc in eventsSnapshot.docs) {
        await eventDoc.reference.delete();
      }
      print('Events deleted successfully for user ID: $userID');
      sendNotificationsToInvitees();
    } catch (error) {
      print('Error deleting events: $error');
    }
  }


  static Future<void> sendNotificationsToInvitees() async {
    try {
      QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance.collection('events').get();
      for (QueryDocumentSnapshot eventDoc in eventsSnapshot.docs) {
        String eventID = eventDoc.id;
        String eventName = eventDoc['eventName'];

        QuerySnapshot inviteesSnapshot = await eventDoc.reference.collection('acceptedInvitees').get();
        for (QueryDocumentSnapshot inviteeDoc in inviteesSnapshot.docs) {
          String inviteeID = inviteeDoc.id;

          print('Sending notification to $inviteeID for event "$eventName"');
          await sendNotification(inviteeID, eventName);
          print('Notification sent to $inviteeID');
        }
      }
    } catch (error) {
      print('Error sending notifications: $error');
    }
  }

  static Future<void> sendNotification(String userID, String eventName) async {
    try {
      String notificationTitle = 'Event Deleted!';
      String notificationBody = 'The event "$eventName" you were invited to has been deleted.';

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().microsecondsSinceEpoch.remainder(1000000),
          channelKey: 'basic_channel',
          title: notificationTitle,
          body: notificationBody,
          notificationLayout: NotificationLayout.Default,
        ),
        actionButtons: [
          NotificationActionButton(
            key: 'OPEN_EVENT',
            label: 'View Event',
          ),
        ],
      );
    } catch (error) {
      print('Error sending notification to $userID: $error');
    }
  }*/
/*
static Future<void> deleteEventsForUser(String userID) async {
  try {
    QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('userId', isEqualTo: userID)
        .get();
    for (QueryDocumentSnapshot eventDoc in eventsSnapshot.docs) {
      // Get event details
      Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;

      // Get invitees' phone numbers
      List<dynamic> inviteesPhoneNumbers = eventData['inviteesPhoneNumbers'];

      // Send notification to each invitee
      for (var phoneNumber in inviteesPhoneNumbers) {
        await sendNotification(phoneNumber, eventData['eventName']);
      }

      // Delete the event
      await eventDoc.reference.delete();
    }
    print('Events deleted successfully for user ID: $userID');
  } catch (error) {
    print('Error deleting events: $error');
  }
}
static Future<void> sendNotification(String phoneNumber, String eventName) async {
  print('Sending notification for event deletion');
  try {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
       // id: DateTime.now().microsecondsSinceEpoch.remainder(1000000),
        channelKey: 'basic_channel',
        title: '$eventName Updated!',
        body: 'The event you are invited to has been Deleted. Please check the details.',
       //notificationLayout: NotificationLayout.Default,

      ),
      schedule: NotificationInterval(
        interval: 5,
        timeZone: DateTime.now().timeZoneName,
      ),
      actionButtons: [
      NotificationActionButton(
        key: 'OPEN_EVENT',
        label: 'View Event',
      ),
    ],
    );
    print('Notification sent successfully for event deletion $eventName,$phoneNumber');
  } catch (e) {
    print('Error sending notification for event deletion: $e');
  }
}*/

static Future<void> deleteEventsForUser(String userID) async {
  try {
    QuerySnapshot eventsSnapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('userId', isEqualTo: userID)
        .get();

    for (QueryDocumentSnapshot eventDoc in eventsSnapshot.docs) {
      // Get event details
      Map<String, dynamic> eventData = eventDoc.data() as Map<String, dynamic>;

      // Check if the event is upcoming
      Timestamp eventTimestamp = eventData['eventDateTime'];
      DateTime eventDateTime = eventTimestamp.toDate();
      if (eventDateTime.isAfter(DateTime.now())) {
        // Get invitees' phone numbers
        List<dynamic> inviteesPhoneNumbers = eventData['inviteesPhoneNumbers'];

        /*Send notification to each invitee
        for (var phoneNumber in inviteesPhoneNumbers) {
          await sendNotification(phoneNumber, eventData['eventName']);
        }*/
      }

      // Delete the event
      await eventDoc.reference.delete();
    }
    print('Events deleted successfully for user ID: $userID');
  } catch (error) {
    print('Error deleting events: $error');
  }
}

/*
static Future<void> sendNotification(String phoneNumber, String eventName) async {
  print('Sending notification for event deletion');
  try {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 0,
        channelKey: 'basic_channel',
        title: 'Event Deleted',
        body: 'The event $eventName has been deleted.',
      ),
    );
    print('Notification sent successfully for event deletion');
  } catch (e) {
    print('Error sending notification for event deletion: $e');
  }
}*/

}
