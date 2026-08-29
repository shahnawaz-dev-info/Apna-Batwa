import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/repositories/income_repository_impl.dart';
import '../../domain/entities/income_entry.dart';
import '../../domain/repositories/income_repository.dart';
import '../../domain/usecases/income_usecases.dart';

final incomeRepositoryProvider = Provider<IncomeRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return IncomeRepositoryImpl(db);
});

final watchAllIncomeProvider = StreamProvider<List<IncomeEntryEntity>>((ref) {
  final repo = ref.watch(incomeRepositoryProvider);
  return WatchAllIncome(repo)();
});

final totalIncomeCentsProvider = Provider<int>((ref) {
  final incomeAsync = ref.watch(watchAllIncomeProvider);
  return incomeAsync.maybeWhen(
    data: (list) => list.fold(0, (sum, item) => sum + item.amountCents),
    orElse: () => 0,
  );
});
