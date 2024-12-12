import 'package:task_application/core/api_client/api_client.dart';
import 'package:task_application/core/constants/api_route.dart';
import 'package:task_application/modules/events/event.dart';

class EventRepository {
  final DioUtil _dioUtil = DioUtil();

  Future<dynamic> fetchEvents() async {
    final response = await _dioUtil.get(ApiRoute.fetchEvents);
    return response;
  }

  Future<dynamic> addEvent(
    Event event,
  ) async {
    final body = event.toJson();

    final response = await _dioUtil.post(ApiRoute.addEvent, body: body);
    return response;
  }

  Future<dynamic> updateEvent(
    Event event,
  ) async {
    final body = event.toJson();
    final response =
        await _dioUtil.patch('${ApiRoute.updateEvent}/${event.id}', body: body);
    return response;
  }

  Future<void> deleteEvent(String eventId) async {
    await _dioUtil.delete('${ApiRoute.deleteEvent}/$eventId');
  }

  // ------------------event-comment------------------
  Future<dynamic> addEventComment(String comment, String eventId) async {
    final body = {'content': comment};
    final response =
        await _dioUtil.post('${ApiRoute.addEventcomment}/$eventId', body: body);
    return response;
  }
}
