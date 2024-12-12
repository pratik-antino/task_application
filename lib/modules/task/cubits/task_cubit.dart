import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:task_application/core/config/toast_util.dart';
import 'package:task_application/core/extensions/common_extension.dart';
import 'package:task_application/modules/task/repository/task_repo.dart';
import 'dart:convert';
import '../model/comment_model.dart';
import '../model/task.dart';
part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final TaskRepo _taskRepo = TaskRepo();
  TaskCubit() : super(TaskInitial());

  final String baseUrl =
      'https://d638-121-243-82-214.ngrok-free.app/api'; // Replace with your actual backend URL

  Future<void> fetchTasks(String token) async {
    emit(TaskLoading());
    try {
      final response = await _taskRepo.fetchAllTasks();
      final List<Task> loadedTasks = [];
      for (var userData in response) {
        loadedTasks.add(Task.fromJson(userData));
      }
      emit(TaskLoaded(loadedTasks));
    } catch (error) {
      emit(TaskError('An error occurred. Please try again.:$error'));
    }
  }

  Future<void> addTask(Task task, String token) async {
    try {
      final response = await _taskRepo.addTask(task);
      ToastUtil.showToast(message: 'Task Deleted Successfully');
      fetchTasks(token);
    } catch (error) {
      emit(TaskError(
          error.getErrorMessage ?? 'An error occurred. Please try again.'));
    }
  }

  Future<void> updateTask(Task task, String token) async {
    try {
      final response = await _taskRepo.updateTask(task);
      fetchTasks(token);
      ToastUtil.showToast(message: 'Task Updated Successfully');
    } catch (error) {
      emit(
        TaskError(
            error.getErrorMessage ?? 'An error occurred. Please try again.'),
      );
    }
  }

  Future<void> deleteTask(String taskId, String token) async {
    try {
      await _taskRepo.deleteTask(taskId);
      fetchTasks(token);
      ToastUtil.showToast(message: 'Task Deleted Successfully');
    } catch (error) {
      emit(TaskError(
          error.getErrorMessage ?? 'An error occurred. Please try again.'));
    }
  }

  Future<void> addComment(String taskId, String comment, String token) async {
    try {
      final response = await _taskRepo.addCommentOnTask(comment, taskId);

      fetchTasks(token);
      ToastUtil.showToast(message: 'Comment added..');
    } catch (error) {
      emit(TaskError(
          error.getErrorMessage ?? 'An error occurred. Please try again.'));
    }
  }

  Future<void> fetchComments(String taskId, String token) async {
    try {
      final response = await _taskRepo.fetchComment();

      if (response) {
        final List<dynamic> commentsJson = json.decode(response.body);
        final comments =
            commentsJson.map((json) => Comment.fromJson(json)).toList();
      } else {
        emit(TaskError('Failed to fetch comments'));
      }
    } catch (error) {
      emit(TaskError('An error occurred. Please try again.'));
    }
  }
}
