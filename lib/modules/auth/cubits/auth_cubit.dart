import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_application/core/extensions/common_extension.dart';
import 'package:task_application/models/user.dart';

import 'package:task_application/modules/auth/auth_repo/auth_repo.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo _authRepo = AuthRepo();
  AuthCubit() : super(AuthInitial()) {
    checkAuthStatus();
  }
  Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getString('userId');
    if (token != null && userId != null) {
      emit(AuthAuthenticated(token: token, userId: userId));
      return true;
    } else {
      emit(AuthUnauthenticated());
      return false;
    }
  }

  // Handle user login
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final response =
          await _authRepo.getUserSignedIn(email: email, password: password);
      if (response["user"] != null && response['token'] != null) {
        final user = User.fromJson(response["user"]);
        final token = response["token"];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('userId', user.id);
        emit(AuthAuthenticated(token: token, userId: user.id));
      }
    } catch (e) {
      emit(
        AuthError(e.getErrorMessage ?? 'error'),
      );
    }
  }

  // Handle user signup
  Future<void> signup(String name, String email, String password) async {
    emit(AuthLoading());
    try {
      final response = await _authRepo.getUserSignedUp(
          email: email, password: password, name: name);

      if (response['token'] != null && response['user'] != null) {
        final user = User.fromJson(response["user"]);
        final token = response["token"];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('userId', user.id);
        emit(AuthAuthenticated(token: token, userId: user.id));
      } else {
        emit(AuthError('Failed to create account. Please try again.'));
      }
    } catch (e) {
      emit(
        AuthError(e.getErrorMessage ?? 'error'),
      );
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
