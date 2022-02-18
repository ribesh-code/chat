import 'package:chat_pack/src/models/user.dart';

abstract class IUserService {
  Future<User> connect({required User user});
  Future<List<User>> onlineUsers();
  Future<void> disconnectUser({required User user});
}
