import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/colors.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../../domain/entities/budget.dart';
import '../providers/budget_providers.dart';

class SetBudgetModal extends ConsumerStatefulWidget {
  final BudgetEntity? existingBudget;

  const SetBudgetModal({super.key, this.existingBudget});

  static Future<void> show(BuildContext context, {BudgetEntity? existingBudget}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SetBudgetModal(existingBudget: existingBudget),
    );
  }

  @override
  ConsumerState<SetBudgetModal> createState() => _SetBudgetModalState();
}

class _SetBudgetModalState extends ConsumerState<SetBudgetModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _limitController;
  late TextEditingController _customCategoryController;
  String? _selectedCategory;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _limitController = TextEditingController(
      text: widget.existingBudget != null ? (widget.existingBudget!.monthlyLimitCents / 100).toStringAsFixed(2) : '',
    );
    _selectedCategory = widget.existingBudget?.category;
    _customCategoryController = TextEditingController(text: _selectedCategory ?? '');
  }

  @override
  void dispose() {
    _limitController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final category = (_selectedCategory ?? _customCategoryController.text).trim();
    final limitDouble = double.parse(_limitController.text.trim());
    final limitCents = (limitDouble * 100).round();

    final selectedMonthYear = ref.read(selectedBudgetMonthYearProvider);

    setState(() => _isSaving = true);
    try {
      final repo = ref.read(budgetRepositoryProvider);
      await repo.setBudget(
        category: category,
        monthlyLimitCents: limitCents,
        month: selectedMonthYear.month,
        year: selectedMonthYear.year,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Budget for "$category" set!'), backgroundColor: AppColors.successGreen),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error setting budget: $e'), backgroundColor: AppColors.expenseRed),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(translationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(watchCategoriesProvider);
    final selectedMonthYear = ref.watch(selectedBudgetMonthYearProvider);

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
                    widget.existingBudget != null ? tr('budget_modal_edit_title') : tr('budget_modal_set_title'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Category Selector
              categoriesAsync.when(
                data: (cats) {
                  final catNames = cats.map((c) => c.name).toList();
                  return DropdownButtonFormField<String>(
                    value: catNames.contains(_selectedCategory) ? _selectedCategory : null,
                    decoration: InputDecoration(
                      labelText: '${tr('expense_category_label')} *',
                      prefixIcon: const Icon(Icons.category_outlined),
                    ),
                    items: catNames.map((name) {
                      return DropdownMenuItem<String>(
                        value: name,
                        child: Text(AppTranslations.translateCategory(name, ref.watch(appLanguageProvider))),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                    validator: (val) {
                      if (val == null && _customCategoryController.text.trim().isEmpty) {
                        return 'Select or enter category';
                      }
                      return null;
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => TextFormField(
                  controller: _customCategoryController,
                  decoration: InputDecoration(labelText: '${tr('expense_category_label')} *', prefixIcon: const Icon(Icons.category_outlined)),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter category' : null,
                ),
              ),
              const SizedBox(height: 14),

              TextFormField(
                controller: _limitController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: tr('budget_monthly_limit_label'),
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.account_balance_outlined),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Enter monthly limit';
                  final parsed = double.tryParse(val.trim());
                  if (parsed == null || parsed <= 0) return 'Enter a valid limit';
                  return null;
                },
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
                          '${tr('budget_set_button')} (${selectedMonthYear.month}/${selectedMonthYear.year})',
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
