import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StudentsPage extends StatefulWidget {
  const StudentsPage({super.key});

  @override
  _StudentsPageState createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final String apiUrl = 'http://localhost:3000/students';
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          students = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        showError('Failed to fetch students. Please try again later.');
      }
    } catch (e) {
      showError('Error fetching students: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> addStudent() async {
    final String firstName = firstNameController.text.trim();
    final String lastName = lastNameController.text.trim();
    final String email = emailController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
      showError('Please fill all fields.');
      return;
    }

    try {
      final newStudent = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newStudent),
      );

      if (response.statusCode == 201) {
        fetchStudents();
        Navigator.pop(context);
      } else {
        showError('Failed to add student.');
      }
    } catch (e) {
      showError('Error adding student. Please try again.');
    }
  }

  Future<void> updateStudent(String id) async {
    final String firstName = firstNameController.text.trim();
    final String lastName = lastNameController.text.trim();
    final String email = emailController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
      showError('Please fill all fields.');
      return;
    }

    try {
      final updatedStudent = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
      };

      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedStudent),
      );

      if (response.statusCode == 200) {
        fetchStudents();
        Navigator.pop(context);
      } else {
        showError('Failed to update student.');
      }
    } catch (e) {
      showError('Error updating student. Please try again.');
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        fetchStudents();
      } else {
        showError('Failed to delete student.');
      }
    } catch (e) {
      showError('Error deleting student: $e');
    }
  }

  void showStudentDialog({Map<String, dynamic>? studentData}) {
    final isEditing = studentData != null;

    if (isEditing) {
      firstNameController.text = studentData!['first_name'];
      lastNameController.text = studentData['last_name'];
      emailController.text = studentData['email'];
    } else {
      firstNameController.clear();
      lastNameController.clear();
      emailController.clear();
    }
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Student' : 'Add Student'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
              ),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => isEditing
                  ? updateStudent(studentData!['id'])
                  : addStudent(),
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
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
        title: const Text('Students'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : students.isEmpty
              ? const Center(
                  child: Text(
                    'No students available. Add a new student!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final studentData = students[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(
                          '${studentData['first_name']} ${studentData['last_name']}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(studentData['email']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () =>
                                  showStudentDialog(studentData: studentData),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  deleteStudent(studentData['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showStudentDialog(),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}