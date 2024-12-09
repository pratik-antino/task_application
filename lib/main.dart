import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:task_application/cubits/audio_command_cubit.dart';
import 'package:task_application/modules/auth/cubits/auth_cubit.dart';
import 'package:task_application/cubits/calendar_cubit.dart';
import 'package:task_application/modules/events/cubits/event_cubit.dart';
import 'package:task_application/modules/meetings/meeting_cubit.dart';
import 'package:task_application/modules/notification/cubits/notification_cubit.dart';
import 'package:task_application/modules/task/cubits/task_cubit.dart';
import 'package:task_application/modules/auth/cubits/user_cubit.dart';
import 'package:task_application/modules/auth/screens/login_screen.dart';

/// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(); // Ensure Firebase is initialized
  print('Handling a background message: ${message.messageId}');
}

/// Local notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Entry point of the Flutter application
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Configure Firebase Messaging background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Set up local notification channel for Android
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // Channel ID
    'High Importance Notifications', // Channel name
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );
  // Initialize local notifications
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Request notification permissions
   FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    badge: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  // Initialize foreground notification handling
  initializeForegroundNotifications();

  runApp(MyApp());
}

/// Initialize foreground notifications
 void initializeForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title ?? 'No Title',
          notification.body ?? 'No Body',
     const      NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel', // Channel ID
              'High Importance Notifications', // Channel Name
              channelDescription: 'This channel is used for important notifications.',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher', // Ensure a small icon is set
            ),
          ),
        );
      }
    });
  
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('Notification opened: ${message.notification?.title}');
    // Handle navigation or other actions when a notification is opened
  });
}

/// Main application widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => AuthCubit()),
        BlocProvider<TaskCubit>(create: (context) => TaskCubit()),
        BlocProvider<EventCubit>(create: (context) => EventCubit()),
        BlocProvider<CalendarCubit>(create: (context) => CalendarCubit()),
        BlocProvider<MeetingCubit>(create: (context) => MeetingCubit()),
        BlocProvider<UserCubit>(create: (context) => UserCubit()),
        BlocProvider<NotificationCubit>(create: (context) => NotificationCubit()),
        BlocProvider<AudioCommandCubit>(create: (context) => AudioCommandCubit()),
      ],
      child: MaterialApp(
        title: 'Task Management App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const  LoginScreen(),
      ),
    );
  }
}