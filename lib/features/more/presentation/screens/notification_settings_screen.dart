import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/notification_providers.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/colors.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsAsync = ref.watch(notificationSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryBlue.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: AppColors.primaryBlue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All notifications run 100% offline on your device. No cloud or Firebase server required.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildSectionHeader('ALERT CATEGORIES'),
            const SizedBox(height: 8),

            _buildToggleCard(
              context,
              isDark: isDark,
              title: 'Budget Limit Warnings',
              subtitle: 'Get notified when spending reaches 90%+ or 100% of category monthly budget limit',
              icon: Icons.pie_chart_outline,
              color: AppColors.warningAmber,
              value: settings.budgetAlerts,
              onChanged: (val) async {
                final granted = await NotificationService.instance.requestPermissionWithExplanation(context);
                if (granted) {
                  ref.read(notificationSettingsProvider.notifier).toggleBudgetAlerts(val);
                }
              },
            ),
            const SizedBox(height: 12),

            _buildToggleCard(
              context,
              isDark: isDark,
              title: 'Khata Repayment Reminders',
              subtitle: 'Receive scheduled alerts for borrowed and lent money due dates',
              icon: Icons.menu_book_outlined,
              color: AppColors.primaryBlue,
              value: settings.khataReminders,
              onChanged: (val) async {
                final granted = await NotificationService.instance.requestPermissionWithExplanation(context);
                if (granted) {
                  ref.read(notificationSettingsProvider.notifier).toggleKhataReminders(val);
                }
              },
            ),
            const SizedBox(height: 12),

            _buildToggleCard(
              context,
              isDark: isDark,
              title: 'Savings Goal Reminders',
              subtitle: 'Get reminded 3 days before a savings target date approaches',
              icon: Icons.savings_outlined,
              color: AppColors.successGreen,
              value: settings.savingsReminders,
              onChanged: (val) async {
                final granted = await NotificationService.instance.requestPermissionWithExplanation(context);
                if (granted) {
                  ref.read(notificationSettingsProvider.notifier).toggleSavingsReminders(val);
                }
              },
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
      ),
    );
  }

  Widget _buildToggleCard(
    BuildContext context, {
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        secondary: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: color,
      ),
    );
  }
}
