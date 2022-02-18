import 'package:chat_pack/src/models/User.dart';
import 'package:chat_pack/src/models/typing_event.dart';

abstract class ITypingNotificationService {
  Future<bool> sendTyping({required TypingEvent event, required User to});
  Stream<TypingEvent> subscribe(
      {required User user, required List<String> userIds});
  void dispose();
}
