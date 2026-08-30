import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/formatters.dart';
import '../../../expenses/domain/entities/expense_entry.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../../income/domain/entities/income_entry.dart';
import '../../../income/presentation/providers/income_providers.dart';
import '../../../khata/domain/entities/borrowed_record.dart';
import '../../../khata/domain/entities/lent_record.dart';
import '../../../khata/domain/entities/person.dart';
import '../../../khata/presentation/providers/khata_providers.dart';
import 'reports_providers.dart';

enum AnalyticsTimeRangeType {
  thisMonth,
  last3Months,
  last6Months,
  thisYear,
  allTime,
  custom,
}

extension AnalyticsTimeRangeTypeExtension on AnalyticsTimeRangeType {
  String get label {
    switch (this) {
      case AnalyticsTimeRangeType.thisMonth:
        return 'This Month';
      case AnalyticsTimeRangeType.last3Months:
        return 'Last 3 Months';
      case AnalyticsTimeRangeType.last6Months:
        return 'Last 6 Months';
      case AnalyticsTimeRangeType.thisYear:
        return 'This Year';
      case AnalyticsTimeRangeType.allTime:
        return 'All Time';
      case AnalyticsTimeRangeType.custom:
        return 'Custom';
    }
  }
}

class AnalyticsDateRange {
  final AnalyticsTimeRangeType type;
  final DateTime start;
  final DateTime end;

  const AnalyticsDateRange({
    required this.type,
    required this.start,
    required this.end,
  });
}

final analyticsDateRangeProvider = StateProvider<AnalyticsDateRange>((ref) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  return AnalyticsDateRange(
    type: AnalyticsTimeRangeType.thisMonth,
    start: start,
    end: end,
  );
});

// FEATURE 1: Spending Trends (Monthly Comparison & % Change Callout)
class SpendingTrendData {
  final List<MonthlyTrendPoint> monthlyPoints;
  final double percentageChange;
  final String changeCallout;
  final bool isExpenseIncreased;

  SpendingTrendData({
    required this.monthlyPoints,
    required this.percentageChange,
    required this.changeCallout,
    required this.isExpenseIncreased,
  });
}

final spendingTrendsProvider = Provider<SpendingTrendData>((ref) {
  final expensesAsync = ref.watch(watchAllExpensesProvider);
  final List<ExpenseEntryEntity> allExpenses = expensesAsync.maybeWhen(data: (l) => l, orElse: () => <ExpenseEntryEntity>[]);

  final now = DateTime.now();
  final List<MonthlyTrendPoint> points = [];
  final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  // Last 6 months (including current month)
  for (int i = 5; i >= 0; i--) {
    final mDate = DateTime(now.year, now.month - i, 1);
    final label = '${monthNames[mDate.month - 1]} ${mDate.year.toString().substring(2)}';
    int expSum = 0;
    for (final e in allExpenses) {
      if (e.date.year == mDate.year && e.date.month == mDate.month) {
        expSum += e.amountCents;
      }
    }
    points.add(MonthlyTrendPoint(label: label, incomeCents: 0, expenseCents: expSum));
  }

  final currentMonthExpense = points.isNotEmpty ? points.last.expenseCents : 0;
  final prevMonthExpense = points.length >= 2 ? points[points.length - 2].expenseCents : 0;

  double pctChange = 0.0;
  String callout = "No data from previous month";
  bool isIncreased = false;

  if (prevMonthExpense > 0) {
    pctChange = ((currentMonthExpense - prevMonthExpense) / prevMonthExpense) * 100;
    if (pctChange > 0) {
      isIncreased = true;
      callout = "${pctChange.abs().toStringAsFixed(1)}% more than last month";
    } else if (pctChange < 0) {
      isIncreased = false;
      callout = "${pctChange.abs().toStringAsFixed(1)}% less than last month";
    } else {
      callout = "Same as last month";
    }
  } else if (currentMonthExpense > 0) {
    callout = "First month of expense data";
  }

  return SpendingTrendData(
    monthlyPoints: points,
    percentageChange: pctChange,
    changeCallout: callout,
    isExpenseIncreased: isIncreased,
  );
});

// FEATURE 2: Category Breakdown & Auto-Written Insight Sentence
class CategoryInsightData {
  final List<CategoryExpenseReport> items;
  final String? topCategoryName;
  final double topCategoryPercentage;
  final int topCategoryCents;
  final String insightSentence;

