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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 2;

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
}

