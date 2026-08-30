import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../providers/recurring_providers.dart';
import '../widgets/add_edit_recurring_modal.dart';

class RecurringManagementScreen extends ConsumerWidget {
  const RecurringManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recurringAsync = ref.watch(watchAllRecurringProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Transactions'),
      ),
      body: recurringAsync.when(
        data: (rules) {
          if (rules.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.repeat_outlined,
                      size: 64,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Recurring Transactions 🔄',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Set up auto-recurring salary, pocket money, or bill rules!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rules.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final rule = rules[index];
              return _buildRecurringCard(context, ref, rule, isDark);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading recurring: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        onPressed: () => AddEditRecurringModal.show(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Recurring Rule', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildRecurringCard(
    BuildContext context,
    WidgetRef ref,
    RecurringTransactionEntity rule,
    bool isDark,
  ) {
    final isIncome = rule.isIncome;
    final color = isIncome ? AppColors.successGreen : AppColors.expenseRed;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            rule.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: (rule.isActive ? AppColors.successGreen : AppColors.warningAmber)
                                .withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            rule.isActive ? 'ACTIVE' : 'PAUSED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: rule.isActive ? AppColors.successGreen : AppColors.warningAmber,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${rule.frequency.name} • ${rule.category}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${isIncome ? "+" : "-"}${CurrencyFormatter.formatCents(rule.amountCents)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Due: ${DateFormatters.formatDate(rule.nextDueDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (rule.lastGeneratedDate != null)
                      Text(
                        'Last Generated: ${DateFormatters.formatDate(rule.lastGeneratedDate!)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      rule.isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
                      color: rule.isActive ? AppColors.warningAmber : AppColors.successGreen,
                    ),
                    tooltip: rule.isActive ? 'Pause Rule' : 'Resume Rule',
                    onPressed: () async {
                      final repo = ref.read(recurringRepositoryProvider);
                      await repo.toggleActive(rule.id, !rule.isActive);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => AddEditRecurringModal.show(context, existingRule: rule),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.expenseRed, size: 20),
                    onPressed: () => _confirmDelete(context, ref, rule),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, RecurringTransactionEntity rule) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Recurring Rule'),
        content: Text(
          'Are you sure you want to delete "${rule.name}"? Past generated income/expense records will remain intact.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.expenseRed),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(recurringRepositoryProvider).deleteRecurring(rule.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
