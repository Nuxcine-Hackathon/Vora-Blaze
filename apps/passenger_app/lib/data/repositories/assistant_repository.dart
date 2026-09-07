import 'package:ride_on/core/services/http.dart';
import 'package:ride_on/core/extensions/workspace.dart';

import '../../core/services/config.dart';

class AssistantRepository {
  Future<Map<String, dynamic>> sendMessage({
    required String message,
    required List<Map<String, String>> history,
  }) async {
    try {
      var response = await httpPost(
        Config.assistantChat,
        context: navigatorKey.currentContext!,
        {"message": message, "history": history},
      );
      return response;
    } catch (error) {
      rethrow;
    }
  }
}
