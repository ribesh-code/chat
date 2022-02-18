import 'dart:developer';

import 'package:chat_pack/src/services/encryption/encryption_contract.dart';
import 'package:chat_pack/src/services/encryption/encryption_service_impl.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  IEncryptionService? sut;

  setUp(() {
    final encrypter = Encrypter(AES(Key.fromLength(32)));
    sut = EncryptionServiceImpl(encrypter: encrypter);
  });

  test('should encrypts the plain text', () {
    String text = 'this is a message';
    final base64 = RegExp(
        r'^(?:[A-Za-z0-9+\/]{4})*(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=|[A-Za-z0-9+\/]{4})$');

    final encrypted = sut?.encrypt(text: text);
    expect(base64.hasMatch(encrypted!), true);
  });

  test('should decrypts the encrypted text', () {
    String text = 'this is a message';
    final encrypted = sut?.encrypt(text: text);
    log('$encrypted');
    final decrypted = sut?.drcrypt(encryptedText: encrypted!);
    log('$decrypted');
    expect(decrypted, text);
  });
}
