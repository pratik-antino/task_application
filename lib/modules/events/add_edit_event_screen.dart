import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_application/modules/auth/cubits/auth_cubit.dart';
import 'package:task_application/modules/events/cubits/event_cubit.dart';
import '../../../models/event.dart';

class AddEventScreen extends StatefulWidget {
  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(Duration(hours: 1));
  List<String> _participants = [];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        final event = Event(
          id: '',
          title: _title,
          description: _description,
          startTime: _startTime,
          endTime: _endTime,
          participants: _participants,
          ownerId: authState.userId,
          sharedWith: [],
        );

        context.read<EventCubit>().addEvent(event, authState.token);
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication error. Please log in again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Event'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => _description = value!,
              ),
              ListTile(
                title: Text('Start Time'),
                subtitle: Text(_startTime.toString()),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context, isStartTime: true),
              ),
              ListTile(
                title: Text('End Time'),
                subtitle: Text(_endTime.toString()),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context, isStartTime: false),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Participants (comma-separated emails)'),
                onSaved: (value) => _participants = value!.split(',').map((e) => e.trim()).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Add Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context, {required bool isStartTime}) async {
    final currentDate = isStartTime ? _startTime : _endTime;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentDate),
      );

      if (selectedTime != null) {
        setState(() {
          if (isStartTime) {
            _startTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );
          } else {
            _endTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              selectedTime.hour,
              selectedTime.minute,
            );
          }
        });
      }
    }
  }
}
