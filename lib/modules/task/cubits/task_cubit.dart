import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../models/task.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  TaskCubit() : super(TaskInitial());

  final String baseUrl = 'http://10.0.2.2:5000/api'; // Replace with your actual backend URL

  Future<void> fetchTasks(String token) async {
    emit(TaskLoading());
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> tasksJson = json.decode(response.body);
        final tasks = tasksJson.map((json) => Task.fromJson(json)).toList();
        emit(TaskLoaded(tasks));
      } else {
        emit(TaskError('Failed to load tasks'));
      }
    } catch (error) {
      emit(TaskError('An error occurred. Please try again.'));
    }
  }

  Future<void> addTask(Task task, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tasks'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 201) {
        fetchTasks(token);
      } else {
        emit(TaskError('Failed to add task'));
      }
    } catch (error) {
      emit(TaskError('An error occurred. Please try again.'));
    }
  }

  Future<void> updateTask(Task task, String token) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/tasks/${task.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(task.toJson()),
      );

      if (response.statusCode == 200) {
        fetchTasks(token);
      } else {
        emit(TaskError('Failed to update task'));
      }
    } catch (error) {
      emit(TaskError('An error occurred. Please try again.'));
    }
  }

  Future<void> deleteTask(String taskId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/tasks/$taskId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        fetchTasks(token);
      } else {
        emit(TaskError('Failed to delete task'));
      }
    } catch (error) {
      emit(TaskError('An error occurred. Please try again.'));
    }
  }
}

