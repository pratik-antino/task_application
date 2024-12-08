part of 'calendar_cubit.dart';

abstract class CalendarState {}

class CalendarInitial extends CalendarState {}

class CalendarDayView extends CalendarState {
  final DateTime day;
  final List<Event> events;

  CalendarDayView(this.day, this.events);
}

class CalendarWeekView extends CalendarState {
  final DateTime startOfWeek;
  final List<Event> events;

  CalendarWeekView(this.startOfWeek, this.events);
}

class CalendarMonthView extends CalendarState {
  final DateTime month;
  final List<Event> events;

  CalendarMonthView(this.month, this.events);
}

