import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/providers/navigation_providers.dart';
import '../../../../core/providers/theme_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../expenses/domain/entities/expense_entry.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../../expenses/presentation/widgets/add_expense_modal.dart';
import '../../../income/domain/entities/income_entry.dart';
import '../../../income/presentation/providers/income_providers.dart';
import '../../../income/presentation/widgets/add_income_modal.dart';
import '../../../khata/presentation/providers/khata_providers.dart';
import '../../../onboarding/presentation/widgets/whats_new_modal.dart';
import '../../../recurring/presentation/providers/recurring_providers.dart';
import '../../../savings/presentation/providers/savings_providers.dart';
import '../../../savings/presentation/screens/savings_goals_screen.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recurringAutoGeneratorProvider).checkAndGenerateDueTransactions();
      _checkWhatsNew();
    });
  }

  Future<void> _checkWhatsNew() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      if (!hasSeenOnboarding) return;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final lastSeenVersion = prefs.getString('last_seen_version');

      if (lastSeenVersion == null || lastSeenVersion != currentVersion) {
        if (mounted) {
          await WhatsNewModal.show(
            context,
            version: currentVersion,
            onDismiss: () async {
              await prefs.setString('last_seen_version', currentVersion);
            },
          );
        }
      }
    } catch (_) {}
  }

  void _showLanguageDialog(BuildContext context, WidgetRef ref, AppLanguage currentLang, String Function(String) tr) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tr('more_app_language'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.translate, color: AppColors.primaryBlue),
                title: Text(tr('more_lang_english'), style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: currentLang == AppLanguage.english
                    ? const Icon(Icons.check_circle, color: AppColors.primaryBlue)
                    : null,
                onTap: () {
                  ref.read(appLanguageProvider.notifier).setLanguage(AppLanguage.english);
                  Navigator.pop(ctx);
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.text_fields, color: AppColors.primaryBlue),
                title: Text(tr('more_lang_roman_urdu'), style: const TextStyle(fontWeight: FontWeight.w600)),
                trailing: currentLang == AppLanguage.romanUrdu
                    ? const Icon(Icons.check_circle, color: AppColors.primaryBlue)
                    : null,
                onTap: () {
                  ref.read(appLanguageProvider.notifier).setLanguage(AppLanguage.romanUrdu);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = ref.watch(translationsProvider);

    final currentBalanceCents = ref.watch(currentBalanceCentsProvider);
    final totalIncomeCents = ref.watch(totalIncomeCentsProvider);
    final totalExpensesCents = ref.watch(totalExpensesCentsProvider);
    final totalYouOweCents = ref.watch(totalYouOweCentsProvider);
    final totalOthersOweYouCents = ref.watch(totalOthersOweYouCentsProvider);
    final totalActiveSavingsCents = ref.watch(totalActiveSavingsCentsProvider);
    final recentTransactions = ref.watch(recentTransactionsProvider);

    final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? false;
    final isHomeTab = ref.watch(selectedMainTabProvider) == 0;
    final shouldInterceptExit = isCurrentRoute && isHomeTab;

    return PopScope(
      canPop: !shouldInterceptExit,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!shouldInterceptExit) return;
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(tr('dashboard_exit_title')),
            content: Text(tr('dashboard_exit_message')),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(tr('common_cancel')),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.expenseRed,
                  foregroundColor: Colors.white,
                ),
                child: Text(tr('dashboard_exit_button')),
              ),
            ],
          ),
        );
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.1) : AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 26,
                    height: 26,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('app_name'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    tr('app_tagline'),
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.language_outlined,
                color: isDark ? Colors.white : AppColors.primaryBlue,
              ),
              tooltip: tr('more_app_language'),
              onPressed: () {
                final currentLang = ref.read(appLanguageProvider);
                _showLanguageDialog(context, ref, currentLang, tr);
              },
            ),
            IconButton(
              icon: Icon(
                isDark ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
                color: isDark ? Colors.amber : AppColors.primaryBlue,
              ),
              tooltip: tr('dashboard_tooltip_theme'),
              onPressed: () {
                ref.read(themeModeProvider.notifier).toggleTheme(context);
              },
            ),
          ],
        ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(watchAllIncomeProvider);
          ref.invalidate(watchAllExpensesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Prominent Current Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? AppColors.balanceGradientDark
                      : AppColors.balanceGradientLight,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryNavy.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tr('dashboard_total_balance'),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(Icons.shield_outlined, color: Colors.white70, size: 18),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.formatCents(currentBalanceCents),
                      style: TextStyle(
                        color: currentBalanceCents < 0 ? AppColors.expenseRed : Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Quick Action Buttons Inside Balance Card
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.successGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => AddIncomeModal.show(context),
                            icon: const Icon(Icons.add_circle, size: 18),
                            label: Text(tr('dashboard_money_in'), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.expenseRed,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => AddExpenseModal.show(context),
                            icon: const Icon(Icons.remove_circle, size: 18),
                            label: Text(tr('dashboard_expense'), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. Summary Grid (Income, Expense, You Owe, Others Owe, Savings)
              Row(
                children: [
                  // Total Income Card -> Transactions (Income sub-tab)
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      title: tr('dashboard_money_in'),
                      amount: CurrencyFormatter.formatCents(totalIncomeCents),
                      icon: Icons.arrow_downward_rounded,
                      color: AppColors.successGreen,
                      onTap: () {
                        ref.read(transactionsSubTabProvider.notifier).state = 1;
                        ref.read(selectedMainTabProvider.notifier).state = 1;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Total Expense Card -> Transactions (Expenses sub-tab)
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      title: tr('dashboard_total_expenses'),
                      amount: CurrencyFormatter.formatCents(totalExpensesCents),
                      icon: Icons.arrow_upward_rounded,
                      color: AppColors.expenseRed,
                      onTap: () {
                        ref.read(transactionsSubTabProvider.notifier).state = 2;
                        ref.read(selectedMainTabProvider.notifier).state = 1;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  // You Owe Card -> Khata (I Borrowed tab)
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      title: tr('dashboard_you_owe'),
                      amount: CurrencyFormatter.formatCents(totalYouOweCents),
                      icon: Icons.handshake_outlined,
                      color: AppColors.expenseRed,
                      onTap: () {
                        ref.read(khataSubTabProvider.notifier).state = 0;
                        ref.read(selectedMainTabProvider.notifier).state = 2;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Others Owe You Card -> Khata (I Lent tab)
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      title: tr('dashboard_others_owe_you'),
                      amount: CurrencyFormatter.formatCents(totalOthersOweYouCents),
                      icon: Icons.account_balance_outlined,
                      color: AppColors.successGreen,
                      onTap: () {
                        ref.read(khataSubTabProvider.notifier).state = 1;
                        ref.read(selectedMainTabProvider.notifier).state = 2;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      title: tr('dashboard_active_savings'),
                      amount: CurrencyFormatter.formatCents(totalActiveSavingsCents),
                      icon: Icons.savings_outlined,
                      color: AppColors.primaryBlue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SavingsGoalsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 3. Recent Transactions Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tr('dashboard_recent_transactions'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                    ),
                  ),
                  Text(
                    tr('dashboard_latest_10'),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 4. Recent Transactions List
              if (recentTransactions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardDark : AppColors.cardLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tr('dashboard_no_transactions'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tr('dashboard_no_transactions_sub'),
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTransactions.take(10).length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = recentTransactions[index];
                    return _buildTransactionTile(context, ref, item, isDark);
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    bool isPlaceholder = false,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPlaceholder
                      ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
                      : (isDark ? AppColors.textMainDark : AppColors.textMainLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTile(
    BuildContext context,
    WidgetRef ref,
    CombinedTransactionItem item,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (item.isIncome ? AppColors.successGreen : AppColors.expenseRed).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            item.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
            color: item.isIncome ? AppColors.successGreen : AppColors.expenseRed,
            size: 20,
          ),
        ),
        title: Text(
          item.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
          ),
        ),
        subtitle: Text(
          '${DateFormatters.formatDate(item.date)}${item.subtitle != null ? " • ${item.subtitle}" : ""}',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          '${item.isIncome ? "+" : "-"}${CurrencyFormatter.formatCents(item.amountCents)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: item.isIncome ? AppColors.successGreen : AppColors.expenseRed,
          ),
        ),
        onTap: () {
          if (item.isIncome) {
            AddIncomeModal.show(context, existingEntry: item.rawEntity as IncomeEntryEntity);
          } else {
            AddExpenseModal.show(context, existingEntry: item.rawEntity as ExpenseEntryEntity);
          }
        },
      ),
    );
  }
}
