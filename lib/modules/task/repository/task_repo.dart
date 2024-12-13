
import 'package:task_application/core/api_client/api_client.dart';
import 'package:task_application/core/constants/api_route.dart';
import 'package:task_application/modules/task/model/task.dart';

class TaskRepo {
  static final _dioUtils = DioUtil();
  // to sign the user
  Future<dynamic> fetchAllTasks() async {
    final response = _dioUtils.get(
      ApiRoute.fetchTasks,
    );
    return response;
  }

  Future<dynamic> addTask(Task task) async {
    final body = task.toJson();

    final response = await _dioUtils.post(ApiRoute.addTask, body: body);

    return response;
  }

  Future<dynamic> updateTask(Task task) async {
    final body = task.toJson();

    final response =
        await _dioUtils.patch('${ApiRoute.editTask}/${task.id}', body: body);

    return response;
  }

  Future<void> deleteTask(String taskId) async {
    await _dioUtils.delete('${ApiRoute.deleteTask}/$taskId');
  }

  Future<dynamic> addCommentOnTask(String comment, String taskId) async {
    final body = {'content': comment};
    final response = await _dioUtils
        .post('${ApiRoute.addTaskComment}/$taskId', body: body);
    return response;
  }

  Future<dynamic> fetchComment() {
    final response = _dioUtils.get(ApiRoute.fetchTaskComment);
    return response;
  }
}
