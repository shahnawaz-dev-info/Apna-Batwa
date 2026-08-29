import '../entities/recurring_transaction.dart';

abstract class RecurringRepository {
  Stream<List<RecurringTransactionEntity>> watchAllRecurring();
  Future<List<RecurringTransactionEntity>> getAllRecurring();
  Future<void> createRecurring(RecurringTransactionEntity entity);
  Future<void> updateRecurring(RecurringTransactionEntity entity);
  Future<void> deleteRecurring(String id);
  Future<void> toggleActive(String id, bool isActive);
}