  CategoryInsightData({
    required this.items,
    this.topCategoryName,
    required this.topCategoryPercentage,
    required this.topCategoryCents,
    required this.insightSentence,
  });
}

final categoryInsightsProvider = Provider<CategoryInsightData>((ref) {
  final dateRange = ref.watch(analyticsDateRangeProvider);
  final expensesAsync = ref.watch(watchAllExpensesProvider);
  final List<ExpenseEntryEntity> allExpenses = expensesAsync.maybeWhen(data: (l) => l, orElse: () => <ExpenseEntryEntity>[]);

  final rangeExpenses = allExpenses.where((e) {
    return e.date.isAfter(dateRange.start.subtract(const Duration(seconds: 1))) &&
        e.date.isBefore(dateRange.end.add(const Duration(seconds: 1)));
  }).toList();

  final Map<String, int> catTotals = {};
  int grandTotalCents = 0;

  for (final e in rangeExpenses) {
    final catName = e.categoryName ?? 'Uncategorized';
    catTotals[catName] = (catTotals[catName] ?? 0) + e.amountCents;
    grandTotalCents += e.amountCents;
  }

  final List<CategoryExpenseReport> list = [];
  catTotals.forEach((catName, cents) {
    final pct = grandTotalCents > 0 ? (cents / grandTotalCents) * 100 : 0.0;
    list.add(CategoryExpenseReport(
      categoryName: catName,
      totalCents: cents,
      percentage: pct,
    ));
  });

  list.sort((a, b) => b.totalCents.compareTo(a.totalCents));

  if (list.isEmpty || grandTotalCents == 0) {
    return CategoryInsightData(
      items: [],
      topCategoryPercentage: 0.0,
      topCategoryCents: 0,
      insightSentence: "No expense records logged for this period.",
    );
  }

  final topItem = list.first;
  final formattedAmount = CurrencyFormatter.formatCents(topItem.totalCents);
  final sentence =
      "Your highest spending category for this period is ${topItem.categoryName} at ${topItem.percentage.toStringAsFixed(0)}% ($formattedAmount).";

  return CategoryInsightData(
    items: list,
    topCategoryName: topItem.categoryName,
    topCategoryPercentage: topItem.percentage,
    topCategoryCents: topItem.totalCents,
    insightSentence: sentence,
  );
});

// FEATURE 3: Income vs Expense Pattern (by day of week)
class DayOfWeekPatternData {
  final List<int> totalCentsPerDay; // Index 0 = Mon ... 6 = Sun
  final String peakDayName;
  final int peakDayTotalCents;
  final String calloutSentence;

  DayOfWeekPatternData({
    required this.totalCentsPerDay,
    required this.peakDayName,
    required this.peakDayTotalCents,
    required this.calloutSentence,
  });
}

final dayOfWeekPatternProvider = Provider<DayOfWeekPatternData>((ref) {
  final dateRange = ref.watch(analyticsDateRangeProvider);
  final expensesAsync = ref.watch(watchAllExpensesProvider);
  final List<ExpenseEntryEntity> allExpenses = expensesAsync.maybeWhen(data: (l) => l, orElse: () => <ExpenseEntryEntity>[]);

  final rangeExpenses = allExpenses.where((e) {
    return e.date.isAfter(dateRange.start.subtract(const Duration(seconds: 1))) &&
        e.date.isBefore(dateRange.end.add(const Duration(seconds: 1)));
  }).toList();

  final List<int> dayTotals = List.filled(7, 0); // 0=Mon, 6=Sun
  final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  for (final e in rangeExpenses) {
    final weekdayIndex = e.date.weekday - 1; // DateTime.weekday: 1=Mon, 7=Sun
    if (weekdayIndex >= 0 && weekdayIndex < 7) {
      dayTotals[weekdayIndex] += e.amountCents;
    }
  }

  int maxIndex = 0;
  int maxCents = 0;
  for (int i = 0; i < 7; i++) {
    if (dayTotals[i] > maxCents) {
      maxCents = dayTotals[i];
      maxIndex = i;
    }
  }

  String callout = "No expense data for weekday analysis.";
  if (maxCents > 0) {
    callout = "You tend to spend most on ${dayNames[maxIndex]}s (${CurrencyFormatter.formatCents(maxCents)} total).";
  }

  return DayOfWeekPatternData(
    totalCentsPerDay: dayTotals,
    peakDayName: dayNames[maxIndex],
    peakDayTotalCents: maxCents,
    calloutSentence: callout,
  );
});

