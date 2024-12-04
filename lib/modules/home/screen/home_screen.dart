import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../../task/screens/task_list_screen.dart';
import '../../events/screens/schedule_event_screen.dart';
import '../../events/calendar_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Management App'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              context.read<AuthCubit>().logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(16.0),
        children: [
          _buildGridItem(context, 'Task Management', Icons.assignment, () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => TaskListScreen()));
          }),
          _buildGridItem(context, 'Meeting Scheduling', Icons.event, () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => ScheduleEventScreen()));
          }),
        ],
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2.0,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48.0),
            SizedBox(height: 8.0),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

