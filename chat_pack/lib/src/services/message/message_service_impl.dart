import 'dart:async';
import 'dart:developer';

import 'package:chat_pack/src/models/message.dart';
import 'package:chat_pack/src/models/User.dart';
import 'package:chat_pack/src/services/encryption/encryption_contract.dart';
import 'package:chat_pack/src/services/message/message_service_contract.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class MessageServiceImpl extends IMessageService {
  MessageServiceImpl(
      {required this.rethinkDb,
      required this.connection,
      required this.encryptionService});
  final RethinkDb rethinkDb;
  final Connection connection;
  final IEncryptionService encryptionService;

  final _controller = StreamController<Message>.broadcast();
  StreamSubscription? _changeFeed;
  @override
  dispose() {
    _changeFeed?.cancel();
    _controller.close();
  }

  @override
  Stream<Message> messages({required User activeUser}) {
    _startRecevingMessages(user: activeUser);
    return _controller.stream;
  }

  @override
  Future<bool> sendMessage({required Message message}) async {
    var data = message.toJson();
    data['contents'] = encryptionService.encrypt(text: message.contents);
    Map record = await rethinkDb.table('messages').insert(data).run(connection);
    return record['inserted'] == 1;
  }

  _startRecevingMessages({required User user}) {
    _changeFeed = rethinkDb
        .table('messages')
        .filter({'to': user.id})
        .changes({'include_initial': true})
        .run(connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event
              .forEach((feedData) {
                if (feedData['new_val'] == null) return;

                final message = _messageFromFeed(feedData);
                _controller.sink.add(message);
                _removeDeliveredMessage(message: message);
              })
              .catchError((err) => log('$err'))
              .onError((err, stackTrace) => log('$stackTrace'));
        });
  }

  Message _messageFromFeed(feedData) {
    var data = feedData['new_val'];
    data['contents'] =
        encryptionService.drcrypt(encryptedText: data['contents']);
    return Message.fromJson(data);
  }

  _removeDeliveredMessage({required Message message}) {
    rethinkDb
        .table('messages')
        .get(message.id)
        .delete({'return_changes': false}).run(connection);
  }
}
