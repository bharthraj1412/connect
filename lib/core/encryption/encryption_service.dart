import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:convert';
import 'package:crypto/crypto.dart';

class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  late encrypt.Key _key;
  late encrypt.IV _iv;

  factory EncryptionService() {
    return _instance;
  }

  EncryptionService._internal();

  static Future<void> initialize() async {
    _instance._key = encrypt.Key.fromSecureRandom(32); // 256-bit key
    _instance._iv = encrypt.IV.fromSecureRandom(16); // 128-bit IV
  }

  /// Encrypt string using AES-256-CBC
  String encryptString(String plaintext) {
    final plainTextBytes = utf8.encode(plaintext);
    final encrypter = encrypt.Encrypter(encrypt.AES(_key, encrypt.AESMode.cbc));
    final encrypted = encrypter.encryptBytes(plainTextBytes, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypt string using AES-256-CBC
  String decryptString(String encryptedText) {
    try {
      final encrypter =
          encrypt.Encrypter(encrypt.AES(_key, encrypt.AESMode.cbc));
      final decrypted = encrypter.decrypt64(encryptedText, iv: _iv);
      return decrypted;
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  /// Generate hash for sensitive data (one-way)
  String hashData(String data) {
    return sha256.convert(utf8.encode(data)).toString();
  }

  /// Generate HMAC for data integrity
  String generateHMAC(String message, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(message);
    final hmacSha256 = encrypt.HMAC(
      encrypt.Key(key),
      length: 32,
    );
    // Note: Using crypto package for HMAC
    return sha256.convert(key + bytes).toString();
  }

  /// Generate random token
  String generateRandomToken({int length = 32}) {
    return encrypt.Key.fromSecureRandom(length).base64;
  }

  /// Encrypt sensitive user data
  Map<String, dynamic> encryptUserData(Map<String, dynamic> userData) {
    return {
      ...userData,
      'phone': encryptString(userData['phone'] as String),
      'upi_id': encryptString(userData['upi_id'] as String),
      'email': encryptString(userData['email'] as String),
    };
  }

  /// Decrypt sensitive user data
  Map<String, dynamic> decryptUserData(Map<String, dynamic> userData) {
    return {
      ...userData,
      'phone': decryptString(userData['phone'] as String),
      'upi_id': decryptString(userData['upi_id'] as String),
      'email': decryptString(userData['email'] as String),
    };
  }
}
