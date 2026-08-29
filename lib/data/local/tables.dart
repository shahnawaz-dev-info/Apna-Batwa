import 'package:drift/drift.dart';

@DataClassName('CategoryTableData')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get type => text().withLength(min: 1, max: 20)(); // 'income' or 'expense'
  BoolColumn get isDefault => boolean().withDefault(const Constant(true))();
}

@DataClassName('IncomeEntryTableData')
class IncomeEntries extends Table {
  TextColumn get id => text()();
  IntColumn get amountCents => integer()();
  TextColumn get source => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}


@DataClassName('ExpenseEntryTableData')
class ExpenseEntries extends Table {
  TextColumn get id => text()();
  IntColumn get amountCents => integer()();
  IntColumn get categoryId => integer().references(Categories, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get paymentMethod => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PersonTableData')
class Persons extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DataClassName('BorrowedRecordTableData')
class BorrowedRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get personId => integer().references(Persons, #id)();
  IntColumn get totalAmountCents => integer()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get status => text()(); // 'pending', 'partiallyPaid', 'fullyPaid'
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DataClassName('LentRecordTableData')
class LentRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get personId => integer().references(Persons, #id)();
  IntColumn get totalAmountCents => integer()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  TextColumn get status => text()(); // 'pending', 'partiallyPaid', 'fullyPaid'
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DataClassName('RepaymentTableData')
class Repayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recordType => text()(); // 'borrowed' or 'lent'
  IntColumn get recordId => integer()(); // FK to BorrowedRecords.id or LentRecords.id
  IntColumn get amountCents => integer()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

