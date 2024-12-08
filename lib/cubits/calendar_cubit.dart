import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/event.dart';

part 'calendar_state.dart';

class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit() : super(CalendarInitial());

  void viewDay(DateTime day, List<Event> events) {
    final dayEvents = events.where((event) =>
        event.startTime.year == day.year &&
        event.startTime.month == day.month &&
        event.startTime.day == day.day).toList();
    emit(CalendarDayView(day, dayEvents));
  }

  void viewWeek(DateTime startOfWeek, List<Event> events) {
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    final weekEvents = events.where((event) =>
        event.startTime.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        event.startTime.isBefore(endOfWeek.add(const Duration(days: 1)))).toList();
    emit(CalendarWeekView(startOfWeek, weekEvents));
  }

  void viewMonth(DateTime month, List<Event> events) {
    final startOfMonth = DateTime(month.year, month.month, 1);
    final endOfMonth = DateTime(month.year, month.month + 1, 0);
    final monthEvents = events.where((event) =>
        event.startTime.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
        event.startTime.isBefore(endOfMonth.add(const Duration(days: 1)))).toList();
    emit(CalendarMonthView(month, monthEvents));
  }
}

