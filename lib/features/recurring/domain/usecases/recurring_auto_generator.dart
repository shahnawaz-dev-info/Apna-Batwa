import '../../../../core/utils/id_generator.dart';
import '../../../expenses/domain/entities/expense_entry.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../income/domain/entities/income_entry.dart';
import '../../../income/domain/repositories/income_repository.dart';
import '../entities/recurring_transaction.dart';
import '../repositories/recurring_repository.dart';

class RecurringAutoGenerator {
  final RecurringRepository _recurringRepo;
  final IncomeRepository _incomeRepo;
  final ExpenseRepository _expenseRepo;

  RecurringAutoGenerator({
    required RecurringRepository recurringRepo,
    required IncomeRepository incomeRepo,
    required ExpenseRepository expenseRepo,
  })  : _recurringRepo = recurringRepo,
        _incomeRepo = incomeRepo,
        _expenseRepo = expenseRepo;

  Future<void> checkAndGenerateDueTransactions() async {
    final now = DateTime.now();
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final allRules = await _recurringRepo.getAllRecurring();
    final activeRules = allRules.where((r) => r.isActive).toList();

    final categories = await _expenseRepo.getCategories();

    for (final rule in activeRules) {
      DateTime nextDueDate = rule.nextDueDate;
      DateTime? lastGeneratedDate = rule.lastGeneratedDate;

      // Loop to catch up multiple missed periods if app was closed
      bool generatedAny = false;

      while (nextDueDate.isBefore(todayEnd) || nextDueDate.isAtSameMomentAs(todayEnd)) {
        final generatedId = IdGenerator.generate();
        final nowTs = DateTime.now();

        if (rule.isIncome) {
          final incomeEntry = IncomeEntryEntity(
            id: generatedId,
            amountCents: rule.amountCents,
            source: rule.name,
            date: nextDueDate,
            note: 'Auto-generated from recurring: ${rule.name}',
            createdAt: nowTs,
            updatedAt: nowTs,
          );
          await _incomeRepo.addIncome(incomeEntry);
        } else {
          // Find matching category ID or fallback to first
          final cat = categories.firstWhere(
            (c) => c.name.toLowerCase() == rule.category.toLowerCase(),
            orElse: () => categories.isNotEmpty ? categories.first : throw Exception('No categories found'),
          );

          final expenseEntry = ExpenseEntryEntity(
            id: generatedId,
            amountCents: rule.amountCents,
            categoryId: cat.id,
            categoryName: cat.name,
            date: nextDueDate,
            note: 'Auto-generated from recurring: ${rule.name}',
            createdAt: nowTs,
            updatedAt: nowTs,
          );
          await _expenseRepo.addExpense(expenseEntry);
        }

        lastGeneratedDate = nextDueDate;
        generatedAny = true;
        nextDueDate = _advanceDate(nextDueDate, rule.frequency);
      }

      if (generatedAny) {
        final updatedRule = rule.copyWith(
          nextDueDate: nextDueDate,
          lastGeneratedDate: lastGeneratedDate,
        );
        await _recurringRepo.updateRecurring(updatedRule);
      }
    }
  }

  static DateTime _advanceDate(DateTime date, RecurringFrequency frequency) {
    switch (frequency) {
      case RecurringFrequency.daily:
        return date.add(const Duration(days: 1));
      case RecurringFrequency.weekly:
        return date.add(const Duration(days: 7));
      case RecurringFrequency.monthly:
        final nextMonth = date.month == 12 ? 1 : date.month + 1;
        final nextYear = date.month == 12 ? date.year + 1 : date.year;
        final daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
        final day = date.day > daysInNextMonth ? daysInNextMonth : date.day;
        return DateTime(nextYear, nextMonth, day, date.hour, date.minute, date.second);
    }
  }
}
