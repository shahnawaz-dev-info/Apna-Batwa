import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../income/presentation/providers/income_providers.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../../income/domain/entities/income_entry.dart';
import '../../../expenses/domain/entities/expense_entry.dart';
import '../../../khata/presentation/providers/khata_providers.dart';
import '../../../savings/presentation/providers/savings_providers.dart';
import '../../../recurring/presentation/providers/recurring_providers.dart';
import '../../../recurring/domain/entities/recurring_transaction.dart';

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

class MomExpenseTrendData {
  final double percentageChange;
  final bool isExpenseIncreased;
  final bool hasPreviousMonthData;
  final bool hasCurrentMonthData;

  MomExpenseTrendData({
    required this.percentageChange,
    required this.isExpenseIncreased,
    required this.hasPreviousMonthData,
    required this.hasCurrentMonthData,
  });
}

final momExpenseTrendProvider = Provider<MomExpenseTrendData>((ref) {
  final expensesAsync = ref.watch(watchAllExpensesProvider);
  final List<ExpenseEntryEntity> allExpenses = expensesAsync.maybeWhen(
    data: (l) => l,
    orElse: () => [],
  );

  final now = DateTime.now();
  final currentMonth = now.month;
  final currentYear = now.year;

  final prevMonthDate = DateTime(currentYear, currentMonth - 1, 1);
  final prevMonth = prevMonthDate.month;
  final prevYear = prevMonthDate.year;

  int currentMonthCents = 0;
  int prevMonthCents = 0;

  for (final e in allExpenses) {
    if (e.date.year == currentYear && e.date.month == currentMonth) {
      currentMonthCents += e.amountCents;
    } else if (e.date.year == prevYear && e.date.month == prevMonth) {
      prevMonthCents += e.amountCents;
    }
  }

  double pctChange = 0.0;
  bool isIncreased = false;

  if (prevMonthCents > 0) {
    pctChange = ((currentMonthCents - prevMonthCents) / prevMonthCents) * 100;
    if (pctChange > 0) isIncreased = true;
  }

  return MomExpenseTrendData(
    percentageChange: pctChange,
    isExpenseIncreased: isIncreased,
    hasPreviousMonthData: prevMonthCents > 0,
    hasCurrentMonthData: currentMonthCents > 0,
  );
});

final financialTipIndexProvider = Provider<int>((ref) {
  final now = DateTime.now();
  final startOfYear = DateTime(now.year, 1, 1);
  final dayOfYear = now.difference(startOfYear).inDays;
  final block6h = now.hour ~/ 6;
  return ((dayOfYear * 4) + block6h) % 20;
});

String getTimeBasedGreetingKey(DateTime time) {
  final hour = time.hour;
  if (hour >= 5 && hour < 11) {
    return 'greeting_morning';
  } else if (hour >= 11 && hour < 17) {
    return 'greeting_afternoon';
  } else if (hour >= 17 && hour < 21) {
    return 'greeting_evening';
  } else {
    return 'greeting_night';
  }
}

final upcomingRecurringProvider = Provider<List<RecurringTransactionEntity>>((ref) {
  final recurringAsync = ref.watch(watchAllRecurringProvider);
  final List<RecurringTransactionEntity> allRecurring = recurringAsync.maybeWhen(
    data: (l) => l,
    orElse: () => [],
  );

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final threeDaysEnd = DateTime(now.year, now.month, now.day + 3, 23, 59, 59);

  final dueList = allRecurring.where((r) {
    if (!r.isActive) return false;
    return !r.nextDueDate.isBefore(todayStart) && !r.nextDueDate.isAfter(threeDaysEnd);
  }).toList();

  dueList.sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
  return dueList;
});
