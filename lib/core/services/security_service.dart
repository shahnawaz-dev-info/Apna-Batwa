import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  static final SecurityService instance = SecurityService._internal();
  SecurityService._internal();

  final _secureStorage = const FlutterSecureStorage();
  final _localAuth = LocalAuthentication();

  static const String _pinHashKey = 'security_pin_hash_v1';
  static const String _biometricEnabledKey = 'security_biometric_enabled_v1';
  static const String _autoLockDurationKey = 'security_auto_lock_duration_v1';
  static const String _salt = 'apna_batwa_secure_salt_2026_v1';

  // Hashing helper
  String _hashPin(String pin) {
    final bytes = utf8.encode(pin + _salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // --- PIN LOCK ---
  Future<bool> isPinSet() async {
    final hash = await _secureStorage.read(key: _pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  Future<bool> verifyPin(String pin) async {
    final storedHash = await _secureStorage.read(key: _pinHashKey);
    if (storedHash == null) return false;
    return storedHash == _hashPin(pin);
  }

  Future<void> setPin(String pin) async {
    final hash = _hashPin(pin);
    await _secureStorage.write(key: _pinHashKey, value: hash);

    // Set default auto-lock to 'After 1 minute' when PIN is first created
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_autoLockDurationKey)) {
      await prefs.setString(_autoLockDurationKey, 'After 1 minute');
    }
  }

  Future<void> removePin() async {
    await _secureStorage.delete(key: _pinHashKey);
    await setBiometricEnabled(false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_autoLockDurationKey, 'Never');
  }

  // --- BIOMETRICS ---
  Future<bool> canCheckBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final canAuth = await canCheckBiometrics();
      if (!canAuth) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Unlock Apna Batwa',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  // --- AUTO-LOCK DURATION ---
  Future<String> getAutoLockDuration() async {
    final prefs = await SharedPreferences.getInstance();
    final pinSet = await isPinSet();
    if (!pinSet) return 'Never';
    return prefs.getString(_autoLockDurationKey) ?? 'After 1 minute';
  }

  Future<void> setAutoLockDuration(String duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_autoLockDurationKey, duration);
  }
}
