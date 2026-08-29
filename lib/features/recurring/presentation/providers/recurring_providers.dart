import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../../income/presentation/providers/income_providers.dart';
import '../../data/repositories/recurring_repository_impl.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/repositories/recurring_repository.dart';
import '../../domain/usecases/recurring_auto_generator.dart';

final recurringRepositoryProvider = Provider<RecurringRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return RecurringRepositoryImpl(db);
});

final watchAllRecurringProvider = StreamProvider<List<RecurringTransactionEntity>>((ref) {
  final repo = ref.watch(recurringRepositoryProvider);
  return repo.watchAllRecurring();
});

final recurringAutoGeneratorProvider = Provider<RecurringAutoGenerator>((ref) {
  return RecurringAutoGenerator(
    recurringRepo: ref.watch(recurringRepositoryProvider),
    incomeRepo: ref.watch(incomeRepositoryProvider),
    expenseRepo: ref.watch(expenseRepositoryProvider),
  );
});
