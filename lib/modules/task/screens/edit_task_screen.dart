import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_application/models/user.dart';
import 'package:task_application/modules/auth/cubits/auth_cubit.dart';
import 'package:task_application/modules/auth/cubits/user_cubit.dart';
import 'package:task_application/modules/auth/cubits/user_state.dart';
import 'package:task_application/modules/task/cubits/task_cubit.dart';
import 'package:task_application/modules/task/model/task.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _title;
  String? _description;
  String? _assignedTo;
  String? _priority;
  String _status = 'To Do';
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _title = widget.task.title;
    _description = widget.task.description;
    _assignedTo = widget.task.assignedTo;
    _priority = widget.task.priority;
    _status = widget.task.status;
    _dueDate = widget.task.dueDate;
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<UserCubit>().fetchUsers(authState.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                  onSaved: (value) => _title = value,
                ),
                TextFormField(
                  initialValue: _description,
                  decoration: const InputDecoration(labelText: 'Description'),
                  onSaved: (value) => _description = value,
                ),

                BlocBuilder<UserCubit, UserState>(
                  builder: (context, state) {
                    if (state is UserLoaded) {
                      return DropdownButtonFormField<String>(
                        value: _assignedTo,
                        decoration:
                            const InputDecoration(labelText: 'Assign To'),
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
                        onChanged: (value) =>
                            setState(() => _assignedTo = value),
                      );
                    } else if (state is UserLoading) {
                      return const Center(
                          child: SizedBox(child: CircularProgressIndicator()));
                    } else if (state is UserError) {
                      return Text('Error: ${state.message}');
                    }
                    return Container();
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: ['High', 'Medium', 'Low'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _priority = value),
                ),
                // CheckboxListTile(
                //   title: const Text('Completed'),
                //   value: _status == 'Done',
                //   onChanged: (bool? value) {
                //     setState(() {
                //       _status = value! ? 'Done' : 'To Do';
                //     });
                //   },
                // ),
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
                const SizedBox(
                  height: 15,
                ),

                ListTile(
                  title: const Text('Select Due Date'),
                  subtitle: Text(DateFormat('dd-MM-yy').format(_dueDate!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _dueDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (pickedDate != null) {
                      setState(() => _dueDate = pickedDate);
                    }
                  },
                ),
                // ElevatedButton(
                //   onPressed: () async {
                //     final DateTime? picked = await showDatePicker(
                //       context: context,
                //       initialDate: _dueDate ?? DateTime.now(),
                //       firstDate: DateTime(2000),
                //       lastDate: DateTime(2101),
                //     );
                //     if (picked != null && picked != _dueDate) {
                //       setState(() {
                //         _dueDate = picked;
                //       });
                //     }
                //   },
                //   child: Text(
                //       'Select Due Date: ${_dueDate?.toIso8601String() ?? ''}'),
                // ),
                const SizedBox(
                  height: 60,
                ),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Update Task'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        final updatedTask = widget.task.copyWith(
          title: _title,
          description: _description,
          assignedTo: _assignedTo!,
          priority: _priority,
          status: _status,
          dueDate: DateTime.parse(
              _dueDate?.toIso8601String() ?? DateTime.now().toString()),
          isCompleted: _status == 'Done',
        );
        context.read<TaskCubit>().updateTask(updatedTask, authState.token);
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    }
  }
}
