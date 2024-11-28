import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  final String backendUrl = 'http://localhost:3050'; // Replace with your server URL

  // Function to send login request to the backend
  Future<String?> login(String email, String password) async {
    final url = '$backendUrl/login'; // Login endpoint

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['token']; // Return the JWT token
    } else if (response.statusCode == 401) {
      throw Exception('Invalid email or password');
    } else {
      throw Exception('Server error');
    }
  }

  // Function to register a new user
  Future<bool> signUp(String email, String password) async {
    final url = '$backendUrl/register'; // Register endpoint

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 201) {
      return true; // User successfully registered
    } else if (response.statusCode == 400) {
      throw Exception('User already exists');
    } else {
      throw Exception('Server error');
    }
  }

  // Function to logout (delete token)
  Future<void> logout() async {
    // Add logic to remove JWT token from secure storage or shared preferences
    // Example: await storage.delete(key: 'jwt');
  }

  // Function to verify the JWT token
  Future<bool> verifyToken(String token) async {
    final url = '$backendUrl/verify'; // Verify endpoint (if available)

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true; // Token is valid
    } else {
      return false; // Token is invalid or expired
    }
  }
}
