import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_application/modules/auth/cubits/auth_cubit.dart';
import 'package:task_application/modules/auth/cubits/user_cubit.dart';
import 'package:task_application/modules/auth/cubits/user_state.dart';
import 'package:task_application/modules/events/cubits/event_cubit.dart';
import 'event.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  _AddEventScreenState createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));
  List<String> _participants = [];
  bool _selectAll = false;

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
        final event = Event(
          id: '',
          title: _title,
          description: _description,
          startTime: _startTime,
          endTime: _endTime,
          participants: _participants,
          ownerId: authState.userId,
          sharedWith: _participants,
        );

        context.read<EventCubit>().addEvent(event, authState.token);
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
        title: const Text('Add Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a title' : null,
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => _description = value!,
              ),
              ListTile(
                title: const Text('Start Time'),
                subtitle: Text(_startTime.toString()),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context, isStartTime: true),
              ),
              ListTile(
                title: const Text('End Time'),
                subtitle: Text(_endTime.toString()),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context, isStartTime: false),
              ),
            
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
                                _participants = state.users.map((user) => user.id).toList();
                              } else {
                                _participants.clear();
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
                                selected: _participants.contains(user.id),
                                onSelected: (isSelected) {
                                  setState(() {
                                    if (isSelected) {
                                      _participants.add(user.id);
                                    } else {
                                      _participants.remove(user.id);
                                      _selectAll = false; // Uncheck "Select All" if deselected
                                    }
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  } else if (state is UserError) {
                    return Text('Error loading users: ${state.message}');
                  }
                  return const SizedBox();
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Add Event'),
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
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentDate),
      );

      if (selectedTime != null) {
        final updatedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        setState(() {
          if (isStartTime) {
            _startTime = updatedDateTime;
            if (_endTime.isBefore(_startTime)) {
              _endTime = _startTime.add(const Duration(hours: 1));
            }
          } else {
            _endTime = updatedDateTime;
            if (_endTime.isBefore(_startTime)) {
              _startTime = _endTime.subtract(const Duration(hours: 1));
            }
          }
        });
      }
    }
  }
}
