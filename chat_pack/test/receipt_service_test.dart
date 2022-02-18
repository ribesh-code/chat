import 'package:chat_pack/src/models/User.dart';
import 'package:chat_pack/src/models/receipt.dart';
import 'package:chat_pack/src/services/receipt/receipt_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rethink_db_ns/rethink_db_ns.dart';

import 'helper.dart';

void main() {
  RethinkDb r = RethinkDb();
  Connection? c;
  ReceiptServiceImpl? sut;

  setUp(() async {
    c = await r.connect(
      host: "localhost",
      port: 28015,
      user: 'admin',
      password: '',
    );
    await createDB(r, c!);
    sut = ReceiptServiceImpl(connection: c!, rethinkDb: r);
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

  test('sent receipt sent sucessfully', () async {
    Receipt receipt = Receipt(
        recipient: '444',
        messageId: '1234',
        status: ReceiptStatus.delivered,
        timestamp: DateTime.now());

    final res = await sut?.send(receipt: receipt);
    expect(res, true);
  });

  test('successfully subscribe and receive receipts', () async {
    sut?.receipts(user: user).listen(expectAsync1((receipt) {
          expect(receipt.recipient, user.id);
        }, count: 2));

    Receipt receipt = Receipt(
        recipient: user.id,
        messageId: '1234',
        status: ReceiptStatus.delivered,
        timestamp: DateTime.now());

    Receipt anotherReceipt = Receipt(
        recipient: user.id,
        messageId: '1234',
        status: ReceiptStatus.read,
        timestamp: DateTime.now());

    await sut?.send(receipt: receipt);
    await sut?.send(receipt: anotherReceipt);
  });
}
