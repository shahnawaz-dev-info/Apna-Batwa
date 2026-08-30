import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_translations.dart';
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

  Future<void> _launchContactEmail(String noEmailMsg) async {
    final Uri emailUri = Uri.parse('mailto:info.shahnawaz99@gmail.com?subject=Apna%20Batwa%20Feedback');
    try {
      final launched = await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(noEmailMsg),
            backgroundColor: AppColors.expenseRed,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(noEmailMsg),
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
    final currentLang = ref.watch(appLanguageProvider);
    final tr = ref.watch(translationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('more_title')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // FINANCIAL TOOLS
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              tr('more_section_financial_tools'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
            ),
          ),
          _buildMenuTile(
            context,
            icon: Icons.favorite_border,
            title: tr('more_wishlist_title'),
            subtitle: tr('more_wishlist_sub'),
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
            title: tr('more_recurring_title'),
            subtitle: tr('more_recurring_sub'),
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
            title: tr('more_budget_title'),
            subtitle: tr('more_budget_sub'),
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
            title: tr('more_savings_title'),
            subtitle: tr('more_savings_sub'),
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

          // APPEARANCE & THEME
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              tr('more_section_appearance'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : AppColors.cardLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Theme Mode
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.brightness_6_outlined, color: AppColors.primaryBlue, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      tr('more_theme_mode'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text(tr('more_theme_system'), style: const TextStyle(fontSize: 12)),
                        icon: const Icon(Icons.settings_suggest_outlined, size: 14),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text(tr('more_theme_light'), style: const TextStyle(fontSize: 12)),
                        icon: const Icon(Icons.wb_sunny_outlined, size: 14),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text(tr('more_theme_dark'), style: const TextStyle(fontSize: 12)),
                        icon: const Icon(Icons.dark_mode_outlined, size: 14),
                      ),
                    ],
                    selected: {currentThemeMode},
                    onSelectionChanged: (Set<ThemeMode> newSelection) {
                      ref.read(themeModeProvider.notifier).setThemeMode(newSelection.first);
                    },
                  ),
                ),
                const Divider(height: 20),
                // App Language Selector (2 options: English & Roman Urdu)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.language_outlined, color: AppColors.primaryBlue, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      tr('more_app_language'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<AppLanguage>(
                    segments: [
                      ButtonSegment(
                        value: AppLanguage.english,
                        label: Text(tr('more_lang_english'), style: const TextStyle(fontSize: 13)),
                        icon: const Icon(Icons.translate, size: 14),
                      ),
                      ButtonSegment(
                        value: AppLanguage.romanUrdu,
                        label: Text(tr('more_lang_roman_urdu'), style: const TextStyle(fontSize: 13)),
                        icon: const Icon(Icons.text_fields, size: 14),
                      ),
                    ],
                    selected: {currentLang},
                    onSelectionChanged: (Set<AppLanguage> newSelection) {
                      ref.read(appLanguageProvider.notifier).setLanguage(newSelection.first);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // PREFERENCES & SETTINGS
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              tr('more_section_preferences'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
            ),
          ),
          _buildMenuTile(
            context,
            icon: Icons.notifications_active_outlined,
            title: tr('more_notifications_title'),
            subtitle: tr('more_notifications_sub'),
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
            title: tr('more_security_title'),
            subtitle: tr('more_security_sub'),
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
            title: tr('more_backup_title'),
            subtitle: tr('more_backup_sub'),
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

          // ABOUT & COMMUNITY
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              tr('more_section_about'),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
            ),
          ),
          _buildMenuTile(
            context,
            icon: Icons.share_outlined,
            title: tr('more_share_title'),
            subtitle: tr('more_share_sub'),
            color: AppColors.successGreen,
            isDark: isDark,
            onTap: () {
              Share.share(tr('more_share_message'));
            },
          ),
          const SizedBox(height: 10),
          _buildMenuTile(
            context,
            icon: Icons.mail_outline,
            title: tr('more_contact_title'),
            subtitle: tr('more_contact_sub'),
            color: AppColors.primaryBlue,
            isDark: isDark,
            onTap: () => _launchContactEmail(tr('more_no_email_app')),
          ),
          const SizedBox(height: 10),
          _buildMenuTile(
            context,
            icon: Icons.info_outline,
            title: tr('more_about_title'),
            subtitle: tr('more_about_sub'),
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

          // FOOTER: Version & Credit
          Center(
            child: Column(
              children: [
                Text(
                  '${tr('more_version')} $_version',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tr('more_developer_credit'),
                  style: const TextStyle(
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
