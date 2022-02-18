import 'package:chat_pack/src/models/user.dart';
import 'package:chat_pack/src/services/user/user_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helper.dart';

void main() {
  RethinkDb r = RethinkDb();
  Connection? c;
  UserServiceImpl? sut;

  setUp(() async {
    c = await r.connect(
      host: "localhost",
      port: 28015,
      user: 'admin',
      password: '',
    );
    await createDB(r, c!);
    sut = UserServiceImpl(rethinkDb: r, connection: c!);
  });

  tearDown(() async {
    await cleanDB(r, c!);
  });

  test('creates a new user in database', () async {
    final user = User(
      userName: 'test',
      photoUrl: 'test',
      active: true,
      lastSeen: DateTime.now(),
    );
    final userWithId = await sut?.connect(user: user);
    expect(userWithId?.id, isNotEmpty);
  });
  test('get online user', () async {
    final user = User(
      userName: 'test',
      photoUrl: 'test',
      active: true,
      lastSeen: DateTime.now(),
    );

    await sut?.connect(user: user);
    final onlineUsers = await sut?.onlineUsers();
    expect(onlineUsers?.length, 1);
  });
}
