import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../expenses/presentation/providers/expense_providers.dart';
import '../providers/transaction_filter_providers.dart';

class TransactionFilterModal extends ConsumerStatefulWidget {
  const TransactionFilterModal({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TransactionFilterModal(),
    );
  }

  @override
  ConsumerState<TransactionFilterModal> createState() => _TransactionFilterModalState();
}

class _TransactionFilterModalState extends ConsumerState<TransactionFilterModal> {
  late String _typeFilter;
  late Set<String> _selectedCategories;
  DateTimeRange? _dateRange;
  late TextEditingController _minAmountController;
  late TextEditingController _maxAmountController;

  @override
  void initState() {
    super.initState();
    final current = ref.read(transactionFilterProvider);
    _typeFilter = current.typeFilter;
    _selectedCategories = Set.from(current.selectedCategories);
    _dateRange = current.dateRange;
    _minAmountController = TextEditingController(
      text: current.minAmountCents != null ? CurrencyFormatter.centsToInputString(current.minAmountCents!) : '',
    );
    _maxAmountController = TextEditingController(
      text: current.maxAmountCents != null ? CurrencyFormatter.centsToInputString(current.maxAmountCents!) : '',
    );
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Filter Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    ref.read(transactionFilterProvider.notifier).clearAll();
                    Navigator.pop(context);
                  },
                  child: const Text('Reset All', style: TextStyle(color: AppColors.expenseRed)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Type Filter
            const Text('Transaction Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'all', label: Text('All')),
                ButtonSegment(value: 'income', label: Text('Income Only')),
                ButtonSegment(value: 'expense', label: Text('Expense Only')),
              ],
              selected: {_typeFilter},
              onSelectionChanged: (val) => setState(() => _typeFilter = val.first),
            ),
            const SizedBox(height: 20),

            // Category Multi-select Filter
            const Text('Categories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            categoriesAsync.when(
              data: (cats) {
                final categoryNames = cats.map((c) => c.name).toList();
                return Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: categoryNames.map((catName) {
                    final isSelected = _selectedCategories.contains(catName);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(catName),
                      selectedColor: AppColors.primaryBlue.withOpacity(0.2),
                      checkmarkColor: AppColors.primaryBlue,
                      onSelected: (val) {
                        setState(() {
                          if (val) {
                            _selectedCategories.add(catName);
                          } else {
                            _selectedCategories.remove(catName);
                          }
                        });
                      },
                    );
                  }).toList(),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // Date Range Filter
            const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  initialDateRange: _dateRange,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  setState(() => _dateRange = picked);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_month_outlined),
                  suffixIcon: _dateRange != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _dateRange = null),
                        )
                      : null,
                ),
                child: Text(
                  _dateRange != null
                      ? '${DateFormatters.formatDate(_dateRange!.start)} – ${DateFormatters.formatDate(_dateRange!.end)}'
                      : 'Select Date Range',
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Amount Range Filter
            const Text('Amount Range (Rs.)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Min Amount',
                      prefixText: 'Rs. ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _maxAmountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Max Amount',
                      prefixText: 'Rs. ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  final notifier = ref.read(transactionFilterProvider.notifier);
                  notifier.setTypeFilter(_typeFilter);

                  // Update categories
                  final currentFilter = ref.read(transactionFilterProvider);
                  for (final cat in currentFilter.selectedCategories) {
                    if (!_selectedCategories.contains(cat)) notifier.toggleCategory(cat);
                  }
                  for (final cat in _selectedCategories) {
                    if (!currentFilter.selectedCategories.contains(cat)) notifier.toggleCategory(cat);
                  }

                  notifier.setDateRange(_dateRange);

                  final minCents = _minAmountController.text.trim().isNotEmpty
                      ? CurrencyFormatter.parseToCents(_minAmountController.text)
                      : null;
                  final maxCents = _maxAmountController.text.trim().isNotEmpty
                      ? CurrencyFormatter.parseToCents(_maxAmountController.text)
                      : null;
                  notifier.setAmountRange(minCents, maxCents);

                  Navigator.pop(context);
                },
                child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
