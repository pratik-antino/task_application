import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as api;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
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

  @override
  void initState() {
    super.initState();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(()async {
        _currentUser = account;
        _authClient = account == null ? null : await  _createAuthClient(account);
        _calendarApi = _authClient == null ? null : api.CalendarApi(_authClient!);
      });
    });
    _googleSignIn.signInSilently();
  }

 Future< auth.AuthClient> _createAuthClient(GoogleSignInAccount account) async{
    final headers = await account.authHeaders;
    final client = auth.authenticatedClient(
      http.Client(),
      auth.AccessCredentials.fromJson(headers),
    );
    return client;
  }

  Future<void> _signIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print("Google Sign-In failed: $error");
    }
  }

  Future<void> _scheduleEvent() async {
    if (_calendarApi == null) return;

    final event = api.Event(
      summary: 'New Google Meet Event',
      description: 'Description of the event.',
      start: api.EventDateTime(dateTime: DateTime.now().add(Duration(hours: 1))),
      end: api.EventDateTime(dateTime: DateTime.now().add(Duration(hours: 2))),
      attendees: [
        api.EventAttendee(email: 'ps4761198@gmail.com'),
      ],
      conferenceData: api.ConferenceData(
        createRequest: api.CreateConferenceRequest(
          conferenceSolutionKey: api.ConferenceSolutionKey(type: 'hangoutsMeet'),
          requestId: DateTime.now().millisecondsSinceEpoch.toString(),
        ),
      ),
    );

    try {
      final result = await _calendarApi!.events.insert(
        event,
        'primary',
        conferenceDataVersion: 1,
      );
      print('Event created: ${result.hangoutLink}');
    } catch (error) {
      print('Failed to create event: $error');
    }
  }

  Future<void> _signOut() async {
    await _googleSignIn.signOut();
    setState(() {
      _currentUser = null;
      _authClient = null;
      _calendarApi = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Google Calendar Integration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _currentUser == null
                ? ElevatedButton(
                    onPressed: _signIn,
                    child: Text('Sign in with Google'),
                  )
                : Column(
                    children: [
                      Text('Signed in as ${_currentUser?.displayName}'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _scheduleEvent,
                        child: Text('Schedule Google Meet Event'),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _signOut,
                        child: Text('Sign out'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
