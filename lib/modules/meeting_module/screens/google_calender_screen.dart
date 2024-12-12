import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as api;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'package:task_application/modules/meeting_module/models/meeting_model.dart';
import 'package:task_application/modules/meeting_module/screens/schedule_meeting_screen.dart';
import 'meeting_detail_screen.dart';
import 'package:intl/intl.dart';

class GoogleCalendarScreen extends StatefulWidget {
  @override
  _GoogleCalendarScreenState createState() => _GoogleCalendarScreenState();
}

class _GoogleCalendarScreenState extends State<GoogleCalendarScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [api.CalendarApi.calendarScope],
  );
  GoogleSignInAccount? _currentUser;
  auth.AuthClient? _authClient;
  api.CalendarApi? _calendarApi;
  List<Meeting> _meetings = [];

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        await _createAuthClient(_currentUser!);
        _fetchMeetings();
      } else {
        _authClient = null;
        _calendarApi = null;
        _meetings = [];
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<void> _createAuthClient(GoogleSignInAccount account) async {
    final authentication = await account.authentication;
    final accessToken = authentication.accessToken;

    if (accessToken == null) {
      print("Error: Access Token is null");
      return;
    }

    try {
      final credentials = auth.AccessCredentials(
        auth.AccessToken(
          'Bearer',
          accessToken,
          DateTime.now().toUtc().add(Duration(hours: 1)),
        ),
        null,
        [api.CalendarApi.calendarScope],
      );

      _authClient = auth.authenticatedClient(http.Client(), credentials);
      _calendarApi = api.CalendarApi(_authClient!);
    } catch (e) {
      print('Error creating auth client: ${e.toString()}');
    }
  }

  Future<void> _fetchMeetings() async {
    if (_calendarApi == null) return;

    try {
      final events = await _calendarApi!.events.list(
        'primary',
        timeMin: DateTime.now().toUtc(),
        singleEvents: true,
        orderBy: 'startTime',
      );

      setState(() {
        _meetings = events.items
                ?.where((event) => event.hangoutLink != null)
                .map((event) => Meeting.fromEvent(event))
                .toList() ??
            [];
      });
    } catch (e) {
      print('Error fetching meetings: ${e.toString()}');
    }
  }

  Future<void> _signIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print("Google Sign-In failed: $error");
    }
  }

  Future<void> _signOut() async {
    await _googleSignIn.signOut();
    setState(() {
      _currentUser = null;
      _authClient = null;
      _calendarApi = null;
      _meetings = [];
    });
  }

  Future<void> _navigateToScheduleMeeting() async {
    if (_calendarApi != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ScheduleMeetingScreen(calendarApi: _calendarApi!),
        ),
      );
      if (result != null) {
        _fetchMeetings();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Meet Scheduler')),
      body: _currentUser == null
          ? Center(
              child: ElevatedButton(
                onPressed: _signIn,
                child: Text('Sign in with Google'),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Signed in as ${_currentUser?.displayName}'),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _meetings.length,
                    itemBuilder: (context, index) {
                      final meeting = _meetings[index];
                      return ListTile(
                        title: Text(meeting.summary),
                        subtitle: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Starts at: ${DateFormat('dd-MM-yy HH:mm').format(meeting.startTime)}',
                            ),
                            Text(
                              'ends at: ${DateFormat('dd-MM-yy HH:mm').format(meeting.endTime)}',
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MeetingDetailScreen(meeting: meeting),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: _navigateToScheduleMeeting,
                  child: Text('Schedule New Meeting'),
                ),
                ElevatedButton(
                  onPressed: _signOut,
                  child: Text('Sign out'),
                ),
              ],
            ),
    );
  }
}
