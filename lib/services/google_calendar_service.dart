import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticatedClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner;

  AuthenticatedClient(this._headers, [http.Client? inner])
      : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
  }
}

class GoogleCalendarService {
  static const _scopes = [
    'email',
    'profile',
    calendar.CalendarApi.calendarScope,
    calendar.CalendarApi.calendarEventsScope,
  ];

  final GoogleSignIn googleSignIn;
  GoogleSignInAccount? _currentUser;
  calendar.CalendarApi? _calendarApi;
  http.Client? _authClient;
  final String sharedCalendarId;

  GoogleCalendarService({required this.sharedCalendarId})
      : googleSignIn = GoogleSignIn(scopes: _scopes);

  Future<void> signInSilently() async {
    _currentUser = await googleSignIn.signInSilently();
    if (_currentUser != null) await _initCalendarApi();
  }

  Future<void> signIn() async {
    _currentUser = await googleSignIn.signIn();
    if (_currentUser == null) throw Exception('Użytkownik anulował logowanie.');
    await _initCalendarApi();
  }

  Future<void> _initCalendarApi() async {
    if (_currentUser == null) throw Exception('Brak zalogowanego użytkownika.');
    final authHeaders = await _currentUser!.authHeaders;
    _authClient?.close();
    _authClient = AuthenticatedClient(authHeaders);
    _calendarApi = calendar.CalendarApi(_authClient!);
  }

  Future<List<Map<String, dynamic>>> getUpcomingEvents({String calendarId = 'primary'}) async {
    await ensureSignedIn();
    final now = DateTime.now().toUtc();
    final events = await _calendarApi!.events.list(
      calendarId,
      timeMin: now,
      singleEvents: true,
      orderBy: 'startTime',
    );

    return events.items?.map((e) {
      final start = e.start?.dateTime ?? e.start?.date;
      final end = e.end?.dateTime ?? e.end?.date;
      return {
        'id': e.id,
        'summary': e.summary,
        'description': e.description,
        'start': start?.toIso8601String(),
        'end': end?.toIso8601String(),
      };
    }).toList() ?? [];
  }

  Future<void> addEvent({
    required String title,
    required DateTime start,
    required DateTime end,
    String? description,
    String calendarId = 'primary',
  }) async {
    await ensureSignedIn();
    final event = calendar.Event()
      ..summary = title
      ..start = calendar.EventDateTime(dateTime: start.toUtc())
      ..end = calendar.EventDateTime(dateTime: end.toUtc())
      ..description = description;
    await _calendarApi!.events.insert(event, calendarId);
  }

  Future<void> deleteEvent(String eventId, {String calendarId = 'primary'}) async {
    await ensureSignedIn();
    await _calendarApi!.events.delete(calendarId, eventId);
  }

  Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();

      _currentUser = null;
      _calendarApi = null;
      _authClient?.close();
      _authClient = null;

      print("Wylogowano poprawnie z Google i Firebase.");
    } catch (e) {
      print("Błąd podczas wylogowania: $e");
    }
  }

  bool get isSignedIn => _currentUser != null;

  Future<void> ensureSignedIn() async {
    if (!isSignedIn) {
      _currentUser = await googleSignIn.signInSilently();
      if (_currentUser == null) {
        _currentUser = await googleSignIn.signIn();
      }
      await _initCalendarApi();
    }
  }

}

