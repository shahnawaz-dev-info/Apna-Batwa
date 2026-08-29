import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';

class NotificationSettingsState {
  final bool budgetAlerts;
  final bool khataReminders;
  final bool savingsReminders;

  const NotificationSettingsState({
    required this.budgetAlerts,
    required this.khataReminders,
    required this.savingsReminders,
  });

  NotificationSettingsState copyWith({
    bool? budgetAlerts,
    bool? khataReminders,
    bool? savingsReminders,
  }) {
    return NotificationSettingsState(
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      khataReminders: khataReminders ?? this.khataReminders,
      savingsReminders: savingsReminders ?? this.savingsReminders,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<AsyncValue<NotificationSettingsState>> {
  NotificationSettingsNotifier() : super(const AsyncValue.loading()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final service = NotificationService.instance;
      final budget = await service.getBudgetAlertsEnabled();
      final khata = await service.getKhataRemindersEnabled();
      final savings = await service.getSavingsRemindersEnabled();

      state = AsyncValue.data(NotificationSettingsState(
        budgetAlerts: budget,
        khataReminders: khata,
        savingsReminders: savings,
      ));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleBudgetAlerts(bool value) async {
    final current = state.value;
    if (current == null) return;
    await NotificationService.instance.setBudgetAlertsEnabled(value);
    state = AsyncValue.data(current.copyWith(budgetAlerts: value));
  }

  Future<void> toggleKhataReminders(bool value) async {
    final current = state.value;
    if (current == null) return;
    await NotificationService.instance.setKhataRemindersEnabled(value);
    state = AsyncValue.data(current.copyWith(khataReminders: value));
  }

  Future<void> toggleSavingsReminders(bool value) async {
    final current = state.value;
    if (current == null) return;
    await NotificationService.instance.setSavingsRemindersEnabled(value);
    state = AsyncValue.data(current.copyWith(savingsReminders: value));
  }
}

final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, AsyncValue<NotificationSettingsState>>((ref) {
  return NotificationSettingsNotifier();
});
