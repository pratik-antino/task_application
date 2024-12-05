import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part './meeting_state.dart';

class MeetingCubit extends Cubit<MeetingState> {
  MeetingCubit() : super(MeetingInitial());

  final String baseUrl = 'http://10.0.2.2:5000/api'; // Replace with your actual backend URL

  Future<void> scheduleMeeting(String eventId, List<String> participants, String token) async {
    emit(MeetingLoading());
    try {
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
        final meetingData = json.decode(response.body);
        emit(MeetingScheduled(meetingData['meetingLink']));
      } else {
        emit(MeetingError('Failed to schedule meeting'));
      }
    } catch (error) {
      emit(MeetingError('An error occurred. Please try again.'));
    }
  }

  Future<void> joinMeeting(String meetingLink) async {
    try {
      // Implement logic to join the meeting using the meetingLink
      // This might involve launching a web view or a native Google Meet integration
      // For this example, we'll just emit a state indicating the meeting is joined
      emit(MeetingJoined(meetingLink));
    } catch (error) {
      emit(MeetingError('Failed to join meeting'));
    }
  }
}

