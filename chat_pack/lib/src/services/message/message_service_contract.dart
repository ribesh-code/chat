import 'package:chat_pack/src/models/User.dart';
import 'package:chat_pack/src/models/message.dart';

abstract class IMessageService {
  Future<bool> sendMessage({required Message message});
  Stream<Message> messages({required User activeUser});
  dispose();
}