// FEATURE 4: Khata Insights Summary
class ActiveKhataContact {
  final String personName;
  final String? phoneNumber;
  final int totalVolumeCents;

  ActiveKhataContact({
    required this.personName,
    this.phoneNumber,
    required this.totalVolumeCents,
  });
}

class KhataAnalyticsInsightData {
  final int totalBorrowedCents;
  final int totalLentCents;
  final int totalRepaidCents;
  final int totalReceivedCents;
  final int netPositionCents;
  final List<ActiveKhataContact> topActiveContacts;

  KhataAnalyticsInsightData({
    required this.totalBorrowedCents,
    required this.totalLentCents,
    required this.totalRepaidCents,
    required this.totalReceivedCents,
    required this.netPositionCents,
    required this.topActiveContacts,
  });
}

final khataAnalyticsProvider = Provider<KhataAnalyticsInsightData>((ref) {
  final borrowedAsync = ref.watch(watchAllBorrowedRecordsProvider);
  final lentAsync = ref.watch(watchAllLentRecordsProvider);
  final personsAsync = ref.watch(watchAllPersonsProvider);

  final List<BorrowedRecordEntity> borrowedList = borrowedAsync.maybeWhen(data: (l) => l, orElse: () => <BorrowedRecordEntity>[]);
  final List<LentRecordEntity> lentList = lentAsync.maybeWhen(data: (l) => l, orElse: () => <LentRecordEntity>[]);
  final List<PersonEntity> personsList = personsAsync.maybeWhen(data: (l) => l, orElse: () => <PersonEntity>[]);

  int totalBorrowed = 0;
  int totalRepaid = 0;
  int totalLent = 0;
  int totalReceived = 0;

  final Map<int, int> personVolumeMap = {};

  for (final b in borrowedList) {
    totalBorrowed += b.totalAmountCents;
    totalRepaid += b.paidAmountCents;
    personVolumeMap[b.personId] = (personVolumeMap[b.personId] ?? 0) + b.totalAmountCents + b.paidAmountCents;
  }

  for (final l in lentList) {
    totalLent += l.totalAmountCents;
    totalReceived += l.paidAmountCents;
    personVolumeMap[l.personId] = (personVolumeMap[l.personId] ?? 0) + l.totalAmountCents + l.paidAmountCents;
  }

  final remainingBorrowed = totalBorrowed - totalRepaid;
  final remainingLent = totalLent - totalReceived;
  final netPos = remainingLent - remainingBorrowed;

  final List<ActiveKhataContact> activeContacts = [];
  personVolumeMap.forEach((personId, volume) {
    final p = personsList.firstWhere(
      (person) => person.id == personId,
      orElse: () => PersonEntity(id: personId, name: 'Unknown', createdAt: DateTime.now(), updatedAt: DateTime.now()),
    );
    activeContacts.add(ActiveKhataContact(
      personName: p.name,
      phoneNumber: p.phoneNumber,
      totalVolumeCents: volume,
    ));
  });

  activeContacts.sort((a, b) => b.totalVolumeCents.compareTo(a.totalVolumeCents));

  return KhataAnalyticsInsightData(
    totalBorrowedCents: totalBorrowed,
    totalLentCents: totalLent,
    totalRepaidCents: totalRepaid,
    totalReceivedCents: totalReceived,
    netPositionCents: netPos,
    topActiveContacts: activeContacts.take(3).toList(),
  );
});

// FEATURE 5: Savings Rate
class SavingsRateData {
  final double? savingsRatePercentage;
  final String labelSentence;
  final int totalIncomeCents;
  final int totalExpensesCents;

  SavingsRateData({
    this.savingsRatePercentage,
    required this.labelSentence,
    required this.totalIncomeCents,
    required this.totalExpensesCents,
  });
}

