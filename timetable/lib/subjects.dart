import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SubjectsPage extends StatefulWidget {
  const SubjectsPage({super.key});

  @override
  _SubjectsPageState createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  final String apiUrl = 'http://localhost:3000/subjects';
  List<Map<String, dynamic>> subjects = [];
  bool isLoading = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController departmentController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSubjects();
  }

  Future<void> fetchSubjects() async {
    setState(() => isLoading = true);

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        setState(() {
          subjects = List<Map<String, dynamic>>.from(json.decode(response.body));
        });
      } else {
        showError('Failed to fetch subjects. Please try again later.');
      }
    } catch (e) {
      showError('Error fetching subjects: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> addSubject() async {
    final String name = nameController.text.trim();
    final String code = codeController.text.trim();
    final String department = departmentController.text.trim();
    final String description = descriptionController.text.trim();

    if (name.isEmpty || code.isEmpty || department.isEmpty || description.isEmpty) {
      showError('Please fill all fields.');
      return;
    }

    try {
      final newSubject = {
        'subject_name': name,
        'subject_code': code,
        'department': department,
        'description': description,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newSubject),
      );

      if (response.statusCode == 201) {
        fetchSubjects();
        Navigator.pop(context);
      } else {
        showError('Failed to add subject.');
      }
    } catch (e) {
      showError('Error adding subject. Please try again.');
    }
  }

  Future<void> updateSubject(String id) async {
    final String name = nameController.text.trim();
    final String code = codeController.text.trim();
    final String department = departmentController.text.trim();
    final String description = descriptionController.text.trim();

    if (name.isEmpty || code.isEmpty || department.isEmpty || description.isEmpty) {
      showError('Please fill all fields.');
      return;
    }

    try {
      final updatedSubject = {
        'subject_name': name,
        'subject_code': code,
        'department': department,
        'description': description,
      };

      final response = await http.put(
        Uri.parse('$apiUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedSubject),
      );

      if (response.statusCode == 200) {
        fetchSubjects();
        Navigator.pop(context);
      } else {
        showError('Failed to update subject.');
      }
    } catch (e) {
      showError('Error updating subject. Please try again.');
    }
  }

  Future<void> deleteSubject(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/$id'));
      if (response.statusCode == 200) {
        fetchSubjects();
      } else {
        showError('Failed to delete subject.');
      }
    } catch (e) {
      showError('Error deleting subject: $e');
    }
  }

  void showSubjectDialog({Map<String, dynamic>? subject}) {
    final isEditing = subject != null;

    if (isEditing) {
      nameController.text = subject!['subject_name'];
      codeController.text = subject['subject_code'];
      departmentController.text = subject['department'];
      descriptionController.text = subject['description'];
    } else {
      nameController.clear();
      codeController.clear();
      departmentController.clear();
      descriptionController.clear();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Subject' : 'Add Subject'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Subject Name'),
              ),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Subject Code'),
              ),
              TextField(
                controller: departmentController,
                decoration: const InputDecoration(labelText: 'Department'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
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
                  ? updateSubject(subject!['id'])
                  : addSubject(),
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
        title: const Text('Subjects'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : subjects.isEmpty
              ? Center(
                  child: Text(
                    'No subjects available.\nAdd a new subject!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          subject['subject_name'],
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(subject['description']),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => showSubjectDialog(subject: subject),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteSubject(subject['id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showSubjectDialog(),
        label: const Text('Add Subject'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}