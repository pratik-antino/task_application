import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial()) {
    checkAuthStatus();
  }

  final String baseUrl = 'https://779a-2409-40d0-1020-c9a9-95a1-2b9d-bb8b-e6cb.ngrok-free.app/api'; // Replace with your actual backend URL

  // Check if the user is authenticated
  Future<void> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');
    if (token != null && userId != null) {
      emit(AuthAuthenticated(token: token, userId: userId));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  // Handle user login
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final token = responseData['token'];
        final userId = responseData['user']['id'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('userId', userId);

        emit(AuthAuthenticated(token: token, userId: userId));
      } else {
        emit(AuthError('Invalid email or password'));
      }
    } catch (error) {
      emit(AuthError('An error occurred. Please try again.'),);
    }
  }

  // Handle user signup
  Future<void> signup(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final token = responseData['token'];
        final userId = responseData['user']['id'];

        emit(AuthAuthenticated(token: token, userId: userId));
      } else {
        emit(AuthError('Failed to create account. Please try again.'));
      }
    } catch (error) {
      emit(AuthError('An error occurred. Please try again.'));
    }
  }

  // Handle logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    emit(AuthUnauthenticated());
  }
}
