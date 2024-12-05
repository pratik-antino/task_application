import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleMeetService {
  final String baseUrl = 'https://your-backend-url.com/api';

  Future<String> scheduleMeeting(String token, String eventId, List<String> participants) async {
    final response = await http.post(
      Uri.parse('$baseUrl/meetings/schedule'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'eventId': eventId,
        'participants': participants,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['meetingLink'];
    } else {
      throw Exception('Failed to schedule meeting');
    }
  }

  Future<void> shareMeeting(String token, String meetingLink, List<String> participants) async {
    final response = await http.post(
      Uri.parse('$baseUrl/meetings/share'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'meetingLink': meetingLink,
        'participants': participants,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to share meeting');
    }
  }

  Future<void> inviteParticipants(String token, String meetingLink, List<String> participants) async {
    final response = await http.post(
      Uri.parse('$baseUrl/meetings/invite'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'meetingLink': meetingLink,
        'participants': participants,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to invite participants');
    }
  }

  Future<List<dynamic>> viewCalendar(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/meetings/calendar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to view calendar');
    }
  }

  Future<void> syncWithCalendar(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/meetings/sync'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to sync with calendar');
    }
  }

  String generateMeetingLink() {
    // This is a simplified version. In a real-world scenario, you'd generate a unique link
    return 'https://meet.google.com/' + DateTime.now().millisecondsSinceEpoch.toString();
  }
}

