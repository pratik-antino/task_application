import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_application/modules/task/screens/add_task_screen.dart';
import 'package:task_application/modules/task/screens/task_detail_screen.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../cubits/task_cubit.dart';
import '../model/task.dart';
import '../../auth/screens/login_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late String token;

  @override
  void initState() {
    super.initState();
    // context.read<TaskCubit>().fet
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        if (authState is AuthAuthenticated) {
          token = authState.token;
          context.read<TaskCubit>().fetchTasks(authState.token);
          return Scaffold(
            appBar: AppBar(
              title: const Text('Tasks'),
            ),
            body: BlocBuilder<TaskCubit, TaskState>(
              builder: (context, taskState) {
                if (taskState is TaskInitial) {
                  context.read<TaskCubit>().fetchTasks(authState.token);
                  return const Center(child: CircularProgressIndicator());
                } else if (taskState is TaskLoading) {
                  return const Center(
                      child: Center(child: CircularProgressIndicator()));
                } else if (taskState is TaskLoaded) {
                  return _buildTaskList(taskState.tasks);
                } else if (taskState is TaskError) {
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(content: Text('Error loading task')),
                  // );
                  return Container();
                }
                return const Center(child: Text('Unknown state'));
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const AddTaskScreen()),
                );
                context.read<TaskCubit>().fetchTasks(authState.token);
              },
              child: const Icon(Icons.add),
            ),
          );
        } else {
          return const LoginScreen();
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
            padding: const EdgeInsets.only(right: 20.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.endToStart,
          onDismissed: (direction) {
            context.read<TaskCubit>().deleteTask(task.id, token);
          },
          child: ListTile(
            title: Text(task.title),
            subtitle: Text(task.description),
            trailing: Text(task.priority),
            onTap: () => _addEditTask(context, task),
          ),
        );
      },
    );
  }

  void _addEditTask(BuildContext context, Task task) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => TaskDetailScreen(task: task, token: token)),
    );
  }

  int _priorityValue(String priority) {
    switch (priority) {
      case 'High':
        return 3;
      case 'Medium':
        return 2;
      case 'Low':
        return 1;
      default:
        return 0;
    }
  }
}
