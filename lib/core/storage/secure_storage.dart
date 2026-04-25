/// Secure Storage Service
/// Wrapper around flutter_secure_storage to persist tokens and user session
library;

import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Keys
const String _keyToken = 'auth_token';
const String _keyUser = 'auth_user_data';

class SecureStorageService {
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();
  // Singleton pattern
  static final SecureStorageService _instance =
      SecureStorageService._internal();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Save Auth Token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  /// Get Auth Token
  Future<String?> getToken() async => await _storage.read(key: _keyToken);

  /// Delete Auth Token
  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  /// Save User data (Stores as JSON string)
  /// Note: User type will be imported from features/auth
  /// Accepting dynamic/Map for now until generic User model is fully linked
  Future<void> saveUser(dynamic user) async {
    String jsonString;
    if (user is String) {
      jsonString = user;
    } else {
      // Assuming user has toJson() or passing a Map
      try {
        // If it's a User object (dynamic dispatch to avoid strict type error before file creation)
        jsonString = jsonEncode(user.toJson());
      } catch (_) {
        // Fallback if passing Map
        jsonString = jsonEncode(user);
      }
    }
    await _storage.write(key: _keyUser, value: jsonString);
  }

  /// Get User data (Returns Map, caller must parse)
  Future<Map<String, dynamic>?> getUserData() async {
    final str = await _storage.read(key: _keyUser);
    if (str == null) return null;
    try {
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (e) {
      // Clear corrupted data
      await _storage.delete(key: _keyUser);
      return null;
    }
  }

  /// Clear all auth data
  Future<void> clear() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyUser);
  }
}
