import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_application/cubits/audio_command_cubit.dart';
import 'package:task_application/modules/auth/cubits/auth_cubit.dart';
import 'package:task_application/cubits/calendar_cubit.dart';
import 'package:task_application/modules/events/cubits/event_cubit.dart';
import 'package:task_application/cubits/meeting_cubit.dart';
import 'package:task_application/modules/notification/cubits/notification_cubit.dart';
import 'package:task_application/cubits/task_cubit.dart';
import 'package:task_application/modules/auth/cubits/user_cubit.dart';
import 'package:task_application/screens/login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(create: (context) => AuthCubit()),
        BlocProvider<TaskCubit>(create: (context) => TaskCubit()),
        BlocProvider<EventCubit>(create: (context) => EventCubit()),
        BlocProvider<CalendarCubit>(create: (context) => CalendarCubit()),
        BlocProvider<MeetingCubit>(create: (context) => MeetingCubit()),
        BlocProvider<UserCubit>(create: (context) => UserCubit(),
        ),
        BlocProvider<NotificationCubit>(
            create: (context) => NotificationCubit()),
        BlocProvider<AudioCommandCubit>(
            create: (context) => AudioCommandCubit()),
       
      ],
      child: MaterialApp(
        title: 'Task Management App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: LoginScreen(),
      ),
    );
  }
}
