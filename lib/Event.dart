import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:maazim/Home_Host.dart';
import 'package:maazim/notification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:country_picker/country_picker.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class MaazimEvent {
  final String eventName;
  final String address; // New property for address
  final String eventLocation;
  final String eventType;
  final DateTime eventDate;
  final TimeOfDay eventTime;
  final String inviterName;
  final int numberOfInvitees;
  final List<String> inviteesPhoneNumbers;
  final int duration;
  final String dressCode;
  final String theme;
  MaazimEvent({
    required this.eventName,
    required this.address,
    required this.eventLocation,
    required this.eventType,
    required this.eventDate,
    required this.eventTime,
    required this.inviterName,
    required this.numberOfInvitees,
    required this.inviteesPhoneNumbers,
    required this.duration,
    required this.dressCode, // Initialize in constructor
    required this.theme, // Initialize in constructor
  });

  String? get eventId => null;
  factory MaazimEvent.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    return MaazimEvent(
      eventName: data['eventName'] ?? '',
      address: data['address'] ?? '',
      eventLocation: data['eventLocation'] ?? '',
      eventType: data['eventType'] ?? '',
      eventDate: (data['eventDateTime'] as Timestamp).toDate(),
      eventTime:
          TimeOfDay.fromDateTime((data['eventDateTime'] as Timestamp).toDate()),
      inviterName: data['inviterName'] ?? '',
      numberOfInvitees: data['numberOfInvitees'] ?? 0,
      inviteesPhoneNumbers:
          List<String>.from(data['inviteesPhoneNumbers'] ?? []),
      duration: data['duration'] ?? 1,
      dressCode: data['dressCode'] ?? 'Casual',
      theme: data['theme'] ?? 'Standard',
    );
  }
}
