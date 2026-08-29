import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../budgets/presentation/screens/budget_management_screen.dart';
import '../../../savings/presentation/screens/savings_goals_screen.dart';
import '../../../reports/presentation/screens/reports_screen.dart';
import '../../../recurring/presentation/screens/recurring_management_screen.dart';
import '../../../security/presentation/screens/security_settings_screen.dart';
import 'backup_restore_screen.dart';
import 'notification_settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('More Options'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'FINANCIAL TOOLS',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
            ),
          ),
          _buildMenuTile(
            context,
            icon: Icons.pie_chart_outline,
            title: 'Reports & Analytics',
            subtitle: 'Category breakdowns, trends & Khata charts',
            color: AppColors.primaryBlue,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportsScreen()),
              );
            },
          ),
          const SizedBox(height: 10),
          _buildMenuTile(
            context,
            icon: Icons.repeat_outlined,
            title: 'Manage Recurring',
            subtitle: 'Auto-recurring income & expense rules',
            color: AppColors.warningAmber,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RecurringManagementScreen()),
              );
            },
          ),
          const SizedBox(height: 10),
          _buildMenuTile(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Budget Management',
            subtitle: 'Set monthly limits & track category spending',
            color: AppColors.primaryBlue,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BudgetManagementScreen()),
              );
            },
          ),
          const SizedBox(height: 10),
          _buildMenuTile(
            context,
            icon: Icons.savings_outlined,
            title: 'Savings Goals',
            subtitle: 'Set target savings & track contributions',
            color: AppColors.successGreen,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavingsGoalsScreen()),
              );
            },
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'PREFERENCES & SETTINGS',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
            ),
          ),
          _buildMenuTile(
            context,
            icon: Icons.notifications_active_outlined,
            title: 'Notification Settings',
            subtitle: 'Budget alerts, Khata & Savings reminders',
            color: AppColors.primaryBlue,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationSettingsScreen()),
              );
            },
          ),
          const SizedBox(height: 10),
          _buildMenuTile(
            context,
            icon: Icons.shield_outlined,
            title: 'PIN & Biometric Security',
            subtitle: 'Protect your financial data offline',
            color: AppColors.warningAmber,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SecuritySettingsScreen()),
              );
            },
          ),
          const SizedBox(height: 10),
          _buildMenuTile(
            context,
            icon: Icons.backup_outlined,
            title: 'Data Backup & Restore',
            subtitle: 'Export & import offline JSON backup files',
            color: AppColors.primaryBlue,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BackupRestoreScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    VoidCallback? onTap,
    bool isDisabled = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isDisabled ? AppColors.textSecondaryLight : color).withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isDisabled ? AppColors.textSecondaryLight : color, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDisabled
                ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
                : (isDark ? AppColors.textMainDark : AppColors.textMainLight),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
        onTap: isDisabled ? null : onTap,
      ),
    );
  }
}
