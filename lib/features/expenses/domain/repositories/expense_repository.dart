import '../entities/category.dart';
import '../entities/expense_entry.dart';

abstract class ExpenseRepository {
  Stream<List<ExpenseEntryEntity>> watchAllExpenses();
  Future<List<ExpenseEntryEntity>> getAllExpenses();
  Future<void> addExpense(ExpenseEntryEntity expense);
  Future<void> updateExpense(ExpenseEntryEntity expense);
  Future<void> deleteExpense(String id);
  Future<int> getTotalExpensesCents();
  Stream<List<CategoryEntity>> watchCategories();
  Future<List<CategoryEntity>> getCategories();
}
