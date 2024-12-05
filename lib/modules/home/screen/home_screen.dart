import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_application/modules/auth/screens/login_screen.dart';
import 'package:task_application/modules/meetings/meeting.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../../task/screens/task_list_screen.dart';
import '../../events/calendar_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void _logout() {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => LoginScreen()));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Task Management App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              context.read<AuthCubit>().logout();
              _logout();
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildGridItem(context, 'Task Management', Icons.assignment, () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => TaskListScreen()));
          }),
          _buildGridItem(context, 'Event Scheduling', Icons.event, () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => CalendarScreen()));
          }),
          _buildGridItem(context, 'Meeting Scheduling', Icons.event, () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => GoogleCalendarScreen()));
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
