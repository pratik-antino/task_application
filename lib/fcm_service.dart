import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Initialize FCM and configure settings
  Future<void> initializeFCM() async {
    // Request permission for notifications
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Notification permissions granted!');
    } else {
      print('Notification permissions denied.');
    }

    // Configure foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription:
                  'This channel is used for important notifications.',
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }
    });
  }

  // Retrieve FCM token
  Future<String?> getFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await prefs.setString('fcmtoken', token);
      }
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Error retrieving FCM token: $e');
      return null;
    }
  }

  // Send FCM token to backend
  Future<void> sendTokenToBackend(String token, String usertoken) async {
    // Replace with your backend API endpoint
    const String backendUrl =
        'https://7e8e-121-243-82-214.ngrok-free.app/api/tokens/save-token';
    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $usertoken',
        },
        body: json.encode({'fcmToken': token}),
      );

      if (response.statusCode == 200) {
        print('FCM token sent to backend successfully!');
      } else {
        print('Failed to send FCM token to backend: ${response.body}');
      }
    } catch (e) {
      print('Error sending FCM token to backend: $e');
    }
  }
}
