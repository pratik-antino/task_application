import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:task_application/core/config/toast_util.dart';
import 'package:task_application/modules/events/event.dart';
import 'package:task_application/modules/auth/cubits/auth_cubit.dart';
import 'package:task_application/modules/events/add_event_screen.dart';
import 'package:task_application/modules/events/cubits/event_cubit.dart';
import 'package:task_application/modules/events/screens/event_detail_screen.dart';
import 'package:intl/intl.dart';

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
    context.read<EventCubit>().fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;

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
          } else if (state is EventLoaded && authState is AuthAuthenticated) {
            // Filter events for participants or owner
            final userId = authState.userId;
            final userEvents = state.events
                .where((event) =>
                    event.ownerId == userId ||
                    event.participants.contains(userId))
                .toList();

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
                    return userEvents
                        .where((event) => isSameDay(event.startTime, day))
                        .toList();
                  },
                ),
                Expanded(
                  child: _buildEventList(userEvents, authState.token),
                ),
              ],
            );
          } else if (state is EventError) {
            ToastUtil.showAPIErrorToast(message: state.message);
          } else {
            return Container();
          }
          return Container();
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _addEvent(context),
      ),
    );
  }

  Widget _buildEventList(List<Event> events, String token) {
    final authState = context.read<AuthCubit>().state;
    if (authState is! AuthAuthenticated) return Container();

    final userId = authState.userId;
    final eventsOnSelectedDay = events
        .where((event) => isSameDay(event.startTime, _selectedDay))
        .toList();

    if (eventsOnSelectedDay.isEmpty) {
      return const Center(child: Text('No events on this day.'));
    }

    return ListView.builder(
      itemCount: eventsOnSelectedDay.length,
      itemBuilder: (context, index) {
        final event = eventsOnSelectedDay[index];
        final isCreator = event.ownerId == userId;

        return Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: ListTile(
            title: Text(event.title),
            subtitle: Text(
                '${DateFormat('dd-MM-yy HH:mm').format(event.startTime)} - ${DateFormat('dd-MM-yy HH:mm').format(event.endTime)}'),
            onTap: () =>
                isCreator ? _editEvent(context, event, authState.token) : null,
            trailing: isCreator
                ? const Icon(Icons.edit, color: Colors.blue)
                : const Icon(Icons.visibility, color: Colors.grey),
          ),
        );
      },
    );
  }

  void _addEvent(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const AddEventScreen()),
    );
  }

  void _editEvent(BuildContext context, Event event, String token) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => EventDetailScreen(
                event: event,
                token: token,
              )),
    );
  }
}
