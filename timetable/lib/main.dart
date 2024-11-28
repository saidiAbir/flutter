import 'package:flutter/material.dart';
import '/auth/login_page.dart'; // Import LoginPage
import '/auth/auth_utils.dart'; // Import authentication check
import 'room.dart'; // Import your Pages like Rooms, Teachers, etc.
import 'teachers.dart'; // Import the TeachersPage
import 'subjects.dart'; // Import the SubjectsPage
import 'classes.dart'; // Import the ClassesPage
import 'sessions.dart'; // Import the SessionsPage
import 'students.dart'; // Import the StudentsPage
import 'timetable.dart'; // Import the TimetablePage
import '/auth/signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Enhanced Navigator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/main': (context) => const HomePage(),
      },
      home: FutureBuilder<bool>(
        future: isAuthenticated(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data == true) {
            return const HomePage();
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}

// HomePage with an enhanced design
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _logout(BuildContext context) async {
    await clearToken(); // Clear the token
    Navigator.pushReplacementNamed(context, '/login'); // Navigate to LoginPage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context), // Call the logout function
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2, // Two items per row
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildCard(context, 'Rooms', Icons.meeting_room, const RoomsPage()),
            _buildCard(context, 'Teachers', Icons.person, const TeachersPage()),
            _buildCard(context, 'Subjects', Icons.book, const SubjectsPage()),
            _buildCard(context, 'Classes', Icons.class_, const ClassesPage()),
            _buildCard(context, 'Sessions', Icons.schedule, const SessionsPage()),
            _buildCard(context, 'Students', Icons.school, const StudentsPage()),
            _buildCard(context, 'Timetable', Icons.table_chart, const TimetablePage()),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, Widget targetPage) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetPage),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.blueAccent),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
