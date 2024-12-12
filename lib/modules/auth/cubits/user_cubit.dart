import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_application/modules/auth/auth_repo/auth_repo.dart';
import '../../../models/user.dart';
import 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final AuthRepo _authRepo = AuthRepo();

  UserCubit() : super(UserInitial());

  Future<void> fetchUsers(String token) async {
    emit(UserLoading());
    try {
      final response = await _authRepo.fetchallUsers();

      final List<User> loadedUsers = [];
      // final extractedData = json.decode(response) as List<dynamic>;
      for (var userData in response) {
        loadedUsers.add(User.fromJson(userData));
      }
      emit(UserLoaded(loadedUsers));
    } catch (error) {
      emit(UserError(error.toString()));
    }
  }
}
