import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  final String apiUrl = 'http://localhost:3000/sessions';
  List<Map<String, dynamic>> sessions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          sessions = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        showError('Failed to fetch sessions. Please try again later.');
      }
    } catch (e) {
      showError('Error fetching sessions: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Timetable'),
      backgroundColor: Colors.blueAccent,
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Table(
                border: TableBorder.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
                columnWidths: const {
                  0: FixedColumnWidth(100),
                  1: FixedColumnWidth(120),
                  2: FixedColumnWidth(120),
                  3: FixedColumnWidth(120),
                  4: FixedColumnWidth(120),
                  5: FixedColumnWidth(120),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  // Table Header (Days)
                  TableRow(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 174, 214, 255),
                    ),
                    children: [
                      _buildHeaderCell('Time'),
                      for (String day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'])
                        _buildHeaderCell(day),
                    ],
                  ),
                  // Table rows for each time slot
                  for (String time in _timeSlots())
                    TableRow(
                      children: [
                        _buildTimeCell(time),
                        for (String day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'])
                          _buildSessionCell(day, time),
                      ],
                    ),
                ],
              ),
            ),
          ),
  );
}

Widget _buildHeaderCell(String text) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Center(
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(255, 90, 169, 248),
        ),
      ),
    ),
  );
}

Widget _buildTimeCell(String time) {
  return Container(
    color: const Color.fromARGB(255, 224, 234, 242),
    padding: const EdgeInsets.all(8.0),
    child: Center(
      child: Text(
        time,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    ),
  );
}

Widget _buildSessionCell(String day, String time) {
  final session = sessions.firstWhere(
    (session) {
      final sessionDate = DateTime.parse(session['session_date']);
      final sessionDay = _getDayFromDate(sessionDate);
      final sessionTime = session['start_time'];

      return sessionDay == day && sessionTime == time.split(' - ')[0];
    },
    orElse: () => {},
  );

  if (session.isEmpty) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Text(
          'No session',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          session['subject_id'],
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          session['teacher_id'],
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    ),
  );
}


  List<String> _timeSlots() {
    // Time slots, you can customize based on your schedule
    return [
      '08:00 - 09:00',
      '09:00 - 10:00',
      '10:00 - 11:00',
      '11:00 - 12:00',
      '12:00 - 13:00',
      '13:00 - 14:00',
      '14:00 - 15:00',
    ];
  }

  Widget _getSessionForDayAndTime(String day, String time) {
    // Find the session based on the day and time slot
    final session = sessions.firstWhere(
      (session) {
        final sessionDate = DateTime.parse(session['session_date']);
        final sessionDay = _getDayFromDate(sessionDate);
        final sessionTime = session['start_time'];

        return sessionDay == day && sessionTime == time.split(' - ')[0];
      },
      orElse: () => {},
    );

    if (session.isEmpty) {
      return const Text('No session');
    }

    return Column(
      children: [
        Text(session['subject_id']),
        Text(session['teacher_id']),
      ],
    );
  }

  String _getDayFromDate(DateTime date) {
    switch (date.weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      default:
        return '';
    }
  }
}
