import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/local/app_database.dart';
import '../../domain/entities/budget.dart';
import '../../domain/repositories/budget_repository.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final AppDatabase _db;
  final Uuid _uuid = const Uuid();

  BudgetRepositoryImpl(this._db);

  @override
  Stream<List<BudgetEntity>> watchBudgetsForMonth(int month, int year) {
    return _db.watchBudgetsForMonth(month, year).map(
          (rows) => rows
              .map(
                (r) => BudgetEntity(
                  id: r.id,
                  category: r.category,
                  monthlyLimitCents: r.monthlyLimitCents,
                  month: r.month,
                  year: r.year,
                  createdAt: r.createdAt,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<List<BudgetEntity>> getBudgetsForMonth(int month, int year) async {
    final rows = await _db.getBudgetsForMonth(month, year);
    return rows
        .map(
          (r) => BudgetEntity(
            id: r.id,
            category: r.category,
            monthlyLimitCents: r.monthlyLimitCents,
            month: r.month,
            year: r.year,
            createdAt: r.createdAt,
          ),
        )
        .toList();
  }

  @override
  Future<String> setBudget({
    required String category,
    required int monthlyLimitCents,
    required int month,
    required int year,
  }) async {
    final existingBudgets = await _db.getBudgetsForMonth(month, year);
    final match = existingBudgets.where((b) => b.category.toLowerCase() == category.trim().toLowerCase());

    if (match.isNotEmpty) {
      final existing = match.first;
      await _db.updateBudget(
        BudgetsCompanion(
          id: Value(existing.id),
          category: Value(existing.category),
          monthlyLimitCents: Value(monthlyLimitCents),
          month: Value(month),
          year: Value(year),
          createdAt: Value(existing.createdAt),
        ),
      );
      return existing.id;
    } else {
      final id = _uuid.v4();
      final now = DateTime.now();
      await _db.insertBudget(
        BudgetsCompanion.insert(
          id: id,
          category: category.trim(),
          monthlyLimitCents: monthlyLimitCents,
          month: month,
          year: year,
          createdAt: now,
        ),
      );
      return id;
    }
  }

  @override
  Future<int> deleteBudget(String id) async {
    return await _db.deleteBudget(id);
  }
}
