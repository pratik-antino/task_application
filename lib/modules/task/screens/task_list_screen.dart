import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_application/modules/task/screens/add_task_screen.dart';
import 'package:task_application/modules/home/screen/home_screen.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../cubits/task_cubit.dart';
import '../../../models/task.dart';
import '../../auth/screens/login_screen.dart';

class TaskListScreen extends StatelessWidget {
  late String token;
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          token = authState.token;
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
                  return Center(
                      child: Center(child: CircularProgressIndicator()));
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
                  MaterialPageRoute(builder: (context) => AddTaskScreen()),
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
        return Dismissible(
          key: Key(task.id),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            context
                .read<TaskCubit>()
                .deleteTask(task.id, token);
          },
          child: ListTile(
            title: Text(task.title),
            subtitle: Text(task.description),
            trailing: Text(task.priority),
            onTap: () {},
          ),
        );
      },
    );
  }
}
