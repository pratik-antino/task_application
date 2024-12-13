import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_application/modules/auth/screens/login_screen.dart';
import 'package:task_application/modules/meeting_module/screens/google_calender_screen.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../../task/screens/task_list_screen.dart';
import '../../events/calendar_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void logout() async {
      await context.read<AuthCubit>().logout();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Task Management App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: logout,
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildGridItem(context, 'Task Management', Icons.assignment, () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const TaskListScreen()));
          }),
          _buildGridItem(context, 'Event Scheduling', Icons.event, () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CalendarScreen()));
          }),
          _buildGridItem(context, 'Meeting Scheduling', Icons.event, () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GoogleCalendarScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildGridItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2.0,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48.0),
            const SizedBox(height: 8.0),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
