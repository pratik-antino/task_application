part of 'meeting_cubit.dart';

abstract class MeetingState {}

class MeetingInitial extends MeetingState {}

class MeetingLoading extends MeetingState {}

class MeetingScheduled extends MeetingState {
  final String meetingLink;

  MeetingScheduled(this.meetingLink);
}

class MeetingJoined extends MeetingState {
  final String meetingLink;

  MeetingJoined(this.meetingLink);
}

class MeetingError extends MeetingState {
  final String message;

  MeetingError(this.message);
}

