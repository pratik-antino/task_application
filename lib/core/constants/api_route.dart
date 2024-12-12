abstract class ApiRoute {
  static const String devUrl = "https://7e8e-121-243-82-214.ngrok-free.app/api";
  static const String ngRok = "https://sm-meter.loca.lt";

  static const String baseUrl = devUrl;
  static const String signIn = '$baseUrl/users/login';
  static const String signup = '$baseUrl/users/signup';
  static const String fetchUsers = '$baseUrl/users';
  static const String fetchTasks = '$baseUrl/tasks';
  static const String addTask = '$baseUrl/tasks/add-task';
  static const String editTask = '$baseUrl/tasks/edit-task';
  static const String deleteTask = '$baseUrl/tasks/delete-task';
  static const String addTaskComment = '$baseUrl/comments/post-comment';
  static const String fetchTaskComment = '$baseUrl/comments';
  // -------------------event-Routes-------------------------------------
  static const String fetchEvents = '$baseUrl/events';
  static const String addEvent = '$baseUrl/events/add-event';
  static const String updateEvent = '$baseUrl/events/update-event';
  static const String deleteEvent = '$baseUrl/events/delete-event';
  static const String addEventcomment = '$baseUrl/event/comments';
}
