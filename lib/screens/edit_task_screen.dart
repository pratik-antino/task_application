import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_application/modules/auth/cubits/auth_cubit.dart';
import 'package:task_application/cubits/task_cubit.dart';
import 'package:task_application/models/task.dart';

class EditTaskScreen extends StatefulWidget {
  final Task task;

  const EditTaskScreen({Key? key, required this.task}) : super(key: key);

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
              TextFormField(
                initialValue: _assignedTo,
                decoration: const InputDecoration(labelText: 'Assigned To'),
                onSaved: (value) => _assignedTo = value,
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
              CheckboxListTile(
                title: Text('Completed'),
                value: _status == 'Done',
                onChanged: (bool? value) {
                  setState(() {
                    _status = value! ? 'Done' : 'To Do';
                  });
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _dueDate) {
                    setState(() {
                      _dueDate = picked;
                    });
                  }
                },
                child: Text('Select Due Date: ${_dueDate?.toIso8601String() ?? ''}'),
              ),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Update Task'),
              ),
            ],
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
          dueDate: _dueDate,
          isCompleted: _status == 'Done',
        );

        context.read<TaskCubit>().updateTask(updatedTask, authState.token);
        Navigator.of(context).pop();
      }
    }
  }
}

