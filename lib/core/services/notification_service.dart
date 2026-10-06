import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../theme/colors.dart';
import '../utils/formatters.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _keyBudgetAlerts = 'notif_budget_alerts';
  static const String _keyKhataReminders = 'notif_khata_reminders';
  static const String _keySavingsReminders = 'notif_savings_reminders';

  Future<void> init() async {
    if (kIsWeb) return;
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification click if needed
      },
    );

    _initialized = true;
  }

  // Preference Settings
  Future<bool> getBudgetAlertsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBudgetAlerts) ?? true;
  }

  Future<void> setBudgetAlertsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBudgetAlerts, enabled);
  }

  Future<bool> getKhataRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyKhataReminders) ?? true;
  }

  Future<void> setKhataRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyKhataReminders, enabled);
  }

  Future<bool> getSavingsRemindersEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySavingsReminders) ?? true;
  }

  Future<void> setSavingsRemindersEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySavingsReminders, enabled);
  }

  // Graceful Permission Request with Explanation Dialog
  Future<bool> requestPermissionWithExplanation(BuildContext context) async {
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.areNotificationsEnabled() ?? false;
      if (granted) return true;

      // Show rationale dialog before calling system prompt
      if (context.mounted) {
        final shouldProceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.notifications_active, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                const Text('Enable Notifications'),
              ],
            ),
            content: const Text(
              'Apna Batwa would like to send you helpful reminders about your budget limits, Khata repayments, and savings goals.\n\nAll notifications are 100% offline and stored on your device.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Not Now'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: Colors.white),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Allow'),
              ),
            ],
          ),
        );

        if (shouldProceed != true) return false;
      }

      final result = await androidPlugin.requestNotificationsPermission();
      return result ?? false;
    }
    return true;
  }

  // Trigger A: Budget Limit Warning
  Future<void> triggerBudgetWarningNotification({
    required String categoryName,
    required int percentage,
    required int limitCents,
    required int spentCents,
  }) async {
    final enabled = await getBudgetAlertsEnabled();
    if (!enabled) return;

    final String title = percentage >= 100
        ? '⚠️ Budget Limit Exceeded!'
        : '⚠️ Budget Alert: $percentage% Used';

    final String body = percentage >= 100
        ? 'You have exceeded your $categoryName budget! Spent: ${CurrencyFormatter.formatCents(spentCents)} of ${CurrencyFormatter.formatCents(limitCents)}'
        : 'You have used $percentage% of your $categoryName budget (${CurrencyFormatter.formatCents(spentCents)} / ${CurrencyFormatter.formatCents(limitCents)})';

    const androidDetails = AndroidNotificationDetails(
      'budget_alerts',
      'Budget Alerts',
      channelDescription: 'Notifications when monthly budget threshold or limit is reached',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);
    await _notificationsPlugin.show(
      categoryName.hashCode,
      title,
      body,
      notificationDetails,
    );
  }

  // Trigger B: Scheduled Khata Reminder
  Future<void> scheduleKhataReminder({
    required int notificationId,
    required String personName,
    required int amountCents,
    required bool isBorrowed, // true = You owe, false = Owed to you
    required DateTime reminderDate,
  }) async {
    final enabled = await getKhataRemindersEnabled();
    if (!enabled) return;

    if (reminderDate.isBefore(DateTime.now())) return;

    final title = isBorrowed ? 'Khata Repayment Reminder' : 'Khata Collection Reminder';
    final body = isBorrowed
        ? 'Reminder: You owe $personName ${CurrencyFormatter.formatCents(amountCents)}'
        : 'Reminder: $personName owes you ${CurrencyFormatter.formatCents(amountCents)}';

    const androidDetails = AndroidNotificationDetails(
      'khata_reminders',
      'Khata Reminders',
      channelDescription: 'Scheduled reminders for borrowed and lent repayments',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    final scheduledTZ = tz.TZDateTime.from(reminderDate, tz.local);

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledTZ,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Trigger C: Savings Goal Target Date Reminder
  Future<void> scheduleSavingsReminder({
    required int notificationId,
    required String goalName,
    required DateTime targetDate,
  }) async {
    final enabled = await getSavingsRemindersEnabled();
    if (!enabled) return;

    // Schedule 3 days before target date at 9 AM
    final reminderDate = targetDate.subtract(const Duration(days: 3));
    final scheduledDate = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      9,
      0,
    );

    if (scheduledDate.isBefore(DateTime.now())) return;

    const title = '🎯 Savings Goal Reminder';
    final body = 'Target date for "$goalName" is approaching in 3 days! Check your progress.';

    const androidDetails = AndroidNotificationDetails(
      'savings_reminders',
      'Savings Reminders',
      channelDescription: 'Reminders for savings goal target dates',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);
    final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledTZ,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}
