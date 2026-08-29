import 'package:drift/drift.dart';
import '../../../../data/local/app_database.dart';
import '../../domain/entities/income_entry.dart';
import '../../domain/repositories/income_repository.dart';

class IncomeRepositoryImpl implements IncomeRepository {
  final AppDatabase _db;

  IncomeRepositoryImpl(this._db);

  @override
  Stream<List<IncomeEntryEntity>> watchAllIncome() {
    return _db.watchAllIncomeEntries().map((rows) => rows.map(_mapToEntity).toList());
  }

  @override
  Future<List<IncomeEntryEntity>> getAllIncome() async {
    final rows = await _db.getAllIncomeEntries();
    return rows.map(_mapToEntity).toList();
  }

  @override
  Future<void> addIncome(IncomeEntryEntity income) async {
    await _db.insertIncomeEntry(
      IncomeEntriesCompanion.insert(
        id: income.id,
        amountCents: income.amountCents,
        source: income.source,
        date: income.date,
        note: Value(income.note),
        createdAt: income.createdAt,
        updatedAt: income.updatedAt,
      ),
    );
  }

  @override
  Future<void> updateIncome(IncomeEntryEntity income) async {
    await _db.updateIncomeEntry(
      IncomeEntriesCompanion(
        id: Value(income.id),
        amountCents: Value(income.amountCents),
        source: Value(income.source),
        date: Value(income.date),
        note: Value(income.note),
        createdAt: Value(income.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteIncome(String id) async {
    await _db.deleteIncomeEntry(id);
  }

  @override
  Future<int> getTotalIncomeCents() async {
    final list = await getAllIncome();
    return list.fold<int>(0, (sum, item) => sum + item.amountCents);
  }

  IncomeEntryEntity _mapToEntity(IncomeEntryTableData row) {
    return IncomeEntryEntity(
      id: row.id,
      amountCents: row.amountCents,
      source: row.source,
      date: row.date,
      note: row.note,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
