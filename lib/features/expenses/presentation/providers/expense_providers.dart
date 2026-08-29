import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/repositories/expense_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/expense_entry.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/usecases/expense_usecases.dart';

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ExpenseRepositoryImpl(db);
});

final watchAllExpensesProvider = StreamProvider<List<ExpenseEntryEntity>>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return WatchAllExpenses(repo)();
});

final watchCategoriesProvider = StreamProvider<List<CategoryEntity>>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  return WatchCategories(repo)();
});

final totalExpensesCentsProvider = Provider<int>((ref) {
  final expenseAsync = ref.watch(watchAllExpensesProvider);
  return expenseAsync.maybeWhen(
    data: (list) => list.fold(0, (sum, item) => sum + item.amountCents),
    orElse: () => 0,
  );
});
