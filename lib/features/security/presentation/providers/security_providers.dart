import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/security_service.dart';

class SecurityState {
  final bool isLocked;
  final bool isPinSet;
  final bool isBiometricSupported;
  final bool isBiometricEnabled;
  final String autoLockDuration;
  final DateTime? pausedAt;

  const SecurityState({
    this.isLocked = false,
    this.isPinSet = false,
    this.isBiometricSupported = false,
    this.isBiometricEnabled = false,
    this.autoLockDuration = 'After 1 minute',
    this.pausedAt,
  });

  SecurityState copyWith({
    bool? isLocked,
    bool? isPinSet,
    bool? isBiometricSupported,
    bool? isBiometricEnabled,
    String? autoLockDuration,
    DateTime? pausedAt,
  }) {
    return SecurityState(
      isLocked: isLocked ?? this.isLocked,
      isPinSet: isPinSet ?? this.isPinSet,
      isBiometricSupported: isBiometricSupported ?? this.isBiometricSupported,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      autoLockDuration: autoLockDuration ?? this.autoLockDuration,
      pausedAt: pausedAt ?? this.pausedAt,
    );
  }
}

class SecurityNotifier extends StateNotifier<SecurityState> {
  SecurityNotifier() : super(const SecurityState()) {
    init();
  }

  final _service = SecurityService.instance;

  Future<void> init() async {
    final pinSet = await _service.isPinSet();
    final bioSupported = await _service.canCheckBiometrics();
    final bioEnabled = await _service.isBiometricEnabled();
    final autoLock = await _service.getAutoLockDuration();

    state = state.copyWith(
      isPinSet: pinSet,
      isBiometricSupported: bioSupported,
      isBiometricEnabled: bioEnabled,
      autoLockDuration: autoLock,
      isLocked: pinSet, // Require lock screen on launch if PIN is set
    );
  }

  Future<bool> verifyAndUnlock(String pin) async {
    final valid = await _service.verifyPin(pin);
    if (valid) {
      state = state.copyWith(isLocked: false);
      return true;
    }
    return false;
  }

  Future<bool> unlockWithBiometrics() async {
    if (!state.isBiometricEnabled || !state.isBiometricSupported) return false;
    final success = await _service.authenticateWithBiometrics();
    if (success) {
      state = state.copyWith(isLocked: false);
      return true;
    }
    return false;
  }

  Future<void> setPin(String pin) async {
    await _service.setPin(pin);
    await init();
  }

  Future<void> removePin() async {
    await _service.removePin();
    state = state.copyWith(isLocked: false);
    await init();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _service.setBiometricEnabled(enabled);
    state = state.copyWith(isBiometricEnabled: enabled);
  }

  Future<void> setAutoLockDuration(String duration) async {
    await _service.setAutoLockDuration(duration);
    state = state.copyWith(autoLockDuration: duration);
  }

  void handleAppLifecycle(AppLifecycleState lifecycle) {
    if (!state.isPinSet) return;

    if (lifecycle == AppLifecycleState.paused || lifecycle == AppLifecycleState.inactive) {
      if (state.pausedAt == null) {
        state = state.copyWith(pausedAt: DateTime.now());
      }
    } else if (lifecycle == AppLifecycleState.resumed) {
      final paused = state.pausedAt;
      state = state.copyWith(pausedAt: null);

      if (paused != null && !state.isLocked) {
        final elapsedSeconds = DateTime.now().difference(paused).inSeconds;
        bool shouldLock = false;

        switch (state.autoLockDuration) {
          case 'Immediately':
            shouldLock = true;
            break;
          case 'After 1 minute':
            shouldLock = elapsedSeconds >= 60;
            break;
          case 'After 5 minutes':
            shouldLock = elapsedSeconds >= 300;
            break;
          case 'Never':
            shouldLock = false;
            break;
        }

        if (shouldLock) {
          state = state.copyWith(isLocked: true);
        }
      }
    }
  }
}

final securityProvider = StateNotifierProvider<SecurityNotifier, SecurityState>((ref) {
  return SecurityNotifier();
});
