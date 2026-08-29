import '../entities/income_entry.dart';
import '../repositories/income_repository.dart';

class WatchAllIncome {
  final IncomeRepository repository;
  WatchAllIncome(this.repository);

  Stream<List<IncomeEntryEntity>> call() => repository.watchAllIncome();
}

class AddIncome {
  final IncomeRepository repository;
  AddIncome(this.repository);

  Future<void> call(IncomeEntryEntity income) => repository.addIncome(income);
}

class UpdateIncome {
  final IncomeRepository repository;
  UpdateIncome(this.repository);

  Future<void> call(IncomeEntryEntity income) => repository.updateIncome(income);
}

class DeleteIncome {
  final IncomeRepository repository;
  DeleteIncome(this.repository);

  Future<void> call(String id) => repository.deleteIncome(id);
}

class GetTotalIncome {
  final IncomeRepository repository;
  GetTotalIncome(this.repository);

  Future<int> call() => repository.getTotalIncomeCents();
}
