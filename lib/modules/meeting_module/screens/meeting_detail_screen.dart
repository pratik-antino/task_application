import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:task_application/core/helper_function.dart';
import 'package:task_application/modules/meeting_module/models/meeting_model.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetingDetailScreen extends StatelessWidget {
  final Meeting meeting;

  const MeetingDetailScreen({super.key, required this.meeting});

  Future<void> _joinMeeting() async {
    try {
      if (await canLaunch(meeting.meetLink)) {
        await launch(meeting.meetLink);
      } else {
        print('Could not launch ${meeting.meetLink}');
      }
    } catch (e) {
      log(e.toString());
    }
  }

  void _shareMeetingLink() {
    HelperFunction.shareContent(meeting.meetLink);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meeting.summary,
              style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 19),
            ),
            const SizedBox(height: 8),
            const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(meeting.description),
            const SizedBox(height: 16),
            Text(
                style: const TextStyle(fontWeight: FontWeight.bold),
                'Start Time: ${DateFormat('dd-MM-yy HH:mm').format(meeting.startTime)}'),
            const SizedBox(height: 10),
            Text(
                style: const TextStyle(fontWeight: FontWeight.bold),
                'End Time: ${DateFormat('dd-MM-yy HH:mm').format(meeting.endTime)}'),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: ElevatedButton(
                    onPressed: _joinMeeting,
                    child: const Text('Join Meeting'),
                  ),
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: _shareMeetingLink,
                    child: const Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
