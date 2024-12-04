import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_application/models/event.dart';
import 'package:task_application/modules/auth/cubits/auth_cubit.dart';

class AddEditEventScreen extends StatefulWidget {
  final Event? event;
  final DateTime? selectedDate;

  AddEditEventScreen({this.event, this.selectedDate});

  @override
  _AddEditEventScreenState createState() => _AddEditEventScreenState();
}

class _AddEditEventScreenState extends State<AddEditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(Duration(hours: 1));

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _title = widget.event!.title;
      _description = widget.event!.description;
      _startTime = widget.event!.startTime;
      _endTime = widget.event!.endTime;
    } else if (widget.selectedDate != null) {
      _startTime = widget.selectedDate!;
      _endTime = widget.selectedDate!.add(Duration(hours: 1));
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final event = Event(
        ownerId: '',
        sharedWith: [''],
        id: widget.event?.id ?? '',
        title: _title,
        description: _description,
        createdBy: Provider.of<AuthCubit>(context, listen: false).state,
        startTime: _startTime,
        endTime: _endTime,
        participants: [],
      );

      if (widget.event == null) {
     
      } else {
      
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Add Event' : 'Edit Event'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Title'),
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
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => _description = value!,
              ),
              ListTile(
                title: Text('Start Time'),
                subtitle: Text(_startTime.toString()),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _startTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
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
                title: Text('End Time'),
                subtitle: Text(_endTime.toString()),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _endTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
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
              SizedBox(height: 20),
              ElevatedButton(
                child: Text(widget.event == null ? 'Add Event' : 'Update Event'),
                onPressed: _submitForm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

