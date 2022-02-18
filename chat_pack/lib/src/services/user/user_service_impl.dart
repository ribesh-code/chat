import 'package:chat_pack/src/models/user.dart';
import 'package:chat_pack/src/services/user/user_service_contract.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class UserServiceImpl implements IUserService {
  final RethinkDb rethinkDb;
  final Connection connection;

  UserServiceImpl({required this.rethinkDb, required this.connection});

  @override
  Future<User> connect({required User user}) async {
    var data = user.toJson();
    if (user.id.isNotEmpty) data['id'] = user.id;
    final result = await rethinkDb.table('users').insert(data, {
      'conflict': 'update',
      'return_changes': true,
    }).run(connection);
    return User.fromJson(result['changes'].first['new_val']);
  }

  @override
  Future<void> disconnectUser({required User user}) async {
    await rethinkDb.table('users').update({
      'id': user.id,
      'active': false,
      'last_seen': DateTime.now(),
    }).run(connection);
    connection.close();
  }

  @override
  Future<List<User>> onlineUsers() async {
    Cursor users =
        await rethinkDb.table('users').filter({'active': true}).run(connection);
    final userList = await users.toList();
    return userList.map((item) => User.fromJson(item)).toList();
  }
}
