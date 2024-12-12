import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_application/core/extensions/common_extension.dart';
import 'package:task_application/modules/events/event_repo/event_repository.dart';
import '../event.dart';
part 'event_state.dart';

class EventCubit extends Cubit<EventState> {
  final EventRepository _eventRepo = EventRepository();
  EventCubit() : super(EventInitial());

  Future<void> fetchEvents() async {
    emit(EventLoading());

    try {
      final response = await _eventRepo.fetchEvents();
      final List<Event> _fetchedEvents = [];
      for (var event in response) {
        _fetchedEvents.add(Event.fromJson(event));
      }
      emit(EventLoaded(_fetchedEvents));
    } catch (error) {
      emit(EventError('An error occurred. Please try again.'));
    }
  }

  Future<void> addEvent(Event event) async {
    try {
      final response = await _eventRepo.addEvent(event);
      fetchEvents();
    } catch (error) {
      emit(EventError(
          error.getErrorMessage ?? 'An error occurred. Please try again.'));
    }
  }

  Future<void> updateEvent(Event event) async {
    try {
      final response = await _eventRepo.updateEvent(event);

      fetchEvents();
    } catch (error) {
      emit(EventError(
          error.getErrorMessage ?? 'An error occurred. Please try again.'));
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      final response = await _eventRepo.deleteEvent(eventId);
      fetchEvents();
    } catch (error) {
      emit(EventError('An error occurred. Please try again.'));
    }
  }

  // Future<void> werw(
  //     String userId, String sharedWithUserId, String token) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/events/share'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: json.encode({
  //         'userId': userId,
  //         'sharedWithUserId': sharedWithUserId,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       fetchEvents(token);
  //     } else {
  //       emit(EventError('Failed to share calendar'));
  //     }
  //   } catch (error) {
  //     emit(EventError('An error occurred. Please try again.'));
  //   }
  // }

  // Future<void> unshareCalendar(
  //     String userId, String sharedWithUserId, String token) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse('$baseUrl/events/unshare'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: json.encode({
  //         'userId': userId,
  //         'sharedWithUserId': sharedWithUserId,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       // fetchEvents(token);
  //     } else {
  //       emit(EventError('Failed to unshare calendar'));
  //     }
  //   } catch (error) {
  //     emit(EventError('An error occurred. Please try again.'));
  //   }
  // }

  // Fetch comments for a specific event
  // Future<void> fetchComments(String eventId, String token) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/events/$eventId/comments'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       final List<dynamic> commentsJson = json.decode(response.body);
  //       final comments =
  //           commentsJson.map((json) => Comment.fromJson(json)).toList();
  //     } else {
  //       emit(EventError('Failed to load comments'));
  //     }
  //   } catch (error) {
  //     emit(EventError('An error occurred while fetching comments.'));
  //   }
  // }

  // Add a comment to an event
  Future<void> addComment(String eventId, String comment) async {
    try {
      final response = _eventRepo.addEventComment(comment, eventId);
      // fetchComments(eventId, token);
      // Fetch the updated comments
      fetchEvents();
    } catch (error) {
      emit(EventError(
          error.getErrorMessage ?? 'An error occurred while adding comment.'));
    }
  }

  // Delete a comment
  // Future<void> deleteComment(String commentId, String token) async {
  //   try {
  //     final response = await http.delete(
  //       Uri.parse('$baseUrl/events/comments/$commentId'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       // emit(CommentDeleted());
  //     } else {
  //       emit(EventError('Failed to delete comment'));
  //     }
  //   } catch (error) {
  //     emit(EventError('An error occurred while deleting comment.'));
  //   }
  // }
}
