import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/google_calendar_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final _calendarService = GoogleCalendarService();

  Map<DateTime, List<Map<String, dynamic>>> _eventsByDay = {};
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _trySilentSignInAndLoadEvents();
  }

  Future<void> _confirmDelete(Map<String, dynamic> event) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) =>
          AlertDialog(
            title: const Text('Usuń wydarzenie'),
            content: Text('Czy na pewno chcesz usunąć "${event['summary'] ??
                '(bez tytułu)'}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Anuluj'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Usuń'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await _calendarService.deleteEvent(event['id']);
        await _loadEvents();
      } catch (e) {
        setState(() {
          _errorMessage = 'Błąd podczas usuwania: $e';
        });
      }
    }
  }

  Future<void> _trySilentSignInAndLoadEvents() async {
    try {
      await _calendarService.ensureSignedIn();
      await _loadEvents();
    } catch (e) {
      setState(() {
        _errorMessage = 'Zaloguj się, aby zobaczyć wydarzenia';
      });
    }
  }

  Future<void> _loadEvents() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final events = await _calendarService.getUpcomingEvents();

      final Map<DateTime, List<Map<String, dynamic>>> grouped = {};
      for (final e in events) {
        final dt = DateTime.tryParse(e['start'])?.toLocal();
        if (dt != null) {
          final day = DateTime(dt.year, dt.month, dt.day);
          grouped.putIfAbsent(day, () => []).add(e);
        }
      }

      setState(() {
        _eventsByDay = grouped;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _eventsByDay[DateTime(day.year, day.month, day.day)] ?? [];
  }

  Color _getColor(String? title) {
    if (title == null) return Colors.blue[100]!;
    final lower = title.toLowerCase();
    if (lower.contains("trening")) return Colors.purple[200]!;
    if (lower.contains("rodzic")) return Colors.green[200]!;
    if (lower.contains("zawody")) return Colors.yellow[200]!;
    return Colors.blue[100]!;
  }

  void _showEventDetails(Map<String, dynamic> event) {
    final startDateTime = DateTime.tryParse(event['start'] ?? '')?.toLocal();
    final dayStr = startDateTime != null ? DateFormat('dd.MM.yyyy').format(startDateTime) : 'Brak daty';
    final timeStr = startDateTime != null ? DateFormat('HH:mm').format(startDateTime) : 'Brak godziny';
    final description = event['description'] ?? '(Brak opisu)';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(event['summary'] ?? 'Bez tytułu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dzień: $dayStr'),
            Text('Godzina rozpoczęcia: $timeStr'),
            const SizedBox(height: 10),
            Text('Opis:', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(description),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Zamknij"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalendarz'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadEvents),
          IconButton(
              icon: const Icon(Icons.add), onPressed: _showAddEventDialog),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            eventLoader: _getEventsForDay,
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: events.map((e) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getColor(
                                (e as Map<String, dynamic>)['summary']),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              children: _getEventsForDay(_selectedDay ?? _focusedDay).map((e) {
                final startTime = DateFormat('HH:mm').format(
                    DateTime.parse(e['start']));
                return ListTile(
                  title: Text(e['summary'] ?? '(bez tytułu)'),
                  subtitle: Text('Godzina: $startTime'),
                  onTap: () => _showEventDetails(e),
                  onLongPress: () => _confirmDelete(e),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _showAddEventDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String eventType = 'Inne'; // Domyślny typ
    final eventTypes = ['Trening', 'Spotkanie z rodzicami', 'Zawody', 'Inne'];

    DateTime start = DateTime.now().add(const Duration(hours: 1));
    DateTime end = start.add(const Duration(hours: 1));

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Dodaj wydarzenie'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Tytuł'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(labelText: 'Opis'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: eventType,
                      items: eventTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            eventType = value;
                          });
                        }
                      },
                      decoration: const InputDecoration(
                          labelText: 'Typ wydarzenia'),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      child: const Text('Wybierz datę i godzinę'),
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: start,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate == null) return;

                        final pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(start),
                        );
                        if (pickedTime == null) return;

                        setState(() {
                          start = DateTime(
                              pickedDate.year, pickedDate.month, pickedDate.day,
                              pickedTime.hour, pickedTime.minute);
                          end = start.add(const Duration(hours: 1));
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Text("Od: ${DateFormat('dd.MM.yyyy HH:mm').format(start)}"),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context),
                    child: const Text("Anuluj")),
                ElevatedButton(
                  onPressed: () async {
                    final fullTitle = '[${eventType}] ${titleController.text
                        .trim()
                        .isEmpty ? "Bez tytułu" : titleController.text.trim()}';
                    await _calendarService.addEvent(
                      title: fullTitle,
                      start: start,
                      end: end,
                      description: descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                    );
                    Navigator.pop(context);
                    await _loadEvents();
                  },
                  child: const Text("Dodaj"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}


