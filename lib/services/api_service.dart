import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // ================= USERS =================

  static Future<List<dynamic>> getUsers() async {
    final res = await http.get(Uri.parse('$baseUrl/users'));
    if (res.statusCode != 200) throw Exception('Failed to load users');
    return jsonDecode(res.body);
  }

  static Future<void> createUser(String name, String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email}),
    );
    if (res.statusCode != 201) throw Exception('Failed to create user');
  }

  static Future<void> deleteUser(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/users/$id'));
    if (res.statusCode != 200) throw Exception('Failed to delete user');
  }

  // ================= TASKS =================

  static Future<List<dynamic>> getTasks({required int userId}) async {
    final res = await http.get(Uri.parse('$baseUrl/tasks?user_id=$userId'));
    if (res.statusCode != 200) throw Exception('Failed to load tasks');
    return jsonDecode(res.body);
  }

  static Future<void> createTask(int userId, String title) async {
    final res = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'user_id': userId, 'title': title}),
    );
    if (res.statusCode != 201) throw Exception('Failed to create task');
  }

  /// ✅ FIXED: accepts named parameter {status}
  static Future<void> updateTask(int id, {required String status}) async {
    final res = await http.put(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status}),
    );
    if (res.statusCode != 200) throw Exception('Failed to update task');
  }

  static Future<void> deleteTask(int id) async {
    final res = await http.delete(Uri.parse('$baseUrl/tasks/$id'));
    if (res.statusCode != 200) throw Exception('Failed to delete task');
  }
}
