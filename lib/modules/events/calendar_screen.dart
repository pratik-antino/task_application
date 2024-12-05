import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:task_application/models/event.dart';
import 'package:task_application/modules/auth/cubits/auth_cubit.dart';
import 'package:task_application/modules/events/add_edit_event_screen.dart';
import 'package:task_application/modules/events/cubits/event_cubit.dart';
import 'package:task_application/modules/events/edit_event_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<EventCubit>().fetchEvents(authState.token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      body: BlocConsumer<EventCubit, EventState>(
        listener: (context, state) {
          if (state is EventError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is EventInitial || state is EventLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is EventLoaded) {
            return Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2030, 3, 14),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  eventLoader: (day) {
                    return state.events
                        .where((event) => isSameDay(event.startTime, day))
                        .toList();
                  },
                ),
                Expanded(
                  child: _buildEventList(state.events),
                ),
              ],
            );
          } else {
            return const Center(child: Text('An error occurred'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _addEvent(context),
      ),
    );
  }

  Widget _buildEventList(List<Event> events) {
    final eventsOnSelectedDay = events
        .where((event) => isSameDay(event.startTime, _selectedDay))
        .toList();

    if (eventsOnSelectedDay.isEmpty) {
      return const Center(child: Text('No events on this day.'));
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: eventsOnSelectedDay.length,
            itemBuilder: (context, index) {
              final event = eventsOnSelectedDay[index];
              return Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ListTile(
                  title: Text(event.title),
                  subtitle: Text(
                      '${event.startTime.toString()} - ${event.endTime.toString()}'),
                  onTap: () => _editEvent(context, event),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _addEvent(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddEventScreen()),
    );
  }

  void _editEvent(BuildContext context, Event event) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => AddEditEventScreen(
                event: event,
              )),
    );
  }
}
