import '../entities/budget.dart';

abstract class BudgetRepository {
  Stream<List<BudgetEntity>> watchBudgetsForMonth(int month, int year);
  Future<List<BudgetEntity>> getBudgetsForMonth(int month, int year);
  Future<String> setBudget({
    required String category,
    required int monthlyLimitCents,
    required int month,
    required int year,
  });
  Future<int> deleteBudget(String id);
}
