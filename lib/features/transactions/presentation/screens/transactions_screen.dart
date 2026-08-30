import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    final filterState = ref.watch(transactionFilterProvider);
    final filterNotifier = ref.read(transactionFilterProvider.notifier);
    final filteredTransactions = ref.watch(filteredTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
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
            tooltip: 'Export Transactions',
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
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'pdf',
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf_outlined, color: AppColors.expenseRed),
                    SizedBox(width: 10),
                    Text('Export as PDF'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'csv',
                child: Row(
                  children: [
                    Icon(Icons.table_chart_outlined, color: AppColors.successGreen),
                    SizedBox(width: 10),
                    Text('Export as CSV'),
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
          tabs: const [
            Tab(text: 'All History'),
            Tab(text: 'Income'),
            Tab(text: 'Expenses'),
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
                hintText: 'Search transactions by name, note, or category...',
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
                    label: const Text('Clear All', style: TextStyle(color: AppColors.expenseRed, fontWeight: FontWeight.bold)),
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
                      label: Text('Cat: $cat'),
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
            _showAddChoiceDialog(context);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Entry', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showAddChoiceDialog(BuildContext context) {
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
              const Text(
                'Choose Transaction Type',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                title: const Text('Add Income / Money In', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Pocket money, salary, gifts, scholarship'),
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
                title: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('Food, transport, hostel, shopping, etc.'),
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

    if (recentTransactions.isEmpty) {
      return _buildEmptyState(
        isDark,
        title: 'No Transactions Yet 📝',
        subtitle: 'Apna pehla income ya kharcha log karein!',
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
              '${DateFormatters.formatDate(item.date)}${item.subtitle != null ? " • ${item.subtitle}" : ""}',
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
                    final confirmed = await _confirmDeleteDialog(context);
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
            onTap: () {
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

    return incomeAsync.when(
      data: (incomes) {
        if (incomes.isEmpty) {
          return _buildEmptyState(
            isDark,
            title: 'No Income Entries 💰',
            subtitle: 'Apna pehla income add karein!',
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
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.account_balance_wallet, color: AppColors.successGreen),
                ),
                title: Text(item.source, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  '${DateFormatters.formatDate(item.date)}${item.note != null ? " • ${item.note}" : ""}',
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
                        final confirmed = await _confirmDeleteDialog(context);
                        if (confirmed == true) {
                          await ref.read(incomeRepositoryProvider).deleteIncome(item.id);
                        }
                      },
                    ),
                  ],
                ),
                onTap: () => AddIncomeModal.show(context, existingEntry: item),
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

    return expenseAsync.when(
      data: (expenses) {
        if (expenses.isEmpty) {
          return _buildEmptyState(
            isDark,
            title: 'No Expenses Recorded 🛒',
            subtitle: 'Koi kharcha nahi hai — sub set hai!',
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
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.expenseRed.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, color: AppColors.expenseRed),
                ),
                title: Text(
                  item.categoryName ?? 'Expense',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${DateFormatters.formatDate(item.date)}${item.paymentMethod != null ? " [${item.paymentMethod}]" : ""}${item.note != null ? " • ${item.note}" : ""}',
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
                        final confirmed = await _confirmDeleteDialog(context);
                        if (confirmed == true) {
                          await ref.read(expenseRepositoryProvider).deleteExpense(item.id);
                        }
                      },
                    ),
                  ],
                ),
                onTap: () => AddExpenseModal.show(context, existingEntry: item),
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

Future<bool?> _confirmDeleteDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete Entry'),
      content: const Text('Are you sure you want to delete this transaction entry?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.expenseRed),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}
