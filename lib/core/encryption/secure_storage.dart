import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _upiIdKey = 'upi_id';
  static const String _encryptionKeyKey = 'encryption_key';
  static const String _deviceFingerprintKey = 'device_fingerprint';

  /// Store auth token
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }

  /// Retrieve auth token
  Future<String?> getAuthToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  /// Store refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Retrieve refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Store user ID
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// Retrieve user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Store UPI ID
  Future<void> saveUpiId(String upiId) async {
    await _storage.write(key: _upiIdKey, value: upiId);
  }

  /// Retrieve UPI ID
  Future<String?> getUpiId() async {
    return await _storage.read(key: _upiIdKey);
  }

  /// Store encryption key
  Future<void> saveEncryptionKey(String key) async {
    await _storage.write(key: _encryptionKeyKey, value: key);
  }

  /// Retrieve encryption key
  Future<String?> getEncryptionKey() async {
    return await _storage.read(key: _encryptionKeyKey);
  }

  /// Store device fingerprint
  Future<void> saveDeviceFingerprint(String fingerprint) async {
    await _storage.write(key: _deviceFingerprintKey, value: fingerprint);
  }

  /// Retrieve device fingerprint
  Future<String?> getDeviceFingerprint() async {
    return await _storage.read(key: _deviceFingerprintKey);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all secure storage (Logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Clear specific key
  Future<void> deleteKey(String key) async {
    await _storage.delete(key: key);
  }

  /// Generic save
  Future<void> save(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Generic retrieve
  Future<String?> get(String key) async {
    return await _storage.read(key: key);
  }
}
