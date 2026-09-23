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
import '../../../budgets/presentation/providers/budget_providers.dart';
import '../../../transactions/presentation/widgets/bank_receipt_modal.dart';
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
    final lang = ref.watch(appLanguageProvider);

    final currentBalanceCents = ref.watch(currentBalanceCentsProvider);
    final totalIncomeCents = ref.watch(totalIncomeCentsProvider);
    final totalExpensesCents = ref.watch(totalExpensesCentsProvider);
    final totalYouOweCents = ref.watch(totalYouOweCentsProvider);
    final totalOthersOweYouCents = ref.watch(totalOthersOweYouCentsProvider);
    final totalActiveSavingsCents = ref.watch(totalActiveSavingsCentsProvider);
    final recentTransactions = ref.watch(recentTransactionsProvider);
    final momTrend = ref.watch(momExpenseTrendProvider);

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
          ref.invalidate(watchAllBorrowedRecordsProvider);
          ref.invalidate(watchAllLentRecordsProvider);
          ref.invalidate(watchBudgetsForSelectedMonthProvider);
          ref.invalidate(watchAllRecurringProvider);
          ref.invalidate(watchAllSavingsGoalsProvider);
          ref.invalidate(watchAllSavingsContributionsProvider);
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 0. Time-based Greeting
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  tr(getTimeBasedGreetingKey(DateTime.now())),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                  ),
                ),
              ),

              // 1. Bank-Grade Realistic Virtual Debit Card
              _buildVirtualDebitCard(
                context,
                ref,
                currentBalanceCents: currentBalanceCents,
                momTrend: momTrend,
              ),

              const SizedBox(height: 14),

              // Bank Quick Action Pills
              Row(
                children: [
                  Expanded(
                    child: _buildActionPill(
                      context,
                      icon: Icons.add_rounded,
                      label: tr('dashboard_money_in'),
                      color: AppColors.successGreen,
                      onTap: () => AddIncomeModal.show(context),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionPill(
                      context,
                      icon: Icons.remove_rounded,
                      label: tr('dashboard_expense'),
                      color: AppColors.expenseRed,
                      onTap: () => AddExpenseModal.show(context),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionPill(
                      context,
                      icon: Icons.menu_book_rounded,
                      label: 'Khata',
                      color: AppColors.primaryBlue,
                      onTap: () => ref.read(selectedMainTabProvider.notifier).state = 2,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildActionPill(
                      context,
                      icon: Icons.bar_chart_rounded,
                      label: 'Reports',
                      color: AppColors.warningAmber,
                      onTap: () => ref.read(selectedMainTabProvider.notifier).state = 3,
                      isDark: isDark,
                    ),
                  ),
                ],
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

              const SizedBox(height: 16),

              // 3. Budget Mini-Progress Indicator
              _buildBudgetMiniProgress(context, ref, lang, isDark),

              // 4. Upcoming Recurring Payment Banner
              _buildRecurringBanner(context, ref, lang, isDark),

              // 5. Rotating Financial Tip Banner
              _buildFinancialTipBanner(context, ref, lang, isDark),

              const SizedBox(height: 8),

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
                  InkWell(
                    onTap: () {
                      ref.read(selectedMainTabProvider.notifier).state = 1;
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Text(
                        tr('common_show_all'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 4. Recent Transactions List (Single Most Recent Entry)
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
                  itemCount: recentTransactions.take(1).length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = recentTransactions[index];
                    return _buildTransactionTile(context, ref, item, isDark);
                  },
                ),

              const SizedBox(height: 28),
              Center(
                child: Text(
                  tr('app_powered_by'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight).withOpacity(0.7),
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
          '${DateFormatters.formatDateTime(item.date)}${item.subtitle != null ? " • ${item.subtitle}" : ""}',
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
        onTap: () => BankReceiptModal.show(context, item),
        onLongPress: () {
          if (item.isIncome) {
            AddIncomeModal.show(context, existingEntry: item.rawEntity as IncomeEntryEntity);
          } else {
            AddExpenseModal.show(context, existingEntry: item.rawEntity as ExpenseEntryEntity);
          }
        },
      ),
    );
  }

  Widget _buildBudgetMiniProgress(BuildContext context, WidgetRef ref, AppLanguage lang, bool isDark) {
    final budgetList = ref.watch(categoryBudgetProgressListProvider);
    if (budgetList.isEmpty) return const SizedBox.shrink();

    CategoryBudgetProgress? topBudget;
    for (final b in budgetList) {
      if (topBudget == null || b.percentage > topBudget.percentage) {
        topBudget = b;
      }
    }

    if (topBudget == null || topBudget.budget.monthlyLimitCents <= 0) {
      return const SizedBox.shrink();
    }

    final categoryName = AppTranslations.translateCategory(topBudget.budget.category, lang);
    final pct = topBudget.percentage;

    Color progressColor;
    if (pct < 80) {
      progressColor = AppColors.successGreen;
    } else if (pct <= 100) {
      progressColor = AppColors.warningAmber;
    } else {
      progressColor = AppColors.expenseRed;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.pie_chart_outline, size: 16, color: progressColor),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${AppTranslations.tr('dashboard_top_budget', lang)}: $categoryName',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${pct.toStringAsFixed(0)}% ${AppTranslations.tr('dashboard_budget_used', lang)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: progressColor.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurringBanner(BuildContext context, WidgetRef ref, AppLanguage lang, bool isDark) {
    final upcomingList = ref.watch(upcomingRecurringProvider);
    if (upcomingList.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningAmber.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.warningAmber.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_active_outlined, size: 18, color: AppColors.warningAmber),
              const SizedBox(width: 8),
              Text(
                AppTranslations.tr('recurring_banner_title', lang),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.warningAmber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...upcomingList.take(2).map((item) {
            final itemDate = DateTime(item.nextDueDate.year, item.nextDueDate.month, item.nextDueDate.day);
            final daysDiff = itemDate.difference(todayStart).inDays;

            String dueText;
            if (daysDiff <= 0) {
              dueText = AppTranslations.tr('recurring_due_today', lang);
            } else if (daysDiff == 1) {
              dueText = AppTranslations.tr('recurring_due_tomorrow', lang);
            } else {
              dueText = lang == AppLanguage.romanUrdu ? '$daysDiff din mein due hai' : 'due in $daysDiff days';
            }

            return Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${item.name} — ${CurrencyFormatter.formatCents(item.amountCents)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    dueText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.warningAmber,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFinancialTipBanner(BuildContext context, WidgetRef ref, AppLanguage lang, bool isDark) {
    final tipIndex = ref.watch(financialTipIndexProvider);
    final tipKey = 'tip_${tipIndex + 1}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outlined,
              size: 20,
              color: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppTranslations.tr('dashboard_tip_title', lang),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppTranslations.tr(tipKey, lang),
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.3,
                    color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVirtualDebitCard(
    BuildContext context,
    WidgetRef ref, {
    required int currentBalanceCents,
    required MomExpenseTrendData momTrend,
  }) {
    final activeBank = ref.watch(activeBankConfigProvider);
    final isHidden = ref.watch(isBalanceHiddenProvider);
    final cardholderName = ref.watch(cardholderNameProvider);
    final tr = ref.watch(translationsProvider);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: activeBank.cardGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: activeBank.primaryColor.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              activeBank.bankIcon,
              size: 150,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(activeBank.bankIcon, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeBank.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              activeBank.subtitle,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.contactless_rounded,
                          color: Colors.white70,
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 36,
                          height: 27,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFFD54F), width: 0.8),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFFE082), Color(0xFFFFB300), Color(0xFFFFC107)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(1, 1),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Container(
                                  width: 16,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.black26, width: 0.8),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 6,
                                top: 0,
                                bottom: 0,
                                child: Container(width: 0.8, color: Colors.black26),
                              ),
                              Positioned(
                                right: 6,
                                top: 0,
                                bottom: 0,
                                child: Container(width: 0.8, color: Colors.black26),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      tr('dashboard_total_balance').toUpperCase(),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () => ref.read(isBalanceHiddenProvider.notifier).toggle(),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              size: 13,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isHidden ? 'Show' : 'Hide',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  isHidden
                      ? 'Rs ••••••••'
                      : CurrencyFormatter.formatCents(currentBalanceCents),
                  style: TextStyle(
                    color: !isHidden && currentBalanceCents < 0 ? const Color(0xFFFF8A80) : Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                if (momTrend.hasPreviousMonthData && !isHidden) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        momTrend.isExpenseIncreased ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: momTrend.isExpenseIncreased ? const Color(0xFFFF8A80) : const Color(0xFF69F0AE),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${momTrend.percentageChange.abs().toStringAsFixed(0)}% ${tr(momTrend.isExpenseIncreased ? 'dashboard_trend_higher' : 'dashboard_trend_lower')}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: momTrend.isExpenseIncreased ? const Color(0xFFFF8A80) : const Color(0xFF69F0AE),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '••••  ••••  ••••  4921',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        letterSpacing: 2.2,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      'EXP 12/29',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => _showEditCardholderDialog(context, ref, cardholderName),
                      borderRadius: BorderRadius.circular(6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cardholderName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.5,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.edit_outlined, size: 12, color: Colors.white.withOpacity(0.7)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'DEBIT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionPill(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditCardholderDialog(BuildContext context, WidgetRef ref, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Cardholder Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Cardholder Name',
            hintText: 'Enter your name',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                ref.read(cardholderNameProvider.notifier).setName(newName);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
