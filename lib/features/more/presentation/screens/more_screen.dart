import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/providers/theme_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../budgets/presentation/screens/budget_management_screen.dart';
import '../../../recurring/presentation/screens/recurring_management_screen.dart';
import '../../../wishlist/presentation/screens/wishlist_screen.dart';
import '../../../savings/presentation/screens/savings_goals_screen.dart';
import '../../../security/presentation/screens/security_settings_screen.dart';
import 'about_screen.dart';
import 'backup_restore_screen.dart';
import 'notification_settings_screen.dart';

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  String _version = '1.1.0';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      setState(() {
        _version = info.version;
      });
    } catch (_) {}
  }

  Future<void> _launchContactEmail() async {
    final Uri emailUri = Uri.parse('mailto:info.shahnawaz99@gmail.com?subject=Apna%20Batwa%20Feedback');
    try {
      final launched = await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No email app available on this device'),
            backgroundColor: AppColors.expenseRed,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No email app available on this device'),
            backgroundColor: AppColors.expenseRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentThemeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('More Options'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // FINANCIAL TOOLS
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'FINANCIAL TOOLS',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
            ),
          ),
          _buildMenuTile(
            context,
            icon: Icons.favorite_border,
            title: 'Wishlist & Shopping',
            subtitle: 'Track desired items & purchase history',
            color: AppColors.primaryBlue,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WishlistScreen()),
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

          // APPEARANCE & THEME (Feature 7)
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'APPEARANCE & THEME',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.brightness_6_outlined, color: AppColors.primaryBlue, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'App Theme Mode',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('System'),
                      icon: Icon(Icons.settings_suggest_outlined, size: 16),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Light'),
                      icon: Icon(Icons.wb_sunny_outlined, size: 16),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode_outlined, size: 16),
                    ),
                  ],
                  selected: {currentThemeMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    ref.read(themeModeProvider.notifier).setThemeMode(newSelection.first);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // PREFERENCES & SETTINGS
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

          const SizedBox(height: 24),

          // ABOUT & COMMUNITY (Feature 3, 4, 5)
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'ABOUT & COMMUNITY',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
            ),
          ),
          _buildMenuTile(
            context,
            icon: Icons.share_outlined,
            title: 'Share App',
            subtitle: 'Share Apna Batwa with friends & family',
            color: AppColors.successGreen,
            isDark: isDark,
            onTap: () {
              Share.share('Check out Apna Batwa — a free offline personal finance app for students to track income, expenses, and Khata!');
            },
          ),
          const SizedBox(height: 10),
          _buildMenuTile(
            context,
            icon: Icons.mail_outline,
            title: 'Contact / Feedback',
            subtitle: 'Send feedback directly to info.shahnawaz99@gmail.com',
            color: AppColors.primaryBlue,
            isDark: isDark,
            onTap: _launchContactEmail,
          ),
          const SizedBox(height: 10),
          _buildMenuTile(
            context,
            icon: Icons.info_outline,
            title: 'About Apna Batwa',
            subtitle: 'App details, version info & privacy details',
            color: AppColors.warningAmber,
            isDark: isDark,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),

          const SizedBox(height: 32),

          // FOOTER: Version & Credit (Feature 1 & 2)
          Center(
            child: Column(
              children: [
                Text(
                  'Version $_version',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Developed by SN Technologies',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
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
