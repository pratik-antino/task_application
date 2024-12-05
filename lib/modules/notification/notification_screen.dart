import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubits/notification_cubit.dart';
import '../auth/cubits/auth_cubit.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<NotificationCubit>().fetchNotifications(authState.token);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationLoaded) {
            return ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return ListTile(
                  title: Text(notification.title),
                  subtitle: Text(notification.message),
                  trailing: Text(notification.timestamp.toString()),
                  leading: Icon(_getNotificationIcon(notification.type)),
                  onTap: () {
                    if (!notification.isRead && authState is AuthAuthenticated) {
                      context.read<NotificationCubit>().markAsRead(notification.id, authState.token);
                    }
                    // Navigate to the relevant screen based on the notification type
                  },
                );
              },
            );
          } else if (state is NotificationError) {
            return Center(child: Text(state.message));
          } else {
            return const Center(child: Text('No notifications'));
          }
        },
      ),
    );
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'task':
        return Icons.assignment;
      case 'meeting':
        return Icons.video_call;
      case 'event':
        return Icons.event;
      default:
        return Icons.notifications;
    }
  }
}

