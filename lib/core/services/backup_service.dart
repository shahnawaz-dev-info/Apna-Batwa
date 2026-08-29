import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/local/app_database.dart';

class BackupResult {
  final bool success;
  final String message;
  final int recordCount;

  BackupResult({
    required this.success,
    required this.message,
    this.recordCount = 0,
  });
}

class BackupService {
  static final BackupService instance = BackupService._internal();
  BackupService._internal();

  Future<BackupResult> createBackup(AppDatabase db) async {
    try {
      final categories = await db.getAllCategories();
      final income = await db.getAllIncomeEntries();
      final expenses = await db.getAllExpenseEntries();
      final persons = await db.getAllPersons();
      final borrowed = await db.getAllBorrowedRecords();
      final lent = await db.getAllLentRecords();
      final repayments = await db.getAllRepayments();
      final wishlist = await db.getAllWishlistItems();
      final purchases = await db.getAllPurchases();
      final budgets = await db.getAllBudgets();
      final savingsGoals = await db.getAllSavingsGoals();
      final savingsContributions = await db.getAllSavingsContributions();
      final recurring = await db.getAllRecurringTransactions();

      final totalRecords = categories.length +
          income.length +
          expenses.length +
          persons.length +
          borrowed.length +
          lent.length +
          repayments.length +
          wishlist.length +
          purchases.length +
          budgets.length +
          savingsGoals.length +
          savingsContributions.length +
          recurring.length;

      final backupData = {
        'app': 'Apna Batwa',
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'data': {
          'categories': categories.map((c) => c.toJson()).toList(),
          'incomeEntries': income.map((i) => i.toJson()).toList(),
          'expenseEntries': expenses.map((e) => e.toJson()).toList(),
          'persons': persons.map((p) => p.toJson()).toList(),
          'borrowedRecords': borrowed.map((b) => b.toJson()).toList(),
          'lentRecords': lent.map((l) => l.toJson()).toList(),
          'repayments': repayments.map((r) => r.toJson()).toList(),
          'wishlistItems': wishlist.map((w) => w.toJson()).toList(),
          'purchases': purchases.map((p) => p.toJson()).toList(),
          'budgets': budgets.map((b) => b.toJson()).toList(),
          'savingsGoals': savingsGoals.map((g) => g.toJson()).toList(),
          'savingsContributions': savingsContributions.map((c) => c.toJson()).toList(),
          'recurringTransactions': recurring.map((r) => r.toJson()).toList(),
        }
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);
      final filename = 'ApnaBatwa_Backup_${DateTime.now().millisecondsSinceEpoch}.json';

      // Save to temporary directory and present Share dialog
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$filename');
      await file.writeAsString(jsonString);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Apna Batwa Backup File',
        text: 'Backup file exported from Apna Batwa.',
      );

      return BackupResult(
        success: true,
        message: 'Backup created successfully ($totalRecords records).',
        recordCount: totalRecords,
      );
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'Failed to create backup: $e',
      );
    }
  }

  Future<BackupResult> restoreBackup(AppDatabase db) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return BackupResult(
          success: false,
          message: 'Restore cancelled (no file selected).',
        );
      }

      final file = result.files.first;
      String content = '';

      if (file.bytes != null) {
        content = utf8.decode(file.bytes!);
      } else if (file.path != null) {
        content = await File(file.path!).readAsString();
      } else {
        return BackupResult(
          success: false,
          message: 'Could not read backup file content.',
        );
      }

      final Map<String, dynamic> rootMap = jsonDecode(content);
      if (rootMap['app'] != 'Apna Batwa') {
        return BackupResult(
          success: false,
          message: 'Invalid backup file format. This is not an Apna Batwa backup.',
        );
      }

      final Map<String, dynamic> dataMap = rootMap['data'] ?? {};

      final categoriesList = (dataMap['categories'] as List? ?? [])
          .map((item) => CategoryTableData.fromJson(item as Map<String, dynamic>))
          .toList();

      final incomeList = (dataMap['incomeEntries'] as List? ?? [])
          .map((item) => IncomeEntryTableData.fromJson(item as Map<String, dynamic>))
          .toList();

      final expenseList = (dataMap['expenseEntries'] as List? ?? [])
          .map((item) => ExpenseEntryTableData.fromJson(item as Map<String, dynamic>))
          .toList();

      final personsList = (dataMap['persons'] as List? ?? [])
          .map((item) => PersonTableData.fromJson(item as Map<String, dynamic>))
          .toList();

      final borrowedList = (dataMap['borrowedRecords'] as List? ?? [])
          .map((item) => BorrowedRecordTableData.fromJson(item as Map<String, dynamic>))
          .toList();

      final lentList = (dataMap['lentRecords'] as List? ?? [])
          .map((item) => LentRecordTableData.fromJson(item as Map<String, dynamic>))
          .toList();

      final repaymentsList = (dataMap['repayments'] as List? ?? [])
          .map((item) => RepaymentTableData.fromJson(item as Map<String, dynamic>))
          .toList();

      final wishlistList = (dataMap['wishlistItems'] as List? ?? [])
          .map((item) => WishlistItemTableData.fromJson(item as Map<String, dynamic>))
          .toList();

      final purchasesList = (dataMap['purchases'] as List? ?? [])
          .map((item) => PurchaseTableData.fromJson(item as Map<String, dynamic>))
          .toList();

      final budgetsList = (dataMap['budgets'] as List? ?? [])
          .map((item) => BudgetTableData.fromJson(item as Map<String, dynamic>))
          .toList();

      final savingsGoalsList = (dataMap['savingsGoals'] as List? ?? [])
          .map((item) => SavingsGoalTableData.fromJson(item as Map<String, dynamic>))
          .toList();

      final savingsContributionsList = (dataMap['savingsContributions'] as List? ?? [])
          .map((item) => SavingsContributionTableData.fromJson(item as Map<String, dynamic>))
          .toList();

      final recurringList = (dataMap['recurringTransactions'] as List? ?? [])
          .map((item) => RecurringTransactionTableData.fromJson(item as Map<String, dynamic>))
          .toList();

      final totalRecords = categoriesList.length +
          incomeList.length +
          expenseList.length +
          personsList.length +
          borrowedList.length +
          lentList.length +
          repaymentsList.length +
          wishlistList.length +
          purchasesList.length +
          budgetsList.length +
          savingsGoalsList.length +
          savingsContributionsList.length +
          recurringList.length;

      await db.restoreAllData(
        categoriesList: categoriesList,
        incomeList: incomeList,
        expenseList: expenseList,
        personsList: personsList,
        borrowedList: borrowedList,
        lentList: lentList,
        repaymentsList: repaymentsList,
        wishlistList: wishlistList,
        purchasesList: purchasesList,
        budgetsList: budgetsList,
        savingsGoalsList: savingsGoalsList,
        savingsContributionsList: savingsContributionsList,
        recurringList: recurringList,
      );

      return BackupResult(
        success: true,
        message: 'Backup restored successfully ($totalRecords records updated).',
        recordCount: totalRecords,
      );
    } catch (e) {
      return BackupResult(
        success: false,
        message: 'Failed to restore backup: $e',
      );
    }
  }
}
