import 'dart:async';
import 'dart:developer';

import 'package:chat_pack/src/models/receipt.dart';
import 'package:chat_pack/src/models/User.dart';
import 'package:chat_pack/src/services/receipt/receipt_service_contract.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

class ReceiptServiceImpl implements IReceiptService {
  ReceiptServiceImpl({
    required this.rethinkDb,
    required this.connection,
  });

  final RethinkDb rethinkDb;
  final Connection connection;

  final _controller = StreamController<Receipt>.broadcast();
  StreamSubscription? _changeFeed;
  @override
  dispose() {
    _changeFeed?.cancel();
    _controller.close();
  }

  @override
  Stream<Receipt> receipts({required User user}) {
    _startRecevingReceipts(user: user);
    return _controller.stream;
  }

  @override
  Future<bool> send({required Receipt receipt}) async {
    var data = receipt.toJson();
    Map record = await rethinkDb.table('receipts').insert(data).run(connection);
    return record['inserted'] == 1;
  }

  _startRecevingReceipts({required User user}) {
    _changeFeed = rethinkDb
        .table('receipts')
        .filter({'recipient': user.id})
        .changes({'include_initial': true})
        .run(connection)
        .asStream()
        .cast<Feed>()
        .listen((event) {
          event
              .forEach((feedData) {
                if (feedData['new_val'] == null) return;

                final receipt = _receiptFromFeed(feedData);
                _controller.sink.add(receipt);
              })
              .catchError((err) => log('$err'))
              .onError((err, stackTrace) => log('$stackTrace'));
        });
  }

  Receipt _receiptFromFeed(feedData) {
    var data = feedData['new_val'];
    return Receipt.fromJson(data);
  }
}
