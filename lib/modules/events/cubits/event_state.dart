part of 'event_cubit.dart';

abstract class EventState {}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventLoaded extends EventState {
  final List<Event> events;
  EventLoaded(this.events);
}

class EventError extends EventState {
  final String message;

  EventError(this.message);
}

