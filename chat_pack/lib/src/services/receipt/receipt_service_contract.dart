import 'package:chat_pack/src/models/User.dart';
import 'package:chat_pack/src/models/receipt.dart';

abstract class IReceiptService {
  Future<bool> send({required Receipt receipt});
  Stream<Receipt> receipts({required User user});
  void dispose();
}
