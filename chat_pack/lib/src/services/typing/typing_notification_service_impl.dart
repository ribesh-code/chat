import 'dart:async';
import 'dart:developer';

import 'package:chat_pack/src/models/typing_event.dart';
import 'package:chat_pack/src/models/User.dart';
import 'package:chat_pack/src/services/typing/typing_notification_service_contract.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class TypingNotificationServiceImpl implements ITypingNotificationService {
  final Connection connection;
  final RethinkDb rethinkDb;

  final _controller = StreamController<TypingEvent>.broadcast();
  StreamSubscription? _changeFeed;

  TypingNotificationServiceImpl({
    required this.connection,
    required this.rethinkDb,
  });
  @override
  Future<bool> sendTyping(
      {required TypingEvent event, required User to}) async {
    if (!to.active) return false;
    Map record = await rethinkDb
        .table('typing_events')
        .insert(event.toJson(), {'conflict': 'update'}).run(connection);
    return record['inserted'] == 1;
  }

  @override
  Stream<TypingEvent> subscribe(
      {required User user, required List<String> userIds}) {
    _startRecevingTypingEvents(user: user, userIds: userIds);
    return _controller.stream;
  }

  _startRecevingTypingEvents(
      {required User user, required List<String> userIds}) {
    _changeFeed = rethinkDb
        .table('typing_events')
        .filter((event) {
          return event('to')
              .eq(user.id)
              .and(rethinkDb.expr(userIds).contains(event('from')));
        })
        .changes({'include_initial': true})
        .run(connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event
              .forEach((feedData) {
                if (feedData['new_val'] == null) return;

                final typing = _eventFromFeed(feedData);
                _controller.sink.add(typing);
                _removeEvent(typing);
              })
              .catchError((err) => log('$err'))
              .onError(((error, stackTrace) => log('$stackTrace')));
        });
  }

  TypingEvent _eventFromFeed(feedData) {
    return TypingEvent.fromJson(feedData['new_val']);
  }

  _removeEvent(TypingEvent event) {
    rethinkDb
        .table('typing_events')
        .get(event.id)
        .delete({'return_changes': false}).run(connection);
  }

  @override
  void dispose() {
    _changeFeed?.cancel();
    _controller.close();
  }
}