final savingsRateAnalyticsProvider = Provider<SavingsRateData>((ref) {
  final dateRange = ref.watch(analyticsDateRangeProvider);
  final incomeAsync = ref.watch(watchAllIncomeProvider);
  final expensesAsync = ref.watch(watchAllExpensesProvider);

  final List<IncomeEntryEntity> allIncome = incomeAsync.maybeWhen(data: (l) => l, orElse: () => <IncomeEntryEntity>[]);
  final List<ExpenseEntryEntity> allExpenses = expensesAsync.maybeWhen(data: (l) => l, orElse: () => <ExpenseEntryEntity>[]);

  final rangeIncome = allIncome.where((i) {
    return i.date.isAfter(dateRange.start.subtract(const Duration(seconds: 1))) &&
        i.date.isBefore(dateRange.end.add(const Duration(seconds: 1)));
  }).toList();

  final rangeExpenses = allExpenses.where((e) {
    return e.date.isAfter(dateRange.start.subtract(const Duration(seconds: 1))) &&
        e.date.isBefore(dateRange.end.add(const Duration(seconds: 1)));
  }).toList();

  final int totalIncCents = rangeIncome.fold<int>(0, (int sum, item) => sum + item.amountCents);
  final int totalExpCents = rangeExpenses.fold<int>(0, (int sum, item) => sum + item.amountCents);

  if (totalIncCents <= 0) {
    return SavingsRateData(
      savingsRatePercentage: null,
      labelSentence: "Savings rate unavailable — no income recorded for this period.",
      totalIncomeCents: totalIncCents,
      totalExpensesCents: totalExpCents,
    );
  }

  final rate = ((totalIncCents - totalExpCents) / totalIncCents) * 100;
  final sentence = rate >= 0
      ? "You saved ${rate.toStringAsFixed(0)}% of your income this period."
      : "Your expenses exceeded income by ${rate.abs().toStringAsFixed(0)}% this period.";

  return SavingsRateData(
    savingsRatePercentage: rate,
    labelSentence: sentence,
    totalIncomeCents: totalIncCents,
    totalExpensesCents: totalExpCents,
  );
});

// FEATURE 6: Simple Predictive Insight (non-AI, average-based)
class PredictiveInsightData {
  final int? projectedExpenseCents;
  final String insightSentence;
  final bool hasEnoughData;

  PredictiveInsightData({
    this.projectedExpenseCents,
    required this.insightSentence,
    required this.hasEnoughData,
  });
}

// Simple moving-average estimate (non-AI arithmetic projection)
final predictiveInsightProvider = Provider<PredictiveInsightData>((ref) {
  final expensesAsync = ref.watch(watchAllExpensesProvider);
  final List<ExpenseEntryEntity> allExpenses = expensesAsync.maybeWhen(data: (l) => l, orElse: () => <ExpenseEntryEntity>[]);

  if (allExpenses.isEmpty) {
    return PredictiveInsightData(
      projectedExpenseCents: null,
      insightSentence: "Not enough data yet for a projection",
      hasEnoughData: false,
    );
  }

  final now = DateTime.now();

  // Find earliest expense date to check data history span
  DateTime earliestDate = allExpenses.first.date;
  for (final e in allExpenses) {
    if (e.date.isBefore(earliestDate)) earliestDate = e.date;
  }

  final daysSpan = now.difference(earliestDate).inDays;
  if (daysSpan < 25) {
    return PredictiveInsightData(
      projectedExpenseCents: null,
      insightSentence: "Not enough data yet for a projection",
      hasEnoughData: false,
    );
  }

  // Calculate moving average monthly expense over last 3 full months
  int monthsCount = 0;
  int sumExpenseCents = 0;

  for (int i = 1; i <= 3; i++) {
    final mDate = DateTime(now.year, now.month - i, 1);
    int monthTotal = 0;
    for (final e in allExpenses) {
      if (e.date.year == mDate.year && e.date.month == mDate.month) {
        monthTotal += e.amountCents;
      }
    }
    if (monthTotal > 0 || mDate.isAfter(earliestDate)) {
      sumExpenseCents += monthTotal;
      monthsCount++;
    }
  }

  if (monthsCount == 0) {
    return PredictiveInsightData(
      projectedExpenseCents: null,
      insightSentence: "Not enough data yet for a projection",
      hasEnoughData: false,
    );
  }

  // Plain moving-average arithmetic projection
  final averageMonthlyExpenseCents = (sumExpenseCents / monthsCount).round();
  final formattedAmount = CurrencyFormatter.formatCents(averageMonthlyExpenseCents);

  return PredictiveInsightData(
    projectedExpenseCents: averageMonthlyExpenseCents,
    insightSentence: "Based on your recent spending, you're on track to spend around $formattedAmount this month.",
    hasEnoughData: true,
  );
});
