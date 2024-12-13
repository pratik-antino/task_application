import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_application/modules/events/cubits/meeting_cubit.dart';
import '../cubits/event_cubit.dart';
import '../../auth/cubits/auth_cubit.dart';
import '../../../cubits/audio_command_cubit.dart';
import '../event.dart';

class ScheduleEventScreen extends StatefulWidget {
  const ScheduleEventScreen({super.key});

  @override
  _ScheduleEventScreenState createState() => _ScheduleEventScreenState();
}

class _ScheduleEventScreenState extends State<ScheduleEventScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime _startTime = DateTime.now();
  DateTime _endTime = DateTime.now().add(const Duration(hours: 1));
  final List<String> _participants = [];
  bool _isGoogleMeetEnabled = false;

  @override
  void initState() {
    super.initState();
    context.read<AudioCommandCubit>().initializeSpeech();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final event = Event(
        id: '',
        title: _title,
        description: _description,
        startTime: _startTime,
        endTime: _endTime,
        participants: _participants,
        ownerId: '',
        sharedWith: [],
      );
      final authState = context.read<AuthCubit>().state;
      if (authState is AuthAuthenticated) {
        context.read<EventCubit>().addEvent(event, authState.token);
        if (_isGoogleMeetEnabled) {
          context.read<MeetingCubit>().scheduleMeeting(event.id, _participants, authState.token);
        }
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
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
              ListTile(
                title: const Text('Start Time'),
                subtitle: Text(_startTime.toString()),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_startTime),
                    );
                    if (time != null) {
                      setState(() {
                        _startTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
              ListTile(
                title: const Text('End Time'),
                subtitle: Text(_endTime.toString()),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _endTime,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_endTime),
                    );
                    if (time != null) {
                      setState(() {
                        _endTime = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Enable Google Meet'),
                value: _isGoogleMeetEnabled,
                onChanged: (value) {
                  setState(() {
                    _isGoogleMeetEnabled = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Schedule Event'),
              ),
              const SizedBox(height: 20),
              BlocConsumer<AudioCommandCubit, AudioCommandState>(
                listener: (context, state) {
                  if (state is AudioCommandResult) {
                    setState(() {
                      _title = state.text;
                    });
                  }
                },
                builder: (context, state) {
                  if (state is AudioCommandReady) {
                    return ElevatedButton(
                      child: const Text('Schedule Event by Voice'),
                      onPressed: () {
                        context.read<AudioCommandCubit>().startListening();
                      },
                    );
                  } else if (state is AudioCommandListening) {
                    return ElevatedButton(
                      child: const Text('Stop Listening'),
                      onPressed: () {
                        context.read<AudioCommandCubit>().stopListening();
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
