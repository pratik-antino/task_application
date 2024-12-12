import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubits/task_cubit.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../../auth/cubits/user_cubit.dart';
import '../../auth/cubits/user_state.dart';
import '../model/task.dart';
import '../../../models/user.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _priority = 'Medium';
  String _status = 'To Do';
  DateTime _dueDate = DateTime.now();
  String? _assignedTo;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<UserCubit>().fetchUsers(authState.token);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        final newTask = Task(
          id: '',
          title: _title,
          description: _description,
          assignedTo: _assignedTo!,
          createdBy: authState.userId,
          priority: _priority,
          status: _status,
          dueDate: _dueDate,
          isCompleted: false,
        );

        context.read<TaskCubit>().addTask(newTask, authState.token);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => _description = value!,
              ),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority'),
                items: ['Low', 'Medium', 'High'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _priority = value!),
              ),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: ['To Do', 'In Progress', 'Done'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _status = value!),
              ),
              ListTile(
                title: const Text('Due Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_dueDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null) {
                    setState(() => _dueDate = pickedDate);
                  }
                },
              ),
              BlocBuilder<UserCubit, UserState>(
                builder: (context, state) {
                  if (state is UserLoaded) {
                    return DropdownButtonFormField<String>(
                      value: _assignedTo,
                      decoration: const InputDecoration(labelText: 'Assign To'),
                      items: state.users.map((User user) {
                        return DropdownMenuItem<String>(
                          value: user.id,
                          child: Text(user.name),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please assign the task to a user';
                        }
                        return null;
                      },
                      onChanged: (value) => setState(() => _assignedTo = value),
                    );
                  } else if (state is UserLoading) {
                    return const Center(child: SizedBox(child: CircularProgressIndicator()));
                  } else if (state is UserError) {
                    return Text('Error: ${state.message}');
                  }
                  return Container();
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

