import 'package:chat_pack/src/services/encryption/encryption_contract.dart';
import 'package:encrypt/encrypt.dart';

class EncryptionServiceImpl extends IEncryptionService {
  final Encrypter encrypter;
  final _iv = IV.fromLength(16); // _iv => initial vector

  EncryptionServiceImpl({required this.encrypter});
  @override
  String drcrypt({required String encryptedText}) {
    final encrypted = Encrypted.fromBase64(encryptedText);
    return encrypter.decrypt(encrypted, iv: _iv);
  }

  @override
  String encrypt({required String text}) {
    return encrypter.encrypt(text, iv: _iv).base64;
  }
}
