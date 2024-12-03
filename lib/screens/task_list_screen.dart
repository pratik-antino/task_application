import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_application/screens/home_screen.dart';
import '../modules/auth/cubits/auth_cubit.dart';
import '../cubits/task_cubit.dart';
import '../models/task.dart';
import 'login_screen.dart';

class TaskListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Tasks'),
              actions: [
                IconButton(
                  icon: Icon(Icons.exit_to_app),
                  onPressed: () {
                    context.read<AuthCubit>().logout();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                ),
              ],
            ),
            body: BlocBuilder<TaskCubit, TaskState>(
              builder: (context, taskState) {
                if (taskState is TaskInitial) {
                  context.read<TaskCubit>().fetchTasks(authState.token);
                  return Center(child: CircularProgressIndicator());
                } else if (taskState is TaskLoading) {
                  return Center(child: Center(child: CircularProgressIndicator()));
                } else if (taskState is TaskLoaded) {
                  return _buildTaskList(taskState.tasks);
                } else if (taskState is TaskError) {
                  return Center(child: Text('Error: ${taskState.message}'));
                }
                return Center(child: Text('Unknown state'));
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
                context.read<TaskCubit>().fetchTasks(authState.token);
              },
              child: Icon(Icons.add),
            ),
          );
        } else {
          return LoginScreen();
        }
      },
    );
  }

  Widget _buildTaskList(List<Task> tasks) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(task.description),
          trailing: Text(task.priority),
          onTap: () {
        
            // Navigate to task details or edit screen
          },
        );
      },
    );
  }
}