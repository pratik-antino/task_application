import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/cubits/auth_cubit.dart';
import '../../cubits/calendar_cubit.dart';
import 'cubits/event_cubit.dart';
import '../../models/event.dart';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../auth/cubits/auth_cubit.dart';
import 'cubits/event_cubit.dart';
import '../../cubits/calendar_cubit.dart';

class CalendarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        // Ensure the token is available in AuthAuthenticated state
        if (authState is AuthAuthenticated) {
          final token = authState.token;

          return BlocBuilder<EventCubit, EventState>(
            builder: (context, eventState) {
              if (eventState is EventInitial) {
                context.read<EventCubit>().fetchEvents(token);
                return Center(child: CircularProgressIndicator());
              } else if (eventState is EventLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (eventState is EventLoaded) {
                return BlocProvider(
                  create: (context) => CalendarCubit(),
                  child: CalendarView(events: eventState.events),
                );
              } else if (eventState is EventError) {
                return Center(child: Text(eventState.message));
              } else {
                return Center(child: Text('Unknown state'));
              }
            },
          );
        } else {
          // If not authenticated, show a message or navigate to login
          return Center(
            child: Text('Please log in to view the calendar.'),
          );
        }
      },
    );
  }
}

class CalendarView extends StatelessWidget {
  final List<Event> events;

  const CalendarView({required this.events});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarState>(
      builder: (context, state) {
        if (state is CalendarDayView) {
          return _buildDayView(context, state);
        } else if (state is CalendarWeekView) {
          return _buildWeekView(context, state);
        } else if (state is CalendarMonthView) {
          return _buildMonthView(context, state);
        } else {
          // Default to month view
          context.read<CalendarCubit>().viewMonth(DateTime.now(), events);
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildDayView(BuildContext context, CalendarDayView state) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Day View: ${DateFormat('yyyy-MM-dd').format(state.day)}'),
      ),
      body: ListView.builder(
        itemCount: state.events.length,
        itemBuilder: (context, index) {
          final event = state.events[index];
          return ListTile(
            title: Text(event.title),
            subtitle: Text(
              '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}',
            ),
          );
        },
      ),
    );
  }

  Widget _buildWeekView(BuildContext context, CalendarWeekView state) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Week View: ${DateFormat('yyyy-MM-dd').format(state.startOfWeek)}'),
      ),
      body: ListView.builder(
        itemCount: 7,
        itemBuilder: (context, index) {
          final day = state.startOfWeek.add(Duration(days: index));
          final dayEvents = state.events
              .where((event) =>
                  event.startTime.year == day.year &&
                  event.startTime.month == day.month &&
                  event.startTime.day == day.day)
              .toList();
          return ExpansionTile(
            title: Text(DateFormat('E, MMM d').format(day)),
            children: dayEvents.map((event) {
              return ListTile(
                title: Text(event.title),
                subtitle: Text(
                  '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}',
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildMonthView(BuildContext context, CalendarMonthView state) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Month View: ${DateFormat('MMMM yyyy').format(state.month)}'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
        ),
        itemCount: DateTime(state.month.year, state.month.month + 1, 0).day,
        itemBuilder: (context, index) {
          final day = DateTime(state.month.year, state.month.month, index + 1);
          final dayEvents = state.events
              .where((event) =>
                  event.startTime.year == day.year &&
                  event.startTime.month == day.month &&
                  event.startTime.day == day.day)
              .toList();
          return InkWell(
            onTap: () => context.read<CalendarCubit>().viewDay(day, events),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${index + 1}'),
                  if (dayEvents.isNotEmpty)
                    const SizedBox(
                      height: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 4,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
