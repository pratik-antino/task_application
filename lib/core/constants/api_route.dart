abstract class ApiRoute {
  static const String devUrl = "https://7e8e-121-243-82-214.ngrok-free.app/api";
  static const String ngRok = "https://sm-meter.loca.lt";

  static const String baseUrl = devUrl;
  static const String signIn = '$baseUrl/users/login';
  static const String signup = '$baseUrl/users/signup';
  static const String fetchUsers = '$baseUrl/users';
}
