import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/id_generator.dart';
import '../../domain/entities/income_entry.dart';
import '../providers/income_providers.dart';
import '../../../recurring/domain/entities/recurring_transaction.dart';
import '../../../recurring/presentation/providers/recurring_providers.dart';

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
      setState(() => _selectedDate = picked);
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingEntry == null
                  ? 'Income added successfully!'
                  : 'Income updated successfully!',
            ),
            backgroundColor: AppColors.successGreen,
          ),
        );
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
                    isEdit ? 'Edit Income' : '+ Add Money In (Income)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Amount field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (PKR)',
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
                decoration: const InputDecoration(labelText: 'Income Source'),
                items: AppConstants.incomeSources
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
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
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  hintText: 'e.g. Monthly stipend from parents',
                ),
              ),
              if (!isEdit) ...[
                const SizedBox(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Make this recurring', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Auto-generate future income entries'),
                  value: _isRecurring,
                  onChanged: (val) => setState(() => _isRecurring = val),
                  activeColor: AppColors.successGreen,
                ),
                if (_isRecurring) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<RecurringFrequency>(
                    value: _recurringFrequency,
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(),
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
                          isEdit ? 'Update Income' : 'Save Income',
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
