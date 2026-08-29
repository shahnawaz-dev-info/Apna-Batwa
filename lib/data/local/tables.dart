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
  TextColumn get status => text()(); // 'pending', 'partiallyPaid', 'fullyPaid', 'overpaid'
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
  TextColumn get status => text()(); // 'pending', 'partiallyPaid', 'fullyPaid', 'overpaid'
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DataClassName('RepaymentTableData')
class Repayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get recordType => text()(); // 'borrowed' or 'lent'
  IntColumn get recordId => integer()(); // FK to BorrowedRecords.id or LentRecords.id
  IntColumn get amountCents => integer()();
  TextColumn get entryType => text().withDefault(const Constant('repayment'))(); // 'addition' or 'repayment'
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

@DataClassName('WishlistItemTableData')
class WishlistItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get priceCents => integer()();
  TextColumn get category => text()();
  TextColumn get priority => text()(); // 'high', 'medium', 'low'
  TextColumn get notes => text().nullable()();
  BoolColumn get isPurchased => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get purchasedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PurchaseTableData')
class Purchases extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get amountCents => integer()();
  TextColumn get category => text()();
  DateTimeColumn get purchaseDate => dateTime()();
  TextColumn get linkedWishlistItemId => text().nullable()();
  TextColumn get linkedExpenseId => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('BudgetTableData')
class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get category => text()();
  IntColumn get monthlyLimitCents => integer()();
  IntColumn get month => integer()();
  IntColumn get year => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SavingsGoalTableData')
class SavingsGoals extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get targetAmountCents => integer()();
  DateTimeColumn get targetDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SavingsContributionTableData')
class SavingsContributions extends Table {
  TextColumn get id => text()();
  TextColumn get savingsGoalId => text()();
  IntColumn get amountCents => integer()();
  DateTimeColumn get contributionDate => dateTime()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RecurringTransactionTableData')
class RecurringTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()(); // 'income' or 'expense'
  TextColumn get name => text()();
  IntColumn get amountCents => integer()();
  TextColumn get category => text()();
  TextColumn get frequency => text()(); // 'daily', 'weekly', 'monthly'
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get nextDueDate => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastGeneratedDate => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

