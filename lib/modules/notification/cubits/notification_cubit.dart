import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../models/notification.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  final String baseUrl = 'http://10.0.2.2:5000/api'; // Replace with your actual backend URL

  Future<void> fetchNotifications(String token) async {
    emit(NotificationLoading());
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> notificationsJson = json.decode(response.body);
        final notifications = notificationsJson.map((json) => Notification.fromJson(json)).toList();
        emit(NotificationLoaded(notifications));
      } else {
        emit(NotificationError('Failed to load notifications'));
      }
    } catch (error) {
      emit(NotificationError('An error occurred. Please try again.'));
    }
  }

  Future<void> markAsRead(String notificationId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        fetchNotifications(token);
      } else {
        emit(NotificationError('Failed to mark notification as read'));
      }
    } catch (error) {
      emit(NotificationError('An error occurred. Please try again.'));
    }
  }
}

