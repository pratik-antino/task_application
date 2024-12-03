// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import '../models/task.dart';
// import '../models/user.dart';

// class ApiService {
//   final String baseUrl = 'http://localhost:3000/api'; // Update this with your server's URL and port

//   Future<Map<String, dynamic>> login(String email, String password) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/users/login'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({'email': email, 'password': password}),
//     );

//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to login');
//     }
//   }

//   Future<Map<String, dynamic>> signup(String name, String email, String password) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/users/signup'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({'name': name, 'email': email, 'password': password}),
//     );

//     if (response.statusCode == 201) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to signup');
//     }
//   }

//   Future<List<Task>> fetchTasks(String token) async {
//     final response = await http.get(
//       Uri.parse('$baseUrl/tasks'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> tasksJson = json.decode(response.body);
//       return tasksJson.map((json) => Task.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load tasks');
//     }
//   }

//   Future<Task> addTask(Task task, String token) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/tasks'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: json.encode(task.toJson()),
//     );

//     if (response.statusCode == 201) {
//       return Task.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to add task');
//     }
//   }

//   Future<Task> updateTask(Task task, String token) async {
//     final response = await http.put(
//       Uri.parse('$baseUrl/tasks/${task.id}'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: json.encode(task.toJson()),
//     );

//     if (response.statusCode == 200) {
//       return Task.fromJson(json.decode(response.body));
//     } else {
//       throw Exception('Failed to update task');
//     }
//   }

//   Future<void> deleteTask(String taskId, String token) async {
//     final response = await http.delete(
//       Uri.parse('$baseUrl/tasks/$taskId'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     if (response.statusCode != 200) {
//       throw Exception('Failed to delete task');
//     }
//   }

//   Future<List<User>> fetchUsers(String token) async {
//     final response = await http.get(
//       Uri.parse('$baseUrl/users'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> usersJson = json.decode(response.body);
//       return usersJson.map((json) => User.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load users');
//     }
//   }
// }
