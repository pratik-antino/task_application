import 'dart:developer';

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
    _googleSignIn.onCurrentUserChanged
        .listen((GoogleSignInAccount? account) async {
      setState(() {
        _currentUser = account;
        if (_currentUser != null) {
          _createAuthClient(_currentUser!);
        } else {
          _authClient = null;
          _calendarApi = null;
        }
      });
    });
    _googleSignIn.signInSilently();
  }

  // This method creates the authenticated client
  Future<void> _createAuthClient(GoogleSignInAccount account) async {
    final authentication = await account.authentication;

    // Handle the possibility of the refresh token being null
    final accessToken = authentication.accessToken;

    if (accessToken == null) {
      print("Error: Access Token is null");
      return; // Don't proceed if the access token is unavailable
    }
try{
    // Create the credentials with access token (no refreshToken in this case)
   final credentials = auth.AccessCredentials(
  auth.AccessToken(
      'Bearer', 
      accessToken, 
      DateTime.utc(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour + 1) // Use UTC time
  ),
  null, // Can be null if not available
  [api.CalendarApi.calendarScope],
);

    
    // Authenticate the client and create the calendar API client
    _authClient = auth.authenticatedClient(http.Client(), credentials);
    _calendarApi = api.CalendarApi(_authClient!);
}catch (e){
  log('danskdna,d${e.toString()}');
}

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

    // Prepare event details
    final event = api.Event(
      summary: 'New Google Meet Event',
      description: 'This is a description of the event.',
      start: api.EventDateTime(dateTime: DateTime.now().add(Duration(hours: 1))),
      end: api.EventDateTime(dateTime: DateTime.now().add(Duration(hours: 2))),
      attendees: [
        api.EventAttendee(email: 'ps4761198@gmail.com'), // Specify attendee emails
        api.EventAttendee(email: 'govindsharma10101997@gmail.com'), // Specify attendee emails
      ],
      conferenceData: api.ConferenceData(
        createRequest: api.CreateConferenceRequest(
          conferenceSolutionKey: api.ConferenceSolutionKey(type: 'hangoutsMeet'), // Google Meet
          requestId: DateTime.now().millisecondsSinceEpoch.toString(),
        ),
      ),
    );

    try {
      // Insert the event into the calendar and request conference data (Google Meet)
      final result = await _calendarApi!.events.insert(
        event,
        'primary',
        conferenceDataVersion: 1,
      );
      print('Event created: ${result.hangoutLink}'); // Log the Google Meet link
      // Show the link in the UI or any other action
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Google Meet Link'),
          content: Text('Event created! Join the meeting here: ${result.hangoutLink}'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (error) {
      print('Failed to create event: $error');
      // Handle error in creating the event
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
