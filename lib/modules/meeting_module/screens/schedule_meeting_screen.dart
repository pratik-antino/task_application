import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/calendar/v3.dart' as api;
import 'package:intl/intl.dart';
import 'package:task_application/modules/auth/cubits/auth_cubit.dart';
import 'package:task_application/modules/auth/cubits/user_cubit.dart';
import 'package:task_application/modules/auth/cubits/user_state.dart';

class ScheduleMeetingScreen extends StatefulWidget {
  final api.CalendarApi calendarApi;

  const ScheduleMeetingScreen({Key? key, required this.calendarApi})
      : super(key: key);

  @override
  _ScheduleMeetingScreenState createState() => _ScheduleMeetingScreenState();
}

class _ScheduleMeetingScreenState extends State<ScheduleMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _startDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  DateTime _endDate = DateTime.now().add(Duration(hours: 1));
  late TimeOfDay _endTime;
  List<String> _attendees = [];
  bool _selectAll = false;
  final TextEditingController _emailController = TextEditingController();
  @override
  void initState() {
    super.initState();
    TimeOfDay currentTime = TimeOfDay.now();

    // Convert current TimeOfDay to DateTime
    DateTime now = DateTime(0, 0, 0, currentTime.hour, currentTime.minute);

    // Add one hour to the DateTime object
    DateTime newTime = now.add(Duration(hours: 1));

    // Convert the DateTime back to TimeOfDay
    _endTime = TimeOfDay(hour: newTime.hour, minute: newTime.minute);
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<UserCubit>().fetchUsers(authState.token);
    }
  }
  

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _addAttendee(String email) {
    setState(() {
      _attendees.add(email);
    });
    log(_attendees.toList().toString());
  }

  Future<void> _scheduleMeeting() async {
    if (_formKey.currentState!.validate()) {
      final event = api.Event(
        summary: _titleController.text,
        description: _descriptionController.text,
        start: api.EventDateTime(
          dateTime: DateTime(
            _startDate.year,
            _startDate.month,
            _startDate.day,
            _startTime.hour,
            _startTime.minute,
          ),
        ),
        end: api.EventDateTime(
          dateTime: DateTime(
            _endDate.year,
            _endDate.month,
            _endDate.day,
            _endTime.hour,
            _endTime.minute,
          ),
        ),
        attendees:
            _attendees.map((email) => api.EventAttendee(email: email)).toList(),
        conferenceData: api.ConferenceData(
          createRequest: api.CreateConferenceRequest(
            requestId:
                "${DateTime.now().millisecondsSinceEpoch}-${_titleController.text}",
            conferenceSolutionKey:
                api.ConferenceSolutionKey(type: 'hangoutsMeet'),
          ),
        ),
      );

      try {
        final createdEvent = await widget.calendarApi.events.insert(
          event,
          'primary',
          conferenceDataVersion: 1,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Meeting scheduled successfully!')),
        );
        Navigator.pop(context, createdEvent);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to schedule meeting: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Schedule Meeting')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Meeting Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                SizedBox(height: 16),
                Text('Start Date and Time'),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => _selectDate(context, true),
                        child:
                            Text(DateFormat('yyyy-MM-dd').format(_startDate)),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => _selectTime(context, true),
                        child: Text(_startTime.format(context)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text('End Date and Time'),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => _selectDate(context, false),
                        child: Text(DateFormat('yyyy-MM-dd').format(_endDate)),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => _selectTime(context, false),
                        child: Text(_endTime.format(context)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                BlocBuilder<UserCubit, UserState>(
                  builder: (context, state) {
                  if (state is UserLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is UserLoaded) {
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CheckboxListTile(
                            title: const Text('Select All Users'),
                            value: _selectAll,
                            onChanged: (value) {
                              setState(() {
                                _selectAll = value!;
                                if (_selectAll) {
                                  _attendees = state.users
                                      .map((user) => user.email)
                                      .toList();
                                } else {
                                  _attendees.clear();
                                }
                              });
                            },
                          ),
                          Wrap(
                            children: state.users.map((user) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: FilterChip(
                                  label: Text(user.name),
                                  selected: _attendees.contains(user.id),
                                  onSelected: (isSelected) {
                                    setState(() {
                                      if (isSelected) {
                                        _attendees.add(user.email);
                                      } else {
                                        _attendees.remove(user.email);
                                        _selectAll =
                                            false; // Uncheck "Select All" if deselected
                                      }
                                    });
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ]);
                  }
                   else if (state is UserError) {
                    return Text('Error loading users: ${state.message}');
                  }
                  return const SizedBox();
                
                }
                ),
                Text('Attendees'),
                ..._attendees.map((email) => Chip(label: Text(email))).toList(),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        decoration:
                            InputDecoration(labelText: 'Add Attendee Email'),
                        onFieldSubmitted: (value) {
                          if (value.isNotEmpty) {
                            // _addAttendee(value);
                          }
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        final email = _emailController.value.text;
                        if (email.isNotEmpty) {
                          _addAttendee(email);
                          _emailController.clear();
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _scheduleMeeting,
                    child: Text('Schedule Meeting'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
