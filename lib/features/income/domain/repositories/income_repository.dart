import '../entities/income_entry.dart';

abstract class IncomeRepository {
  Stream<List<IncomeEntryEntity>> watchAllIncome();
  Future<List<IncomeEntryEntity>> getAllIncome();
  Future<void> addIncome(IncomeEntryEntity income);
  Future<void> updateIncome(IncomeEntryEntity income);
  Future<void> deleteIncome(String id);
  Future<int> getTotalIncomeCents();
}
