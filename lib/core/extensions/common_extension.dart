

import 'package:task_application/core/api_client/api_exception.dart';

extension ObjectExtentions on Object? {
  String? get getErrorMessage {
    if (this is ApiException) {
      return (this as ApiException).errorMessage;
    }
    return null;
  }


}
extension EmailExtension on String {
  bool get emailValid => RegExp(
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
      .hasMatch(this);
}

extension StringExtension on String {
String capitalize() {
return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
}
}