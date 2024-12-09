import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../models/user.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit() : super(UserInitial());

  final String baseUrl = 'https://d638-121-243-82-214.ngrok-free.app/api'; // Replace with your actual backend URL

  Future<void> fetchUsers(String token) async {
    emit(UserLoading());
    try {
      final url = Uri.parse('$baseUrl/users');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<User> loadedUsers = [];
        final extractedData = json.decode(response.body) as List<dynamic>;
        
        for (var userData in extractedData) {
          loadedUsers.add(User.fromJson(userData));
        }

        emit(UserLoaded(loadedUsers));
      } else {
        emit(const UserError('Failed to load users'));
      }
    } catch (error) {
      emit(UserError(error.toString()));
    }
  }
}

