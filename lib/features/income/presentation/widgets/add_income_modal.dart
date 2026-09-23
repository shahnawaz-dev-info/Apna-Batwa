import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/id_generator.dart';
import '../../domain/entities/income_entry.dart';
import '../providers/income_providers.dart';
import '../../../recurring/domain/entities/recurring_transaction.dart';
import '../../../recurring/presentation/providers/recurring_providers.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../transactions/presentation/widgets/bank_receipt_modal.dart';

class AddIncomeModal extends ConsumerStatefulWidget {
  final IncomeEntryEntity? existingEntry;

  const AddIncomeModal({super.key, this.existingEntry});

  static Future<void> show(BuildContext context, {IncomeEntryEntity? existingEntry}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddIncomeModal(existingEntry: existingEntry),
    );
  }

  @override
  ConsumerState<AddIncomeModal> createState() => _AddIncomeModalState();
}

class _AddIncomeModalState extends ConsumerState<AddIncomeModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late String _selectedSource;
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
    _selectedSource = entry?.source ?? AppConstants.incomeSources.first;
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

  Future<void> _saveIncome() async {
    if (!_formKey.currentState!.validate()) return;

    final amountCents = CurrencyFormatter.parseToCents(_amountController.text);
    if (amountCents <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Amount must be greater than zero.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(incomeRepositoryProvider);
      final now = DateTime.now();

      IncomeEntryEntity? createdEntry;
      if (widget.existingEntry == null) {
        final newEntry = IncomeEntryEntity(
          id: IdGenerator.generate(),
          amountCents: amountCents,
          source: _selectedSource,
          date: _selectedDate,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );
        await repo.addIncome(newEntry);
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
            type: 'income',
            name: _selectedSource,
            amountCents: amountCents,
            category: 'Income',
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
          source: _selectedSource,
          date: _selectedDate,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          updatedAt: now,
        );
        await repo.updateIncome(updated);
      }

      if (mounted) {
        Navigator.pop(context);
        if (createdEntry != null) {
          BankReceiptModal.show(
            context,
            CombinedTransactionItem(
              id: createdEntry.id,
              amountCents: createdEntry.amountCents,
              title: AppTranslations.translateCategory(createdEntry.source, ref.watch(appLanguageProvider)),
              subtitle: createdEntry.note,
              date: createdEntry.date,
              createdAt: createdEntry.createdAt,
              isIncome: true,
              rawEntity: createdEntry,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Income updated successfully!'),
              backgroundColor: AppColors.successGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save income: $e'),
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
                    isEdit ? tr('income_modal_edit_title') : tr('income_modal_add_title'),
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
                                title: Text(tr('income_delete_title')),
                                content: Text(tr('income_delete_msg')),
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
                              await ref.read(incomeRepositoryProvider).deleteIncome(widget.existingEntry!.id);
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
                  labelText: tr('income_amount_label'),
                  hintText: 'e.g. 5000',
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
              // Source dropdown
              DropdownButtonFormField<String>(
                value: _selectedSource,
                decoration: InputDecoration(labelText: tr('income_source_label')),
                items: AppConstants.incomeSources
                    .map((s) => DropdownMenuItem(value: s, child: Text(AppTranslations.translateCategory(s, ref.watch(appLanguageProvider)))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSource = val);
                },
              ),
              const SizedBox(height: 16),
              // Date picker field
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
                  hintText: 'e.g. Monthly stipend from parents',
                ),
              ),
              if (!isEdit) ...[
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tr('income_make_recurring'), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(tr('income_recurring_sub')),
                  value: _isRecurring,
                  onChanged: (val) => setState(() => _isRecurring = val),
                  activeColor: AppColors.successGreen,
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
                    backgroundColor: AppColors.successGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isSubmitting ? null : _saveIncome,
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          isEdit ? tr('income_update_btn') : tr('income_save_btn'),
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
