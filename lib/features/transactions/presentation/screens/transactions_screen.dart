import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/providers/navigation_providers.dart';
import '../../../../core/services/csv_export_service.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../income/domain/entities/income_entry.dart';
import '../../../income/presentation/providers/income_providers.dart';
import '../../../income/presentation/widgets/add_income_modal.dart';
import '../../../expenses/domain/entities/expense_entry.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../../expenses/presentation/widgets/add_expense_modal.dart';
import '../providers/transaction_filter_providers.dart';
import '../widgets/transaction_filter_modal.dart';
import '../widgets/bank_receipt_modal.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: ref.read(transactionsSubTabProvider),
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(transactionsSubTabProvider.notifier).state = _tabController.index;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(transactionsSubTabProvider, (prev, next) {
      if (_tabController.index != next) {
        _tabController.animateTo(next);
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tr = ref.watch(translationsProvider);
    final filterState = ref.watch(transactionFilterProvider);
    final filterNotifier = ref.read(transactionFilterProvider.notifier);
    final filteredTransactions = ref.watch(filteredTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('transactions_title')),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: filterState.hasActiveFilters,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => TransactionFilterModal.show(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: tr('transactions_export_tooltip'),
            onSelected: (value) async {
              final list = filteredTransactions;
              if (value == 'pdf') {
                await PdfExportService.instance.exportTransactionsPdf(
                  transactions: list,
                  title: 'Filtered List',
                );
              } else if (value == 'csv') {
                await CsvExportService.instance.exportTransactionsCsv(
                  transactions: list,
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf_outlined, color: AppColors.expenseRed),
                    const SizedBox(width: 10),
                    Text(tr('transactions_export_pdf')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    const Icon(Icons.table_chart_outlined, color: AppColors.successGreen),
                    const SizedBox(width: 10),
                    Text(tr('transactions_export_csv')),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryBlue,
          labelColor: AppColors.primaryBlue,
          unselectedLabelColor:
              isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          tabs: [
            Tab(text: tr('transactions_tab_all')),
            Tab(text: tr('transactions_tab_income')),
            Tab(text: tr('transactions_tab_expenses')),
          ],
        ),
      ),
      body: Column(
        children: [
          // Live Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (val) => filterNotifier.setSearchQuery(val),
              decoration: InputDecoration(
                hintText: tr('transactions_search_hint'),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: filterState.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => filterNotifier.setSearchQuery(''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Applied Filter Chips Bar
          if (filterState.hasActiveFilters)
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ActionChip(
                    label: Text(tr('transactions_clear_all'), style: const TextStyle(color: AppColors.expenseRed, fontWeight: FontWeight.bold)),
                    onPressed: () => filterNotifier.clearAll(),
                    avatar: const Icon(Icons.close, size: 16, color: AppColors.expenseRed),
                    backgroundColor: AppColors.expenseRed.withOpacity(0.1),
                  ),
                  const SizedBox(width: 6),
                  if (filterState.typeFilter != 'all')
                    Chip(
                      label: Text('Type: ${filterState.typeFilter.toUpperCase()}'),
                      onDeleted: () => filterNotifier.setTypeFilter('all'),
                    ),
                  for (final cat in filterState.selectedCategories) ...[
                    const SizedBox(width: 6),
                    Chip(
                      label: Text('${tr('transactions_filter_category')}: ${AppTranslations.translateCategory(cat, ref.watch(appLanguageProvider))}'),
                      onDeleted: () => filterNotifier.toggleCategory(cat),
                    ),
                  ],
                  if (filterState.dateRange != null) ...[
                    const SizedBox(width: 6),
                    Chip(
                      label: Text(
                        'Date: ${DateFormatters.formatShortDate(filterState.dateRange!.start)} - ${DateFormatters.formatShortDate(filterState.dateRange!.end)}',
                      ),
                      onDeleted: () => filterNotifier.setDateRange(null),
                    ),
                  ],
                  if (filterState.minAmountCents != null || filterState.maxAmountCents != null) ...[
                    const SizedBox(width: 6),
                    Chip(
                      label: Text(
                        'Amount: ${filterState.minAmountCents != null ? CurrencyFormatter.formatCents(filterState.minAmountCents!) : '0'} - ${filterState.maxAmountCents != null ? CurrencyFormatter.formatCents(filterState.maxAmountCents!) : '∞'}',
                      ),
                      onDeleted: () => filterNotifier.setAmountRange(null, null),
                    ),
                  ],
                ],
              ),
            ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _AllTransactionsTab(isDark: isDark),
                _IncomeTransactionsTab(isDark: isDark),
                _ExpenseTransactionsTab(isDark: isDark),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_tabController.index == 1) {
            AddIncomeModal.show(context);
          } else if (_tabController.index == 2) {
            AddExpenseModal.show(context);
          } else {
            _showAddChoiceDialog(context, tr);
          }
        },
        icon: const Icon(Icons.add),
        label: Text(tr('transactions_add_entry'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddChoiceDialog(BuildContext context, String Function(String) tr) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tr('transactions_choose_type'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_downward, color: AppColors.successGreen),
                ),
                title: Text(tr('transactions_add_income_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(tr('transactions_add_income_sub')),
                onTap: () {
                  Navigator.pop(ctx);
                  AddIncomeModal.show(context);
                },
              ),
              const Divider(),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.expenseRed.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_upward, color: AppColors.expenseRed),
                ),
                title: Text(tr('transactions_add_expense_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(tr('transactions_add_expense_sub')),
                onTap: () {
                  Navigator.pop(ctx);
                  AddExpenseModal.show(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AllTransactionsTab extends ConsumerWidget {
  final bool isDark;
  const _AllTransactionsTab({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentTransactions = ref.watch(filteredTransactionsProvider);
    final tr = ref.watch(translationsProvider);

    if (recentTransactions.isEmpty) {
      return _buildEmptyState(
        isDark,
        title: tr('transactions_empty_all_title'),
        subtitle: tr('transactions_empty_all_sub'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: recentTransactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = recentTransactions[index];
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
            ),
          ),
          child: ListTile(
            onTap: () => BankReceiptModal.show(context, item),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (item.isIncome ? AppColors.successGreen : AppColors.expenseRed)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                item.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: item.isIncome ? AppColors.successGreen : AppColors.expenseRed,
              ),
            ),
            title: Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Text(
              '${DateFormatters.formatDateTime(item.date)}${item.subtitle != null ? " • ${item.subtitle}" : ""}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${item.isIncome ? "+" : "-"}${CurrencyFormatter.formatCents(item.amountCents)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: item.isIncome ? AppColors.successGreen : AppColors.expenseRed,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.expenseRed, size: 20),
                  onPressed: () async {
                    final confirmed = await _confirmDeleteDialog(context, tr);
                    if (confirmed == true) {
                      if (item.isIncome) {
                        await ref.read(incomeRepositoryProvider).deleteIncome(item.id);
                      } else {
                        await ref.read(expenseRepositoryProvider).deleteExpense(item.id);
                      }
                    }
                  },
                ),
              ],
            ),
            onLongPress: () {
              if (item.isIncome) {
                AddIncomeModal.show(context, existingEntry: item.rawEntity as IncomeEntryEntity);
              } else {
                AddExpenseModal.show(context, existingEntry: item.rawEntity as ExpenseEntryEntity);
              }
            },
          ),
        );
      },
    );
  }
}

class _IncomeTransactionsTab extends ConsumerWidget {
  final bool isDark;
  const _IncomeTransactionsTab({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomeAsync = ref.watch(watchAllIncomeProvider);
    final tr = ref.watch(translationsProvider);

    return incomeAsync.when(
      data: (incomes) {
        if (incomes.isEmpty) {
          return _buildEmptyState(
            isDark,
            title: tr('transactions_empty_income_title'),
            subtitle: tr('transactions_empty_income_sub'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: incomes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = incomes[index];
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: ListTile(
                onTap: () => BankReceiptModal.show(
                  context,
                  CombinedTransactionItem(
                    id: item.id,
                    amountCents: item.amountCents,
                    title: AppTranslations.translateCategory(item.source, ref.watch(appLanguageProvider)),
                    subtitle: item.note,
                    date: item.date,
                    createdAt: item.createdAt,
                    isIncome: true,
                    rawEntity: item,
                  ),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_wallet, color: AppColors.successGreen),
                ),
                title: Text(AppTranslations.translateCategory(item.source, ref.watch(appLanguageProvider)), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${DateFormatters.formatDateTime(item.date)}${item.note != null ? " • ${item.note}" : ""}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '+${CurrencyFormatter.formatCents(item.amountCents)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.successGreen,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.expenseRed, size: 20),
                      onPressed: () async {
                        final confirmed = await _confirmDeleteDialog(context, tr);
                        if (confirmed == true) {
                          await ref.read(incomeRepositoryProvider).deleteIncome(item.id);
                        }
                      },
                    ),
                  ],
                ),
                onLongPress: () => AddIncomeModal.show(context, existingEntry: item),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading income: $err')),
    );
  }
}

class _ExpenseTransactionsTab extends ConsumerWidget {
  final bool isDark;
  const _ExpenseTransactionsTab({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseAsync = ref.watch(watchAllExpensesProvider);
    final tr = ref.watch(translationsProvider);

    return expenseAsync.when(
      data: (expenses) {
        if (expenses.isEmpty) {
          return _buildEmptyState(
            isDark,
            title: tr('transactions_empty_expense_title'),
            subtitle: tr('transactions_empty_expense_sub'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: expenses.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = expenses[index];
            return Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: ListTile(
                onTap: () => BankReceiptModal.show(
                  context,
                  CombinedTransactionItem(
                    id: item.id,
                    amountCents: item.amountCents,
                    title: AppTranslations.translateCategory(item.categoryName, ref.watch(appLanguageProvider)),
                    subtitle: item.note,
                    date: item.date,
                    createdAt: item.createdAt,
                    isIncome: false,
                    rawEntity: item,
                  ),
                ),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.expenseRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, color: AppColors.expenseRed),
                ),
                title: Text(
                  AppTranslations.translateCategory(item.categoryName, ref.watch(appLanguageProvider)),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${DateFormatters.formatDateTime(item.date)}${item.paymentMethod != null ? " [${AppTranslations.translatePaymentMethod(item.paymentMethod, ref.watch(appLanguageProvider))}]" : ""}${item.note != null ? " • ${item.note}" : ""}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '-${CurrencyFormatter.formatCents(item.amountCents)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.expenseRed,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.expenseRed, size: 20),
                      onPressed: () async {
                        final confirmed = await _confirmDeleteDialog(context, tr);
                        if (confirmed == true) {
                          await ref.read(expenseRepositoryProvider).deleteExpense(item.id);
                        }
                      },
                    ),
                  ],
                ),
                onLongPress: () => AddExpenseModal.show(context, existingEntry: item),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading expenses: $err')),
    );
  }
}

Widget _buildEmptyState(bool isDark, {required String title, required String subtitle}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    ),
  );
}

Future<bool?> _confirmDeleteDialog(BuildContext context, String Function(String) tr) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(tr('transactions_delete_title')),
      content: Text(tr('transactions_delete_msg')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(tr('common_cancel')),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.expenseRed),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(tr('common_delete')),
        ),
      ],
    ),
  );
}
