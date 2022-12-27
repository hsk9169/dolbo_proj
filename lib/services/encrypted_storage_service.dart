import 'dart:typed_data';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:encrypt/encrypt.dart';

/* << Encrypted Storage Dictionary >>
 * * Dolbo List Number
 * * * 'list_num': {number of list}
 * * Dolbo List Element (index = 0,1,2,...)
 * * * 'element_{index}': {place.id}
 * * Last Seen Page in Main Page
 * * * 'last_seen': {page_num}
 * * Alarm Setting
 * * * 'alarm_allowed': {'TRUE' or 'FALSE'}
 * * * 'alarm_threshold': {'WARNING' or 'DANGER'}
 */
class EncryptedStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String _encKey = 'sUpErEnCkEy';
  final IV _iv = IV.fromLength(16);
  String? _secureStorageKey = '';
  late Key _aesKey;

  Future<void> initStorage() async {
    _secureStorageKey =
        await _storage.read(key: _encKey, aOptions: _getAndroidOptions());

    if (_secureStorageKey == null) {
      _secureStorageKey = SecureRandom(32).base64;
      await _storage.write(
          key: _encKey,
          value: _secureStorageKey,
          aOptions: _getAndroidOptions());
    }
    _aesKey = Key.fromBase64(_secureStorageKey!);
  }

  Future<void> deleteAllData() async {
    await _storage.deleteAll();
  }

  Future<void> saveData(String key, String value) async {
    final encryptedKeyBytes = AES(_aesKey).encrypt(
      Uint8List.fromList(utf8.encode(key)),
      iv: _iv,
    );
    final encryptedValueBytes = AES(_aesKey).encrypt(
      Uint8List.fromList(utf8.encode(value)),
      iv: _iv,
    );

    if (await _storage.containsKey(
        key: encryptedKeyBytes.base64, aOptions: _getAndroidOptions())) {
      await _storage.delete(
          key: encryptedKeyBytes.base64, aOptions: _getAndroidOptions());
    }
    await _storage.write(
        key: encryptedKeyBytes.base64,
        value: encryptedValueBytes.base64,
        aOptions: _getAndroidOptions());
  }

  Future<String> readData(String key) async {
    final encryptedKeyBytes = AES(_aesKey).encrypt(
      Uint8List.fromList(utf8.encode(key)),
      iv: _iv,
    );
    var secureStorageValue = await _storage.read(
        key: encryptedKeyBytes.base64, aOptions: _getAndroidOptions());
    if (secureStorageValue == null) {
      return '';
    }

    final encrypted = Encrypted(base64.decode(secureStorageValue));
    final decryptedValueBytes = AES(_aesKey).decrypt(
      encrypted,
      iv: _iv,
    );
    return utf8.decode(decryptedValueBytes);
  }

  Future<void> removeData(String key) async {
    final encryptedKeyBytes = AES(_aesKey).encrypt(
      Uint8List.fromList(utf8.encode(key)),
      iv: _iv,
    );
    await _storage.delete(
        key: encryptedKeyBytes.base64, aOptions: _getAndroidOptions());
  }

  Future<void> readAll() async {
    final allData = await _storage.readAll(aOptions: _getAndroidOptions());
    allData.entries
        .forEach((entry) => print('key: ${entry.key}, val: ${entry.value}'));
  }

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );
}

class SecItem {
  SecItem(this.key, this.value);

  final String key;
  final String value;

  Map<String, String> toJson() => {
        'key': key,
        'value': value,
      };
}
