import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../income/presentation/providers/income_providers.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../../income/domain/entities/income_entry.dart';
import '../../../expenses/domain/entities/expense_entry.dart';
import '../../../khata/presentation/providers/khata_providers.dart';
import '../../../savings/presentation/providers/savings_providers.dart';

final currentBalanceCentsProvider = Provider<int>((ref) {
  final totalIncome = ref.watch(totalIncomeCentsProvider);
  final totalExpenses = ref.watch(totalExpensesCentsProvider);
  final totalYouOwe = ref.watch(totalYouOweCentsProvider);
  final totalOthersOweYou = ref.watch(totalOthersOweYouCentsProvider);
  final totalActiveSavings = ref.watch(totalActiveSavingsCentsProvider);

  // Current Balance = (Income - Expenses) + You Owe - Others Owe You - Active Savings Contributions
  return (totalIncome - totalExpenses) + totalYouOwe - totalOthersOweYou - totalActiveSavings;
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

  String get type => isIncome ? 'income' : 'expense';
  String? get note => subtitle;
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

  final lang = ref.watch(appLanguageProvider);

  for (final inc in incomes) {
    items.add(
      CombinedTransactionItem(
        id: inc.id,
        amountCents: inc.amountCents,
        title: AppTranslations.translateCategory(inc.source, lang),
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
        title: AppTranslations.translateCategory(exp.categoryName, lang),
        subtitle: exp.note ?? (exp.paymentMethod != null ? AppTranslations.translatePaymentMethod(exp.paymentMethod, lang) : null),
        date: exp.date,
        isIncome: false,
        rawEntity: exp,
      ),
    );
  }

  items.sort((a, b) => b.date.compareTo(a.date));

  return items;
});
