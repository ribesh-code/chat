import 'package:chat_pack/src/models/User.dart';
import 'package:chat_pack/src/models/typing_event.dart';
import 'package:chat_pack/src/services/typing/typing_notification_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helper.dart';

void main() {
  RethinkDb r = RethinkDb();
  Connection? c;
  TypingNotificationServiceImpl? sut;

  setUp(() async {
    c = await r.connect(
      host: "localhost",
      port: 28015,
      user: 'admin',
      password: '',
    );
    await createDB(r, c!);
    sut = TypingNotificationServiceImpl(connection: c!, rethinkDb: r);
  });

  tearDown(() async {
    sut?.dispose();
    await cleanDB(r, c!);
  });

  final user = User.fromJson({
    'username': 'Ribesh Basnet',
    'photo_url': 'url',
    'active': true,
    'last_seen': DateTime.now(),
    'id': '1234',
  });
  final user2 = User.fromJson({
    'username': 'Monika kc',
    'photo_url': 'url',
    'active': true,
    'last_seen': DateTime.now(),
    'id': '11111',
  });

  test('should send typing notification successfully', () async {
    TypingEvent typingEvent = TypingEvent(
      from: user2.id,
      to: user.id,
      event: Typing.start,
    );

    final res = await sut?.sendTyping(event: typingEvent, to: user);
    expect(res, true);
  });

  test('should successfully subscribe and recevie typing events', () async {
    sut?.subscribe(
        user: user2, userIds: [user.id]).listen(expectAsync1((event) {
      expect(event.from, user.id);
    }, count: 2));

    TypingEvent startTyping = TypingEvent(
      to: user2.id,
      from: user.id,
      event: Typing.start,
    );

    TypingEvent stopTyping = TypingEvent(
      to: user2.id,
      from: user.id,
      event: Typing.stop,
    );

    await sut?.sendTyping(event: startTyping, to: user2);
    await sut?.sendTyping(event: stopTyping, to: user2);
  });
}
