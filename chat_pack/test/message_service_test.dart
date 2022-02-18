import 'package:chat_pack/src/models/User.dart';
import 'package:chat_pack/src/models/message.dart';
import 'package:chat_pack/src/services/encryption/encryption_service_impl.dart';

import 'package:chat_pack/src/services/message/message_service_impl.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helper.dart';

void main() {
  RethinkDb r = RethinkDb();
  Connection? c;
  MessageServiceImpl? sut;

  setUp(() async {
    c = await r.connect(
      host: "localhost",
      port: 28015,
      user: 'admin',
      password: '',
    );
    await createDB(r, c!);
    final encryptionService =
        EncryptionServiceImpl(encrypter: Encrypter(AES(Key.fromLength(32))));
    sut = MessageServiceImpl(
        rethinkDb: r, connection: c!, encryptionService: encryptionService);
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

  test('should sent message successfully', () async {
    final message = Message(
      from: user.id,
      to: '3456',
      timestamp: DateTime.now(),
      contents: 'This is a message',
    );
    final res = await sut?.sendMessage(message: message);
    expect(res, true);
  });

  test('successfully subscribe and recieve messages', () async {
    String contents = 'this is a message';
    sut?.messages(activeUser: user2).listen(expectAsync1((message) {
          expect(message.to, user2.id);
          expect(message.id, isNotEmpty);
          expect(message.contents, contents);
        }, count: 2));

    Message message = Message(
      from: user.id,
      to: user2.id,
      timestamp: DateTime.now(),
      contents: contents,
    );
    Message secondMessage = Message(
      from: user.id,
      to: user2.id,
      timestamp: DateTime.now(),
      contents: contents,
    );

    await sut?.sendMessage(message: message);
    await sut?.sendMessage(message: secondMessage);
  });

  test('successfully subscribe and receive new messages ', () async {
    Message message = Message(
      from: user.id,
      to: user2.id,
      timestamp: DateTime.now(),
      contents: 'this is a message',
    );

    Message secondMessage = Message(
      from: user.id,
      to: user2.id,
      timestamp: DateTime.now(),
      contents: 'this is another message',
    );

    await sut?.sendMessage(message: message);
    await sut?.sendMessage(message: secondMessage).whenComplete(
          () => sut?.messages(activeUser: user2).listen(
                expectAsync1((message) {
                  expect(message.to, user2.id);
                }, count: 2),
              ),
        );
  });
}
