import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_application/models/event.dart';
import 'package:task_application/modules/auth/cubits/auth_cubit.dart';
import 'package:task_application/modules/events/cubits/event_cubit.dart'; // Your EventCubit

class AddEditEventScreen extends StatefulWidget {
  final Event event;

  // Pass the existing event to edit
  const AddEditEventScreen({super.key, required this.event});

  @override
  _AddEditEventScreenState createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends State<AddEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));

  @override
  void initState() {
    super.initState();
    _title = widget.event.title;
    _description = widget.event.description;
    _startTime = widget.event.startTime;
    _endTime = widget.event.endTime;
  }

 void _submitForm() {
  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      if (authState.userId != widget.event.ownerId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Only the creator can edit this event.')),
        );
        return;
      }

      final updatedEvent = Event(
        id: widget.event.id,
        title: _title,
        description: _description,
        startTime: _startTime,
        endTime: _endTime,
        participants: widget.event.participants,
        sharedWith: widget.event.sharedWith,
        ownerId: authState.userId,
      );

      context.read<EventCubit>().updateEvent(updatedEvent, authState.token);
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication error. Please log in again.')),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _title,
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
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => _description = value!,
              ),
              ListTile(
                title: const Text('Start Time'),
                subtitle: Text(_startTime.toString()),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _startTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_startTime),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _startTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
              ),
              ListTile(
                title: const Text('End Time'),
                subtitle: Text(_endTime.toString()),
                trailing: const Icon(Icons.access_time),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _endTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null) {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_endTime),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _endTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Update Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
