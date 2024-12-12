import 'package:task_application/core/api_client/api_client.dart';
import 'package:task_application/core/constants/api_route.dart';

class AuthRepo {
  static final dioUtils = DioUtil();
  // to sign the user
  Future<dynamic> getUserSignedIn({
    required String email,
    required String password,
  }) async {
    final body = {"email": email, "password": password};
    final response = dioUtils.post(ApiRoute.signIn, body: body);
    return response;
  }

  Future<dynamic> getUserSignedUp(
      {required String email,
      required String password,
      required String name}) async {
    final body = {
      'name': name,
      'email': email,
      'password': password,
    };
    final response = dioUtils.post(ApiRoute.signup, body: body);
    return response;
  }

  Future <dynamic>fetchallUsers(){
    
    final response = dioUtils.get(ApiRoute.fetchUsers);
    return response;
  }
}
