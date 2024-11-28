import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TeachersPage extends StatefulWidget {
  const TeachersPage({super.key});

  @override
  _TeachersPageState createState() => _TeachersPageState();
}

class _TeachersPageState extends State<TeachersPage> {
  final String apiUrl = 'http://localhost:3000/teachers';
  List<Map<String, dynamic>> teachers = [];
  bool isLoading = true;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTeachers();
  }

  Future<void> fetchTeachers() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          teachers = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        showError('Failed to fetch teachers. Please try again later.');
      }
    } catch (e) {
      showError('Error fetching teachers: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> addTeacher() async {
    final String firstName = firstNameController.text.trim();
    final String lastName = lastNameController.text.trim();
    final String email = emailController.text.trim();
    final String department = departmentController.text.trim();
    final String phone = phoneController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        department.isEmpty ||
        phone.isEmpty) {
      showError('Please fill all fields.');
      return;
    }

    try {
      final newTeacher = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'department': department,
        'phone': phone,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newTeacher),
      );

      if (response.statusCode == 201) {
        fetchTeachers();
        Navigator.pop(context);
      } else {
        showError('Failed to add teacher.');
      }
    } catch (e) {
      showError('Error adding teacher: $e');
    }
  }

  Future<void> updateTeacher(String id) async {
    final String firstName = firstNameController.text.trim();
    final String lastName = lastNameController.text.trim();
    final String email = emailController.text.trim();
    final String department = departmentController.text.trim();
    final String phone = phoneController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        department.isEmpty ||
        phone.isEmpty) {
      showError('Please fill all fields.');
      return;
    }

    try {
      final updatedTeacher = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'department': department,
        'phone': phone,
      };

      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedTeacher),
      );

      if (response.statusCode == 200) {
        fetchTeachers();
        Navigator.pop(context);
      } else {
        showError('Failed to update teacher.');
      }
    } catch (e) {
      showError('Error updating teacher: $e');
    }
  }

  Future<void> deleteTeacher(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        fetchTeachers();
      } else {
        showError('Failed to delete teacher.');
      }
    } catch (e) {
      showError('Error deleting teacher: $e');
    }
  }

  void showTeacherDialog({Map<String, dynamic>? teacher}) {
    final isEditing = teacher != null;

    if (isEditing) {
      firstNameController.text = teacher?['first_name'] ?? '';
      lastNameController.text = teacher?['last_name'] ?? '';
      emailController.text = teacher?['email'] ?? '';
      departmentController.text = teacher?['department'] ?? '';
      phoneController.text = teacher?['phone'] ?? '';
    } else {
      firstNameController.clear();
      lastNameController.clear();
      emailController.clear();
      departmentController.clear();
      phoneController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Teacher' : 'Add Teacher'),
          content: SingleChildScrollView(
            child: Column(
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
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: departmentController,
                  decoration: const InputDecoration(labelText: 'Department'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => isEditing
                  ? updateTeacher(teacher!['id'])
                  : addTeacher(),
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
        title: const Text('Teachers'),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : teachers.isEmpty
              ? const Center(
                  child: Text(
                    'No teachers available. Add a new teacher!',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: teachers.length,
                  itemBuilder: (context, index) {
                    final teacher = teachers[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${teacher['first_name']} ${teacher['last_name']}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Email: ${teacher['email']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Department: ${teacher['department']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Phone: ${teacher['phone']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Divider(
                              color: Colors.grey,
                              height: 20,
                              thickness: 0.5,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () =>
                                      showTeacherDialog(teacher: teacher),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => deleteTeacher(teacher['id']),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showTeacherDialog(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}