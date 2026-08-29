import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../income/presentation/providers/income_providers.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../../income/domain/entities/income_entry.dart';
import '../../../expenses/domain/entities/expense_entry.dart';
import '../../../khata/presentation/providers/khata_providers.dart';

final currentBalanceCentsProvider = Provider<int>((ref) {
  final totalIncome = ref.watch(totalIncomeCentsProvider);
  final totalExpenses = ref.watch(totalExpensesCentsProvider);
  final totalYouOwe = ref.watch(totalYouOweCentsProvider);
  final totalOthersOweYou = ref.watch(totalOthersOweYouCentsProvider);

  return (totalIncome - totalExpenses) + totalYouOwe - totalOthersOweYou;
});

class CombinedTransactionItem {
  final String id;
  final int amountCents;
  final String title;
  final String? subtitle;
  final DateTime date;
  final bool isIncome;
  final Object rawEntity;

  CombinedTransactionItem({
    required this.id,
    required this.amountCents,
    required this.title,
    this.subtitle,
    required this.date,
    required this.isIncome,
    required this.rawEntity,
  });
}

final recentTransactionsProvider = Provider<List<CombinedTransactionItem>>((ref) {
  final incomeAsync = ref.watch(watchAllIncomeProvider);
  final expenseAsync = ref.watch(watchAllExpensesProvider);

  final List<IncomeEntryEntity> incomes = incomeAsync.maybeWhen(
    data: (list) => list,
    orElse: () => [],
  );

  final List<ExpenseEntryEntity> expenses = expenseAsync.maybeWhen(
    data: (list) => list,
    orElse: () => [],
  );

  final List<CombinedTransactionItem> items = [];

  for (final inc in incomes) {
    items.add(
      CombinedTransactionItem(
        id: inc.id,
        amountCents: inc.amountCents,
        title: inc.source,
        subtitle: inc.note,
        date: inc.date,
        isIncome: true,
        rawEntity: inc,
      ),
    );
  }

  for (final exp in expenses) {
    items.add(
      CombinedTransactionItem(
        id: exp.id,
        amountCents: exp.amountCents,
        title: exp.categoryName ?? 'Expense',
        subtitle: exp.note ?? exp.paymentMethod,
        date: exp.date,
        isIncome: false,
        rawEntity: exp,
      ),
    );
  }

  items.sort((a, b) => b.date.compareTo(a.date));

  return items;
});
