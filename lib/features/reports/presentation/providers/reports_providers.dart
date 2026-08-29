import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../../income/presentation/providers/income_providers.dart';

enum ReportTimeRange {
  thisMonth,
  lastMonth,
  last3Months,
  thisYear,
}

extension ReportTimeRangeExtension on ReportTimeRange {
  String get label {
    switch (this) {
      case ReportTimeRange.thisMonth:
        return 'This Month';
      case ReportTimeRange.lastMonth:
        return 'Last Month';
      case ReportTimeRange.last3Months:
        return 'Last 3 Months';
      case ReportTimeRange.thisYear:
        return 'This Year';
    }
  }

  DateTimeRange getRange(DateTime now) {
    switch (this) {
      case ReportTimeRange.thisMonth:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
      case ReportTimeRange.lastMonth:
        final start = DateTime(now.year, now.month - 1, 1);
        final end = DateTime(now.year, now.month, 0, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
      case ReportTimeRange.last3Months:
        final start = DateTime(now.year, now.month - 2, 1);
        final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
      case ReportTimeRange.thisYear:
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year, 12, 31, 23, 59, 59);
        return DateTimeRange(start: start, end: end);
    }
  }
}

class DateTimeRange {
  final DateTime start;
  final DateTime end;
  const DateTimeRange({required this.start, required this.end});
}

final reportTimeRangeProvider = StateProvider<ReportTimeRange>((ref) => ReportTimeRange.thisMonth);

class CategoryExpenseReport {
  final String categoryName;
  final int totalCents;
  final double percentage;

  CategoryExpenseReport({
    required this.categoryName,
    required this.totalCents,
    required this.percentage,
  });
}

final categoryExpenseReportProvider = Provider<List<CategoryExpenseReport>>((ref) {
  final rangeType = ref.watch(reportTimeRangeProvider);
  final expensesAsync = ref.watch(watchAllExpensesProvider);

  final allExpenses = expensesAsync.maybeWhen(
    data: (list) => list,
    orElse: () => [],
  );

  final now = DateTime.now();
  final range = rangeType.getRange(now);

  final rangeExpenses = allExpenses.where((e) {
    return e.date.isAfter(range.start.subtract(const Duration(seconds: 1))) &&
        e.date.isBefore(range.end.add(const Duration(seconds: 1)));
  }).toList();

  final Map<String, int> categoryTotals = {};
  int grandTotalCents = 0;

  for (final e in rangeExpenses) {
    final catName = e.categoryName ?? 'Uncategorized';
    final int currentVal = categoryTotals[catName] ?? 0;
    final int amt = e.amountCents;
    categoryTotals[catName] = currentVal + amt;
    grandTotalCents = grandTotalCents + amt;
  }

  final List<CategoryExpenseReport> report = [];
  categoryTotals.forEach((catName, cents) {
    final pct = grandTotalCents > 0 ? (cents / grandTotalCents) * 100 : 0.0;
    report.add(CategoryExpenseReport(
      categoryName: catName,
      totalCents: cents,
      percentage: pct,
    ));
  });

  report.sort((a, b) => b.totalCents.compareTo(a.totalCents));
  return report;
});

class MonthlyTrendPoint {
  final String label;
  final int incomeCents;
  final int expenseCents;

  MonthlyTrendPoint({
    required this.label,
    required this.incomeCents,
    required this.expenseCents,
  });
}

final incomeExpenseTrendProvider = Provider<List<MonthlyTrendPoint>>((ref) {
  final rangeType = ref.watch(reportTimeRangeProvider);
  final incomeAsync = ref.watch(watchAllIncomeProvider);
  final expensesAsync = ref.watch(watchAllExpensesProvider);

  final allIncome = incomeAsync.maybeWhen(data: (l) => l, orElse: () => []);
  final allExpenses = expensesAsync.maybeWhen(data: (l) => l, orElse: () => []);

  final now = DateTime.now();
  final range = rangeType.getRange(now);

  // Group into monthly buckets
  final Map<String, MonthlyTrendPoint> pointsMap = {};

  final List<DateTime> months = [];
  DateTime curr = DateTime(range.start.year, range.start.month, 1);
  while (!curr.isAfter(range.end)) {
    months.add(curr);
    curr = DateTime(curr.year, curr.month + 1, 1);
  }

  final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  for (final m in months) {
    final key = '${m.year}-${m.month}';
    final label = '${monthNames[m.month - 1]} ${m.year.toString().substring(2)}';

    int incSum = 0;
    for (final inc in allIncome) {
      if (inc.date.year == m.year && inc.date.month == m.month) {
        final int amt = inc.amountCents;
        incSum += amt;
      }
    }

    int expSum = 0;
    for (final exp in allExpenses) {
      if (exp.date.year == m.year && exp.date.month == m.month) {
        final int amt = exp.amountCents;
        expSum += amt;
      }
    }

    pointsMap[key] = MonthlyTrendPoint(
      label: label,
      incomeCents: incSum,
      expenseCents: expSum,
    );
  }

  return pointsMap.values.toList();
});
