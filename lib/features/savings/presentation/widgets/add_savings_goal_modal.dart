import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/savings_goal.dart';
import '../providers/savings_providers.dart';
import '../../../../core/services/notification_service.dart';

class AddSavingsGoalModal extends ConsumerStatefulWidget {
  final SavingsGoalEntity? existingGoal;

  const AddSavingsGoalModal({super.key, this.existingGoal});

  static Future<void> show(BuildContext context, {SavingsGoalEntity? existingGoal}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddSavingsGoalModal(existingGoal: existingGoal),
    );
  }

  @override
  ConsumerState<AddSavingsGoalModal> createState() => _AddSavingsGoalModalState();
}

class _AddSavingsGoalModalState extends ConsumerState<AddSavingsGoalModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _targetController;
  DateTime? _selectedTargetDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingGoal?.name ?? '');
    _targetController = TextEditingController(
      text: widget.existingGoal != null ? (widget.existingGoal!.targetAmountCents / 100).toStringAsFixed(2) : '',
    );
    _selectedTargetDate = widget.existingGoal?.targetDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _pickTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedTargetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedTargetDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final targetDouble = double.parse(_targetController.text.trim());
    final targetCents = (targetDouble * 100).round();

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(savingsRepositoryProvider);
      if (widget.existingGoal != null) {
        final updated = SavingsGoalEntity(
          id: widget.existingGoal!.id,
          name: name,
          targetAmountCents: targetCents,
          targetDate: _selectedTargetDate,
          createdAt: widget.existingGoal!.createdAt,
          isCompleted: widget.existingGoal!.isCompleted,
        );
        await repo.updateSavingsGoal(updated);
      } else {
        await repo.addSavingsGoal(
          name: name,
          targetAmountCents: targetCents,
          targetDate: _selectedTargetDate,
        );
      }

      if (_selectedTargetDate != null) {
        await NotificationService.instance.scheduleSavingsReminder(
          notificationId: name.hashCode,
          goalName: name,
          targetDate: _selectedTargetDate!,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Savings goal "$name" saved!'), backgroundColor: AppColors.successGreen),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving goal: $e'), backgroundColor: AppColors.expenseRed),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.existingGoal != null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.cardLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
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
                    isEditing ? tr('savings_modal_edit_title') : tr('savings_modal_add_title'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: tr('savings_goal_name_label'),
                  hintText: 'e.g. New Phone, Emergency Fund, Laptop',
                  prefixIcon: const Icon(Icons.savings_outlined),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Enter goal name' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _targetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: tr('savings_target_amount_label'),
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.flag_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter target amount';
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed <= 0) return 'Enter a valid target';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: _pickTargetDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: tr('savings_target_date_label'),
                    prefixIcon: const Icon(Icons.calendar_month_outlined),
                    suffixIcon: _selectedTargetDate != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _selectedTargetDate = null),
                          )
                        : null,
                  ),
                  child: Text(
                    _selectedTargetDate != null
                        ? DateFormatters.formatDate(_selectedTargetDate!)
                        : tr('savings_no_deadline'),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isEditing ? tr('savings_save_goal_changes') : tr('savings_create_goal'),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
