import '../entities/category.dart';
import '../entities/expense_entry.dart';
import '../repositories/expense_repository.dart';

class WatchAllExpenses {
  final ExpenseRepository repository;
  WatchAllExpenses(this.repository);

  Stream<List<ExpenseEntryEntity>> call() => repository.watchAllExpenses();
}

class AddExpense {
  final ExpenseRepository repository;
  AddExpense(this.repository);

  Future<void> call(ExpenseEntryEntity expense) => repository.addExpense(expense);
}

class UpdateExpense {
  final ExpenseRepository repository;
  UpdateExpense(this.repository);

  Future<void> call(ExpenseEntryEntity expense) => repository.updateExpense(expense);
}

class DeleteExpense {
  final ExpenseRepository repository;
  DeleteExpense(this.repository);

  Future<void> call(String id) => repository.deleteExpense(id);
}

class GetTotalExpenses {
  final ExpenseRepository repository;
  GetTotalExpenses(this.repository);

  Future<int> call() => repository.getTotalExpensesCents();
}

class WatchCategories {
  final ExpenseRepository repository;
  WatchCategories(this.repository);

  Stream<List<CategoryEntity>> call() => repository.watchCategories();
}
