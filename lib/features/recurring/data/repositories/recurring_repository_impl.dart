import 'package:drift/drift.dart';
import '../../../../data/local/app_database.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/repositories/recurring_repository.dart';

class RecurringRepositoryImpl implements RecurringRepository {
  final AppDatabase _db;

  RecurringRepositoryImpl(this._db);

  RecurringTransactionEntity _mapToEntity(RecurringTransactionTableData data) {
    return RecurringTransactionEntity(
      id: data.id,
      type: data.type,
      name: data.name,
      amountCents: data.amountCents,
      category: data.category,
      frequency: RecurringFrequencyExtension.fromString(data.frequency),
      startDate: data.startDate,
      nextDueDate: data.nextDueDate,
      isActive: data.isActive,
      lastGeneratedDate: data.lastGeneratedDate,
      createdAt: data.createdAt,
    );
  }

  @override
  Stream<List<RecurringTransactionEntity>> watchAllRecurring() {
    return _db.watchAllRecurringTransactions().map(
          (list) => list.map(_mapToEntity).toList(),
        );
  }

  @override
  Future<List<RecurringTransactionEntity>> getAllRecurring() async {
    final list = await _db.getAllRecurringTransactions();
    return list.map(_mapToEntity).toList();
  }

  @override
  Future<void> createRecurring(RecurringTransactionEntity entity) async {
    await _db.insertRecurringTransaction(
      RecurringTransactionsCompanion.insert(
        id: entity.id,
        type: entity.type,
        name: entity.name,
        amountCents: entity.amountCents,
        category: entity.category,
        frequency: entity.frequency.name.toLowerCase(),
        startDate: entity.startDate,
        nextDueDate: entity.nextDueDate,
        isActive: Value(entity.isActive),
        lastGeneratedDate: Value(entity.lastGeneratedDate),
        createdAt: entity.createdAt,
      ),
    );
  }

  @override
  Future<void> updateRecurring(RecurringTransactionEntity entity) async {
    await _db.updateRecurringTransaction(
      RecurringTransactionsCompanion(
        id: Value(entity.id),
        type: Value(entity.type),
        name: Value(entity.name),
        amountCents: Value(entity.amountCents),
        category: Value(entity.category),
        frequency: Value(entity.frequency.name.toLowerCase()),
        startDate: Value(entity.startDate),
        nextDueDate: Value(entity.nextDueDate),
        isActive: Value(entity.isActive),
        lastGeneratedDate: Value(entity.lastGeneratedDate),
        createdAt: Value(entity.createdAt),
      ),
    );
  }

  @override
  Future<void> deleteRecurring(String id) async {
    await _db.deleteRecurringTransaction(id);
  }

  @override
  Future<void> toggleActive(String id, bool isActive) async {
    final all = await _db.getAllRecurringTransactions();
    final match = all.firstWhere((element) => element.id == id);
    await _db.updateRecurringTransaction(
      RecurringTransactionsCompanion(
        id: Value(match.id),
        type: Value(match.type),
        name: Value(match.name),
        amountCents: Value(match.amountCents),
        category: Value(match.category),
        frequency: Value(match.frequency),
        startDate: Value(match.startDate),
        nextDueDate: Value(match.nextDueDate),
        isActive: Value(isActive),
        lastGeneratedDate: Value(match.lastGeneratedDate),
        createdAt: Value(match.createdAt),
      ),
    );
  }
}
