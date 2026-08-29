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

@DriftDatabase(tables: [Categories, IncomeEntries, ExpenseEntries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;

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
}
