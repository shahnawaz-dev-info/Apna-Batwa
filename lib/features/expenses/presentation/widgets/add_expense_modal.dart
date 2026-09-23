import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/id_generator.dart';
import '../../domain/entities/expense_entry.dart';
import '../providers/expense_providers.dart';
import '../../../../core/services/notification_service.dart';
import '../../../budgets/presentation/providers/budget_providers.dart';
import '../../../recurring/domain/entities/recurring_transaction.dart';
import '../../../recurring/presentation/providers/recurring_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../transactions/presentation/widgets/bank_receipt_modal.dart';

class AddExpenseModal extends ConsumerStatefulWidget {
  final ExpenseEntryEntity? existingEntry;

  const AddExpenseModal({super.key, this.existingEntry});

  static Future<void> show(BuildContext context, {ExpenseEntryEntity? existingEntry}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddExpenseModal(existingEntry: existingEntry),
    );
  }

  @override
  ConsumerState<AddExpenseModal> createState() => _AddExpenseModalState();
}

class _AddExpenseModalState extends ConsumerState<AddExpenseModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  int? _selectedCategoryId;
  String? _selectedPaymentMethod;
  late DateTime _selectedDate;
  bool _isSubmitting = false;
  bool _isRecurring = false;
  RecurringFrequency _recurringFrequency = RecurringFrequency.monthly;

  @override
  void initState() {
    super.initState();
    final entry = widget.existingEntry;
    _amountController = TextEditingController(
      text: entry != null ? CurrencyFormatter.centsToInputString(entry.amountCents) : '',
    );
    _noteController = TextEditingController(text: entry?.note ?? '');
    _selectedCategoryId = entry?.categoryId;
    _selectedPaymentMethod = entry?.paymentMethod;
    _selectedDate = entry?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final now = DateTime.now();
      setState(() => _selectedDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        now.hour,
        now.minute,
        now.second,
      ));
    }
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    final amountCents = CurrencyFormatter.parseToCents(_amountController.text);
    if (amountCents <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount must be greater than zero.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(expenseRepositoryProvider);
      final categoriesAsync = ref.read(watchCategoriesProvider);
      final categories = categoriesAsync.asData?.value ?? [];
      final category = categories.firstWhere(
        (c) => c.id == _selectedCategoryId,
        orElse: () => categories.first,
      );
      final now = DateTime.now();

      ExpenseEntryEntity? createdEntry;
      if (widget.existingEntry == null) {
        final newEntry = ExpenseEntryEntity(
          id: IdGenerator.generate(),
          amountCents: amountCents,
          categoryId: _selectedCategoryId!,
          categoryName: category.name,
          paymentMethod: _selectedPaymentMethod,
          date: _selectedDate,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await repo.addExpense(newEntry);
        createdEntry = newEntry;

        if (_isRecurring) {
          final recRepo = ref.read(recurringRepositoryProvider);
          DateTime nextDue = _selectedDate;
          if (_recurringFrequency == RecurringFrequency.daily) {
            nextDue = nextDue.add(const Duration(days: 1));
          } else if (_recurringFrequency == RecurringFrequency.weekly) {
            nextDue = nextDue.add(const Duration(days: 7));
          } else {
            nextDue = DateTime(nextDue.year, nextDue.month + 1, nextDue.day);
          }

          final recRule = RecurringTransactionEntity(
            id: IdGenerator.generate(),
            type: 'expense',
            name: category.name,
            amountCents: amountCents,
            category: category.name,
            frequency: _recurringFrequency,
            startDate: _selectedDate,
            nextDueDate: nextDue,
            isActive: true,
            lastGeneratedDate: _selectedDate,
            createdAt: now,
          );
          await recRepo.createRecurring(recRule);
        }
      } else {
        final updated = widget.existingEntry!.copyWith(
          amountCents: amountCents,
          categoryId: _selectedCategoryId!,
          categoryName: category.name,
          paymentMethod: _selectedPaymentMethod,
          date: _selectedDate,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          updatedAt: now,
        );
        await repo.updateExpense(updated);
      }

      // Check Budget Alert Trigger
      try {
        final budgetRepo = ref.read(budgetRepositoryProvider);
        final budgets = await budgetRepo.getBudgetsForMonth(_selectedDate.month, _selectedDate.year);
        final matchingBudget = budgets.firstWhere(
          (b) => b.category.toLowerCase() == category.name.toLowerCase(),
          orElse: () => throw Exception('No budget'),
        );

        final allExpenses = await repo.getAllExpenses();
        final monthExpenses = allExpenses.where((e) =>
            e.categoryId == category.id &&
            e.date.month == _selectedDate.month &&
            e.date.year == _selectedDate.year);
        final totalSpent = monthExpenses.fold<int>(0, (sum, e) => sum + e.amountCents);

        final double ratio = totalSpent / matchingBudget.monthlyLimitCents;
        if (ratio >= 0.9) {
          final int percentage = (ratio * 100).round();
          await NotificationService.instance.triggerBudgetWarningNotification(
            categoryName: category.name,
            percentage: percentage,
            limitCents: matchingBudget.monthlyLimitCents,
            spentCents: totalSpent,
          );
        }
      } catch (_) {
        // No budget set for this category or ignore budget check error
      }

      if (mounted) {
        Navigator.pop(context);
        if (createdEntry != null) {
          BankReceiptModal.show(
            context,
            CombinedTransactionItem(
              id: createdEntry.id,
              amountCents: createdEntry.amountCents,
              title: createdEntry.categoryName ?? 'Expense',
              subtitle: createdEntry.note,
              date: createdEntry.date,
              createdAt: createdEntry.createdAt,
              isIncome: false,
              rawEntity: createdEntry,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense updated successfully!'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save expense: $e'),
            backgroundColor: AppColors.expenseRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.existingEntry != null;
    final categoriesAsync = ref.watch(watchCategoriesProvider);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 24,
        left: 20,
        right: 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? tr('expense_modal_edit_title') : tr('expense_modal_add_title'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                    ),
                  ),
                  Row(
                    children: [
                      if (isEdit)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.expenseRed),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(tr('expense_delete_title')),
                                content: Text(tr('expense_delete_msg')),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(tr('common_cancel')),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(foregroundColor: AppColors.expenseRed),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: Text(tr('common_delete')),
                                  ),
                                ],
                              ),
                            );
                            if (confirmed == true && widget.existingEntry != null) {
                              await ref.read(expenseRepositoryProvider).deleteExpense(widget.existingEntry!.id);
                              if (mounted) Navigator.pop(context);
                            }
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Amount field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: tr('expense_amount_label'),
                  hintText: 'e.g. 250',
                  prefixText: 'Rs. ',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter amount';
                  }
                  final cents = CurrencyFormatter.parseToCents(value);
                  if (cents <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Category dropdown
              categoriesAsync.when(
                data: (categories) {
                  if (_selectedCategoryId == null && categories.isNotEmpty) {
                    _selectedCategoryId = categories.first.id;
                  }
                  return DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(labelText: tr('expense_category_label')),
                    items: categories
                        .map((c) => DropdownMenuItem(value: c.id, child: Text(AppTranslations.translateCategory(c.name, ref.watch(appLanguageProvider)))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategoryId = val);
                    },
                    validator: (val) => val == null ? 'Please select category' : null,
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('Error loading categories: $e'),
              ),
              const SizedBox(height: 16),
              // Payment method dropdown
              DropdownButtonFormField<String>(
                value: _selectedPaymentMethod,
                decoration: InputDecoration(labelText: tr('expense_payment_method_label')),
                items: AppConstants.paymentMethods
                    .map((m) => DropdownMenuItem(value: m, child: Text(AppTranslations.translatePaymentMethod(m, ref.watch(appLanguageProvider)))))
                    .toList(),
                onChanged: (val) {
                  setState(() => _selectedPaymentMethod = val);
                },
              ),
              const SizedBox(height: 16),
              // Date picker
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormatters.formatDate(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),
              // Note field
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(
                  labelText: tr('purchase_notes_label'),
                  hintText: 'e.g. Lunch at university canteen',
                ),
              ),
              if (!isEdit) ...[
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tr('expense_make_recurring'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(tr('expense_recurring_sub')),
                  value: _isRecurring,
                  onChanged: (val) => setState(() => _isRecurring = val),
                  activeColor: AppColors.expenseRed,
                ),
                if (_isRecurring) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<RecurringFrequency>(
                    value: _recurringFrequency,
                    decoration: InputDecoration(
                      labelText: tr('recurring_frequency_label'),
                      border: const OutlineInputBorder(),
                    ),
                    items: RecurringFrequency.values
                        .map((f) => DropdownMenuItem(value: f, child: Text(f.name)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _recurringFrequency = val);
                    },
                  ),
                ],
              ],
              const SizedBox(height: 24),
              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.expenseRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _saveExpense,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEdit ? tr('expense_update_btn') : tr('expense_save_btn'),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
