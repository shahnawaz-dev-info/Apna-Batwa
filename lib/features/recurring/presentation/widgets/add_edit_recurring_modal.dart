import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/id_generator.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../providers/recurring_providers.dart';

class AddEditRecurringModal extends ConsumerStatefulWidget {
  final RecurringTransactionEntity? existingRule;

  const AddEditRecurringModal({super.key, this.existingRule});

  static Future<void> show(BuildContext context, {RecurringTransactionEntity? existingRule}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => AddEditRecurringModal(existingRule: existingRule),
    );
  }

  @override
  ConsumerState<AddEditRecurringModal> createState() => _AddEditRecurringModalState();
}

class _AddEditRecurringModalState extends ConsumerState<AddEditRecurringModal> {
  final _formKey = GlobalKey<FormState>();
  late String _type; // 'income' or 'expense'
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  String _category = 'General';
  RecurringFrequency _frequency = RecurringFrequency.monthly;
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();
    final rule = widget.existingRule;
    _type = rule?.type ?? 'expense';
    _nameController = TextEditingController(text: rule?.name ?? '');
    _amountController = TextEditingController(
      text: rule != null ? CurrencyFormatter.centsToInputString(rule.amountCents) : '',
    );
    _category = rule?.category ?? 'General';
    _frequency = rule?.frequency ?? RecurringFrequency.monthly;
    _startDate = rule?.startDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    final categoriesAsync = ref.watch(watchCategoriesProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.existingRule != null ? tr('recurring_modal_edit_title') : tr('recurring_modal_add_title'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Type Selector (Income vs Expense)
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'income', label: Text(tr('tab_income')), icon: const Icon(Icons.arrow_downward)),
                  ButtonSegment(value: 'expense', label: Text(tr('tab_expenses')), icon: const Icon(Icons.arrow_upward)),
                ],
                selected: {_type},
                onSelectionChanged: (val) => setState(() => _type = val.first),
              ),
              const SizedBox(height: 16),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: tr('recurring_name_label'),
                  hintText: 'e.g. Monthly Salary, Wifi Bill, Pocket Money',
                  border: const OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 12),

              // Amount Field
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: tr('recurring_amount_label'),
                  prefixText: 'Rs. ',
                  border: const OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Please enter amount';
                  final parsed = double.tryParse(val);
                  if (parsed == null || parsed <= 0) return 'Enter valid positive amount';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Category Field
              categoriesAsync.when(
                data: (cats) {
                  final expenseCats = cats.map((c) => c.name).toList();
                  if (!expenseCats.contains(_category) && expenseCats.isNotEmpty) {
                    _category = expenseCats.first;
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _category,
                    decoration: InputDecoration(
                      labelText: tr('expense_category_label'),
                      border: const OutlineInputBorder(),
                    ),
                    items: (_type == 'income'
                            ? ['Salary', 'Pocket Money', 'Gift', 'Scholarship', 'General']
                            : (expenseCats.isEmpty ? ['General'] : expenseCats))
                        .map((c) => DropdownMenuItem(value: c, child: Text(AppTranslations.translateCategory(c, ref.watch(appLanguageProvider)))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _category = val);
                    },
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),

              // Frequency Field
              DropdownButtonFormField<RecurringFrequency>(
                initialValue: _frequency,
                decoration: InputDecoration(
                  labelText: tr('recurring_frequency_label'),
                  border: const OutlineInputBorder(),
                ),
                items: RecurringFrequency.values
                    .map((f) => DropdownMenuItem(value: f, child: Text(tr('freq_${f.name}'))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _frequency = val);
                },
              ),
              const SizedBox(height: 12),

              // Start Date Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(tr('recurring_start_date_label'), style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(DateFormatters.formatDate(_startDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (picked != null) {
                    setState(() => _startDate = picked);
                  }
                },
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _save,
                  child: Text(
                    widget.existingRule != null ? tr('recurring_update_rule_btn') : tr('recurring_save_rule_btn'),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final amountCents = CurrencyFormatter.parseToCents(_amountController.text);
    final isEditing = widget.existingRule != null;

    final rule = RecurringTransactionEntity(
      id: isEditing ? widget.existingRule!.id : IdGenerator.generate(),
      type: _type,
      name: name,
      amountCents: amountCents,
      category: _category,
      frequency: _frequency,
      startDate: _startDate,
      nextDueDate: isEditing ? widget.existingRule!.nextDueDate : _startDate,
      isActive: isEditing ? widget.existingRule!.isActive : true,
      lastGeneratedDate: widget.existingRule?.lastGeneratedDate,
      createdAt: isEditing ? widget.existingRule!.createdAt : DateTime.now(),
    );

    final repo = ref.read(recurringRepositoryProvider);
    if (isEditing) {
      await repo.updateRecurring(rule);
    } else {
      await repo.createRecurring(rule);
    }

    if (mounted) Navigator.pop(context);
  }
}
