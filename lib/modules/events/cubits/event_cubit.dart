import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:task_application/modules/task/model/comment_model.dart';
import 'dart:convert';
import '../event.dart';
part 'event_state.dart';

class EventCubit extends Cubit<EventState> {
  EventCubit() : super(EventInitial());

  final String baseUrl =
      'https://d638-121-243-82-214.ngrok-free.app/api'; // Replace with your actual backend URL

  Future<void> fetchEvents(String token) async {
    emit(EventLoading());
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> eventsJson = json.decode(response.body);
        final events = eventsJson.map((json) => Event.fromJson(json)).toList();
        emit(EventLoaded(events));
      } else {
        emit(EventError('Failed to load events'));
      }
    } catch (error) {
      emit(EventError('An error occurred. Please try again.'));
    }
  }

  Future<void> addEvent(Event event, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(event.toJson()),
      );

      if (response.statusCode == 201) {
        fetchEvents(token);
      } else {
        // emit(EventError('Failed to add event'));
      }
    } catch (error) {
      // emit(EventError('An error occurred. Please try again.'));
    }
  }

  Future<void> updateEvent(Event event, String token) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/events/${event.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(event.toJson()),
      );

      if (response.statusCode == 200) {
        fetchEvents(token);
      } else {
        emit(EventError('Failed to update event'));
      }
    } catch (error) {
      // emit(EventError('An error occurred. Please try again.'));
    }
  }

  Future<void> deleteEvent(String eventId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/events/$eventId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        fetchEvents(token);
      } else {
        emit(EventError('Failed to delete event'));
      }
    } catch (error) {
      emit(EventError('An error occurred. Please try again.'));
    }
  }

  Future<void> shareCalendar(
      String userId, String sharedWithUserId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events/share'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'userId': userId,
          'sharedWithUserId': sharedWithUserId,
        }),
      );

      if (response.statusCode == 200) {
        fetchEvents(token);
      } else {
        emit(EventError('Failed to share calendar'));
      }
    } catch (error) {
      emit(EventError('An error occurred. Please try again.'));
    }
  }

  Future<void> unshareCalendar(
      String userId, String sharedWithUserId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/events/unshare'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'userId': userId,
          'sharedWithUserId': sharedWithUserId,
        }),
      );

      if (response.statusCode == 200) {
        // fetchEvents(token);
      } else {
        emit(EventError('Failed to unshare calendar'));
      }
    } catch (error) {
      emit(EventError('An error occurred. Please try again.'));
    }
  }

  // Fetch comments for a specific event
  Future<void> fetchComments(String eventId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/events/$eventId/comments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> commentsJson = json.decode(response.body);
        final comments =
            commentsJson.map((json) => Comment.fromJson(json)).toList();
      } else {
        emit(EventError('Failed to load comments'));
      }
    } catch (error) {
      emit(EventError('An error occurred while fetching comments.'));
    }
  }

  // Add a comment to an event
  Future<void> addComment(String eventId, String content, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/event/comments/$eventId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'content': content}),
      );

      if (response.statusCode == 201) {
        // fetchComments(eventId, token); // Fetch the updated comments
      } else {
        emit(EventError('Failed to add comment'));
      }
    } catch (error) {
      emit(EventError('An error occurred while adding comment.'));
    }
  }

  // Delete a comment
  Future<void> deleteComment(String commentId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/events/comments/$commentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // emit(CommentDeleted());
      } else {
        emit(EventError('Failed to delete comment'));
      }
    } catch (error) {
      emit(EventError('An error occurred while deleting comment.'));
    }
  }
}
