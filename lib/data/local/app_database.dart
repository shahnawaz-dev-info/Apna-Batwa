import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../../core/constants/app_constants.dart';
import 'tables.dart';

part 'app_database.g.dart';

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'apna_batwa.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}

@DriftDatabase(tables: [
  Categories,
  IncomeEntries,
  ExpenseEntries,
  Persons,
  BorrowedRecords,
  LentRecords,
  Repayments,
  WishlistItems,
  Purchases,
  Budgets,
  SavingsGoals,
  SavingsContributions,
  RecurringTransactions,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          // Seed default expense categories
          for (final catName in AppConstants.defaultExpenseCategories) {
            await into(categories).insert(
              CategoriesCompanion.insert(
                name: catName,
                type: 'expense',
                isDefault: const Value(true),
              ),
            );
          }
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(persons);
            await m.createTable(borrowedRecords);
            await m.createTable(lentRecords);
            await m.createTable(repayments);
          }
          if (from < 3) {
            await m.addColumn(repayments, repayments.entryType);

            // Merge duplicate BorrowedRecords per person
            final allBorrowed = await select(borrowedRecords).get();
            final Map<int, List<BorrowedRecordTableData>> borrowedByPerson = {};
            for (final b in allBorrowed) {
              borrowedByPerson.putIfAbsent(b.personId, () => []).add(b);
            }

            for (final entry in borrowedByPerson.entries) {
              final records = entry.value;
              records.sort((a, b) => a.id.compareTo(b.id));
              final surviving = records.first;

              final totalSum = records.fold<int>(0, (sum, r) => sum + r.totalAmountCents);

              for (final r in records) {
                // Add addition history entry
                await into(repayments).insert(
                  RepaymentsCompanion.insert(
                    recordType: 'borrowed',
                    recordId: surviving.id,
                    amountCents: r.totalAmountCents,
                    entryType: const Value('addition'),
                    date: r.date,
                    note: Value(r.note),
                    createdAt: r.createdAt,
                  ),
                );

                if (r.id != surviving.id) {
                  // Re-point existing repayments to surviving record
                  await (update(repayments)
                        ..where((t) => t.recordType.equals('borrowed') & t.recordId.equals(r.id)))
                      .write(RepaymentsCompanion(recordId: Value(surviving.id)));
                  // Delete duplicate record
                  await (delete(borrowedRecords)..where((t) => t.id.equals(r.id))).go();
                }
              }

              // Update surviving record total
              await (update(borrowedRecords)..where((t) => t.id.equals(surviving.id)))
                  .write(BorrowedRecordsCompanion(totalAmountCents: Value(totalSum)));
            }

            // Merge duplicate LentRecords per person
            final allLent = await select(lentRecords).get();
            final Map<int, List<LentRecordTableData>> lentByPerson = {};
            for (final l in allLent) {
              lentByPerson.putIfAbsent(l.personId, () => []).add(l);
            }

            for (final entry in lentByPerson.entries) {
              final records = entry.value;
              records.sort((a, b) => a.id.compareTo(b.id));
              final surviving = records.first;

              final totalSum = records.fold<int>(0, (sum, r) => sum + r.totalAmountCents);

              for (final r in records) {
                // Add addition history entry
                await into(repayments).insert(
                  RepaymentsCompanion.insert(
                    recordType: 'lent',
                    recordId: surviving.id,
                    amountCents: r.totalAmountCents,
                    entryType: const Value('addition'),
                    date: r.date,
                    note: Value(r.note),
                    createdAt: r.createdAt,
                  ),
                );

                if (r.id != surviving.id) {
                  // Re-point existing repayments to surviving record
                  await (update(repayments)
                        ..where((t) => t.recordType.equals('lent') & t.recordId.equals(r.id)))
                      .write(RepaymentsCompanion(recordId: Value(surviving.id)));
                  // Delete duplicate record
                  await (delete(lentRecords)..where((t) => t.id.equals(r.id))).go();
                }
              }

              // Update surviving record total
              await (update(lentRecords)..where((t) => t.id.equals(surviving.id)))
                  .write(LentRecordsCompanion(totalAmountCents: Value(totalSum)));
            }
          }
          if (from < 4) {
            await m.createTable(wishlistItems);
            await m.createTable(purchases);
            await m.createTable(budgets);
            await m.createTable(savingsGoals);
            await m.createTable(savingsContributions);
          }
          if (from < 5) {
            await m.createTable(recurringTransactions);
          }
        },
      );

  // Category Operations
  Stream<List<CategoryTableData>> watchAllCategories() => select(categories).watch();
  Future<List<CategoryTableData>> getAllCategories() => select(categories).get();
  Future<int> insertCategory(CategoriesCompanion entry) => into(categories).insert(entry);

  // Income Operations
  Stream<List<IncomeEntryTableData>> watchAllIncomeEntries() {
    return (select(incomeEntries)
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<List<IncomeEntryTableData>> getAllIncomeEntries() {
    return (select(incomeEntries)
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .get();
  }

  Future<int> insertIncomeEntry(IncomeEntriesCompanion entry) {
    return into(incomeEntries).insert(entry);
  }

  Future<bool> updateIncomeEntry(IncomeEntriesCompanion entry) {
    return update(incomeEntries).replace(entry);
  }

  Future<int> deleteIncomeEntry(String id) {
    return (delete(incomeEntries)..where((t) => t.id.equals(id))).go();
  }

  // Expense Operations
  Stream<List<ExpenseEntryTableData>> watchAllExpenseEntries() {
    return (select(expenseEntries)
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<List<ExpenseEntryTableData>> getAllExpenseEntries() {
    return (select(expenseEntries)
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .get();
  }

  Future<int> insertExpenseEntry(ExpenseEntriesCompanion entry) {
    return into(expenseEntries).insert(entry);
  }

  Future<bool> updateExpenseEntry(ExpenseEntriesCompanion entry) {
    return update(expenseEntries).replace(entry);
  }

  Future<int> deleteExpenseEntry(String id) {
    return (delete(expenseEntries)..where((t) => t.id.equals(id))).go();
  }

  // Person Operations
  Stream<List<PersonTableData>> watchAllPersons() =>
      (select(persons)..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)])).watch();
  Future<List<PersonTableData>> getAllPersons() =>
      (select(persons)..orderBy([(t) => OrderingTerm(expression: t.name, mode: OrderingMode.asc)])).get();
  Future<int> insertPerson(PersonsCompanion entry) => into(persons).insert(entry);
  Future<bool> updatePerson(PersonsCompanion entry) => update(persons).replace(entry);
  Future<int> deletePerson(int id) => (delete(persons)..where((t) => t.id.equals(id))).go();

  // BorrowedRecord Operations
  Stream<List<TypedResult>> watchAllBorrowedRecordsWithPerson() {
    final query = select(borrowedRecords).join([
      innerJoin(persons, persons.id.equalsExp(borrowedRecords.personId)),
    ]);
    query.orderBy([OrderingTerm(expression: borrowedRecords.date, mode: OrderingMode.desc)]);
    return query.watch();
  }

  Future<List<TypedResult>> getAllBorrowedRecordsWithPerson() {
    final query = select(borrowedRecords).join([
      innerJoin(persons, persons.id.equalsExp(borrowedRecords.personId)),
    ]);
    query.orderBy([OrderingTerm(expression: borrowedRecords.date, mode: OrderingMode.desc)]);
    return query.get();
  }

  Future<int> insertBorrowedRecord(BorrowedRecordsCompanion entry) => into(borrowedRecords).insert(entry);
  Future<bool> updateBorrowedRecord(BorrowedRecordsCompanion entry) => update(borrowedRecords).replace(entry);
  Future<int> deleteBorrowedRecord(int id) async {
    await (delete(repayments)..where((t) => t.recordType.equals('borrowed') & t.recordId.equals(id))).go();
    return (delete(borrowedRecords)..where((t) => t.id.equals(id))).go();
  }

  // LentRecord Operations
  Stream<List<TypedResult>> watchAllLentRecordsWithPerson() {
    final query = select(lentRecords).join([
      innerJoin(persons, persons.id.equalsExp(lentRecords.personId)),
    ]);
    query.orderBy([OrderingTerm(expression: lentRecords.date, mode: OrderingMode.desc)]);
    return query.watch();
  }

  Future<List<TypedResult>> getAllLentRecordsWithPerson() {
    final query = select(lentRecords).join([
      innerJoin(persons, persons.id.equalsExp(lentRecords.personId)),
    ]);
    query.orderBy([OrderingTerm(expression: lentRecords.date, mode: OrderingMode.desc)]);
    return query.get();
  }

  Future<int> insertLentRecord(LentRecordsCompanion entry) => into(lentRecords).insert(entry);
  Future<bool> updateLentRecord(LentRecordsCompanion entry) => update(lentRecords).replace(entry);
  Future<int> deleteLentRecord(int id) async {
    await (delete(repayments)..where((t) => t.recordType.equals('lent') & t.recordId.equals(id))).go();
    return (delete(lentRecords)..where((t) => t.id.equals(id))).go();
  }

  // Repayment Operations
  Stream<List<RepaymentTableData>> watchRepaymentsForRecord(String recordType, int recordId) {
    return (select(repayments)
          ..where((t) => t.recordType.equals(recordType) & t.recordId.equals(recordId))
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .watch();
  }

  Future<List<RepaymentTableData>> getRepaymentsForRecord(String recordType, int recordId) {
    return (select(repayments)
          ..where((t) => t.recordType.equals(recordType) & t.recordId.equals(recordId))
          ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .get();
  }

  Stream<List<RepaymentTableData>> watchAllRepayments() {
    return select(repayments).watch();
  }

  Future<List<RepaymentTableData>> getAllRepayments() {
    return select(repayments).get();
  }

  Future<int> insertRepayment(RepaymentsCompanion entry) => into(repayments).insert(entry);
  Future<int> deleteRepayment(int id) => (delete(repayments)..where((t) => t.id.equals(id))).go();

  // Wishlist Operations
  Stream<List<WishlistItemTableData>> watchAllWishlistItems() =>
      (select(wishlistItems)..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])).watch();
  Future<List<WishlistItemTableData>> getAllWishlistItems() =>
      (select(wishlistItems)..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])).get();
  Future<int> insertWishlistItem(WishlistItemsCompanion entry) => into(wishlistItems).insert(entry);
  Future<bool> updateWishlistItem(WishlistItemsCompanion entry) => update(wishlistItems).replace(entry);
  Future<int> deleteWishlistItem(String id) => (delete(wishlistItems)..where((t) => t.id.equals(id))).go();

  // Purchases Operations
  Stream<List<PurchaseTableData>> watchAllPurchases() =>
      (select(purchases)..orderBy([(t) => OrderingTerm(expression: t.purchaseDate, mode: OrderingMode.desc)])).watch();
  Future<List<PurchaseTableData>> getAllPurchases() =>
      (select(purchases)..orderBy([(t) => OrderingTerm(expression: t.purchaseDate, mode: OrderingMode.desc)])).get();
  Future<int> insertPurchase(PurchasesCompanion entry) => into(purchases).insert(entry);
  Future<bool> updatePurchase(PurchasesCompanion entry) => update(purchases).replace(entry);
  Future<int> deletePurchase(String id) => (delete(purchases)..where((t) => t.id.equals(id))).go();

  // Budget Operations
  Stream<List<BudgetTableData>> watchBudgetsForMonth(int month, int year) =>
      (select(budgets)..where((t) => t.month.equals(month) & t.year.equals(year))).watch();
  Future<List<BudgetTableData>> getBudgetsForMonth(int month, int year) =>
      (select(budgets)..where((t) => t.month.equals(month) & t.year.equals(year))).get();
  Stream<List<BudgetTableData>> watchAllBudgets() => select(budgets).watch();
  Future<int> insertBudget(BudgetsCompanion entry) => into(budgets).insert(entry);
  Future<bool> updateBudget(BudgetsCompanion entry) => update(budgets).replace(entry);
  Future<int> deleteBudget(String id) => (delete(budgets)..where((t) => t.id.equals(id))).go();

  // Savings Goal Operations
  Stream<List<SavingsGoalTableData>> watchAllSavingsGoals() =>
      (select(savingsGoals)..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])).watch();
  Future<List<SavingsGoalTableData>> getAllSavingsGoals() =>
      (select(savingsGoals)..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)])).get();
  Future<int> insertSavingsGoal(SavingsGoalsCompanion entry) => into(savingsGoals).insert(entry);
  Future<bool> updateSavingsGoal(SavingsGoalsCompanion entry) => update(savingsGoals).replace(entry);
  Future<int> deleteSavingsGoal(String id) async {
    await (delete(savingsContributions)..where((t) => t.savingsGoalId.equals(id))).go();
    return (delete(savingsGoals)..where((t) => t.id.equals(id))).go();
  }

  // Savings Contribution Operations
  Stream<List<SavingsContributionTableData>> watchContributionsForGoal(String goalId) =>
      (select(savingsContributions)
            ..where((t) => t.savingsGoalId.equals(goalId))
            ..orderBy([(t) => OrderingTerm(expression: t.contributionDate, mode: OrderingMode.desc)]))
          .watch();
  Stream<List<SavingsContributionTableData>> watchAllSavingsContributions() =>
      select(savingsContributions).watch();
  Future<List<SavingsContributionTableData>> getAllSavingsContributions() =>
      select(savingsContributions).get();
  Future<int> insertSavingsContribution(SavingsContributionsCompanion entry) =>
      into(savingsContributions).insert(entry);
  Future<int> deleteSavingsContribution(String id) =>
      (delete(savingsContributions)..where((t) => t.id.equals(id))).go();

  // Recurring Transaction Operations
  Stream<List<RecurringTransactionTableData>> watchAllRecurringTransactions() =>
      (select(recurringTransactions)
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
          .watch();
  Future<List<RecurringTransactionTableData>> getAllRecurringTransactions() =>
      (select(recurringTransactions)
            ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
          .get();
  Future<int> insertRecurringTransaction(RecurringTransactionsCompanion entry) =>
      into(recurringTransactions).insert(entry);
  Future<bool> updateRecurringTransaction(RecurringTransactionsCompanion entry) =>
      update(recurringTransactions).replace(entry);
  Future<int> deleteRecurringTransaction(String id) =>
      (delete(recurringTransactions)..where((t) => t.id.equals(id))).go();
}

