import 'package:drift/drift.dart';
import '../../../../data/local/app_database.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense_entry.dart';
import '../../domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final AppDatabase _db;

  ExpenseRepositoryImpl(this._db);

  @override
  Stream<List<ExpenseEntryEntity>> watchAllExpenses() {
    return _db.watchAllExpenseEntries().asyncMap((rows) async {
      final categories = await getCategories();
      final categoryMap = {for (var c in categories) c.id: c.name};

      return rows.map((r) => _mapToEntity(r, categoryMap[r.categoryId])).toList();
    });
  }

  @override
  Future<List<ExpenseEntryEntity>> getAllExpenses() async {
    final rows = await _db.getAllExpenseEntries();
    final categories = await getCategories();
    final categoryMap = {for (var c in categories) c.id: c.name};

    return rows.map((r) => _mapToEntity(r, categoryMap[r.categoryId])).toList();
  }

  @override
  Future<void> addExpense(ExpenseEntryEntity expense) async {
    await _db.insertExpenseEntry(
      ExpenseEntriesCompanion.insert(
        id: expense.id,
        amountCents: expense.amountCents,
        categoryId: expense.categoryId,
        date: expense.date,
        note: Value(expense.note),
        paymentMethod: Value(expense.paymentMethod),
        createdAt: expense.createdAt,
        updatedAt: expense.updatedAt,
      ),
    );
  }

  @override
  Future<void> updateExpense(ExpenseEntryEntity expense) async {
    await _db.updateExpenseEntry(
      ExpenseEntriesCompanion(
        id: Value(expense.id),
        amountCents: Value(expense.amountCents),
        categoryId: Value(expense.categoryId),
        date: Value(expense.date),
        note: Value(expense.note),
        paymentMethod: Value(expense.paymentMethod),
        createdAt: Value(expense.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _db.deleteExpenseEntry(id);
  }

  @override
  Future<int> getTotalExpensesCents() async {
    final list = await getAllExpenses();
    return list.fold<int>(0, (sum, item) => sum + item.amountCents);
  }

  @override
  Stream<List<CategoryEntity>> watchCategories() {
    return _db.watchAllCategories().map(
          (rows) => rows
              .map((r) => CategoryEntity(
                    id: r.id,
                    name: r.name,
                    type: r.type,
                    isDefault: r.isDefault,
                  ))
              .toList(),
        );
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final rows = await _db.getAllCategories();
    return rows
        .map((r) => CategoryEntity(
              id: r.id,
              name: r.name,
              type: r.type,
              isDefault: r.isDefault,
            ))
        .toList();
  }

  ExpenseEntryEntity _mapToEntity(ExpenseEntryTableData row, String? categoryName) {
    return ExpenseEntryEntity(
      id: row.id,
      amountCents: row.amountCents,
      categoryId: row.categoryId,
      categoryName: categoryName ?? 'Expense',
      date: row.date,
      note: row.note,
      paymentMethod: row.paymentMethod,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
