import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../data/repositories/budget_repository_impl.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return BudgetRepositoryImpl(db);
});

final selectedBudgetMonthYearProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, 1);
});

final watchBudgetsForSelectedMonthProvider = StreamProvider<List<BudgetEntity>>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  final monthYear = ref.watch(selectedBudgetMonthYearProvider);
  return repo.watchBudgetsForMonth(monthYear.month, monthYear.year);
});

class CategoryBudgetProgress {
  final BudgetEntity budget;
  final int spentCents;

  CategoryBudgetProgress({required this.budget, required this.spentCents});

  int get remainingCents => budget.monthlyLimitCents - spentCents;
  double get percentage => budget.monthlyLimitCents > 0 ? (spentCents / budget.monthlyLimitCents) * 100 : 0.0;
  bool get isOverBudget => spentCents > budget.monthlyLimitCents;
}

final categoryBudgetProgressListProvider = Provider<List<CategoryBudgetProgress>>((ref) {
  final budgetsAsync = ref.watch(watchBudgetsForSelectedMonthProvider);
  final expensesAsync = ref.watch(watchAllExpensesProvider);
  final selectedMonthYear = ref.watch(selectedBudgetMonthYearProvider);

  final List<BudgetEntity> budgets = budgetsAsync.maybeWhen(
    data: (list) => list,
    orElse: () => [],
  );

  final allExpenses = expensesAsync.maybeWhen(
    data: (list) => list,
    orElse: () => [],
  );

  // Filter expenses for selected month & year
  final monthExpenses = allExpenses.where((e) {
    return e.date.month == selectedMonthYear.month && e.date.year == selectedMonthYear.year;
  }).toList();

  return budgets.map((budget) {
    final catExpenses = monthExpenses.where((e) {
      return (e.categoryName ?? 'Uncategorized').toLowerCase() == budget.category.toLowerCase();
    });
    int spent = 0;
    for (final e in catExpenses) {
      spent = (spent + e.amountCents).toInt();
    }
    return CategoryBudgetProgress(budget: budget, spentCents: spent);
  }).toList();
});
