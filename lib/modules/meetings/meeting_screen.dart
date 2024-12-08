import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_application/modules/auth/cubits/auth_cubit.dart';
import 'package:task_application/modules/meetings/google_meet_service.dart';

class GoogleMeetScreen extends StatefulWidget {
  @override
  _GoogleMeetScreenState createState() => _GoogleMeetScreenState();
}

class _GoogleMeetScreenState extends State<GoogleMeetScreen> {
  final GoogleMeetService _googleMeetService = GoogleMeetService();
  String? _meetingLink;
  List<dynamic> _calendarEvents = [];

  @override
  void initState() {
    super.initState();
    _fetchCalendar();
  }

  Future<void> _fetchCalendar() async {
    final token = (context.read<AuthCubit>().state as AuthAuthenticated).token;
    try {
      final events = await _googleMeetService.viewCalendar(token);
      setState(() {
        _calendarEvents = events;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch calendar events')),
      );
    }
  }

  Future<void> _scheduleMeeting() async {
    final token = (context.read<AuthCubit>().state as AuthAuthenticated).token;
    try {
      final meetingLink = await _googleMeetService.scheduleMeeting(token, 'eventId', ['participant1@example.com', 'participant2@example.com']);
      setState(() {
        _meetingLink = meetingLink;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to schedule meeting')),
      );
    }
  }

  Future<void> _syncCalendar() async {
    final token = (context.read<AuthCubit>().state as AuthAuthenticated).token;
    try {
      await _googleMeetService.syncWithCalendar(token);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Calendar synced successfully')),
      );
      _fetchCalendar();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sync calendar')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Meet Integration'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: _scheduleMeeting,
              child: Text('Schedule Meeting'),
            ),
            if (_meetingLink != null) ...[
              SizedBox(height: 16),
              Text('Meeting Link: $_meetingLink'),
            ],
            SizedBox(height: 32),
            Text('Calendar Events:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: _calendarEvents.length,
                itemBuilder: (context, index) {
                  final event = _calendarEvents[index];
                  return ListTile(
                    title: Text(event['title']),
                    subtitle: Text('${event['startTime']} - ${event['endTime']}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _syncCalendar,
              child: Text('Sync Calendar'),
            ),
          ],
        ),
      ),
    );
  }
}

