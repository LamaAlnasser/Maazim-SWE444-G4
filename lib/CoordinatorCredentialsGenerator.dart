import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class CoordinatorCredentialsGenerator {
  String generatePassword(int length) {
    const charset =
        "0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz#?!";
    Random secureRandom = Random.secure();
    return List.generate(
            length, (index) => charset[secureRandom.nextInt(charset.length)])
        .join();
  }

  String generateUsername(String eventId) {
    return "EC_$eventId";
  }

  String generateHashedPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  String generateCoordinatorEmail(String username) {
    return "$username@Maazim.com";
  }

  Map<String, String> generateCredentials(String eventName, String eventId) {
    String username = generateUsername(eventId);
    String password =
        generatePassword(8); // You can adjust the length as needed
    String hashedPassword = generateHashedPassword(password);
    String coordinatorEmail = generateCoordinatorEmail(username);
    return {
      'username': username,
      'hashedPassword': hashedPassword,
      'password': password,
      'email': coordinatorEmail
    };
  }
}
