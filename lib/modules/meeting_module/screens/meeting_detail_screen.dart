import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:task_application/modules/meeting_module/models/meeting_model.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetingDetailScreen extends StatelessWidget {
  final Meeting meeting;

  const MeetingDetailScreen({Key? key, required this.meeting}) : super(key: key);

  Future<void> _joinMeeting() async {
    try{
    if (await canLaunch(meeting.meetLink)) {
      await launch(meeting.meetLink);
    } else {
      print('Could not launch ${meeting.meetLink}');
    }
    }catch(e){
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meeting Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meeting.summary
            ),
            SizedBox(height: 8),
            Text(
              'Description:'
            ),
            Text(meeting.description),
            SizedBox(height: 16),
            Text(
              'Start Time: ${meeting.startTime}'
            ),
            Text(
              'End Time: ${meeting.endTime}'
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _joinMeeting,
                child: Text('Join Meeting'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

