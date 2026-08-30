import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/localization/app_translations.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../providers/recurring_providers.dart';
import '../widgets/add_edit_recurring_modal.dart';

class RecurringManagementScreen extends ConsumerWidget {
  const RecurringManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(translationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recurringAsync = ref.watch(watchAllRecurringProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('recurring_title')),
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
                      tr('recurring_empty_title'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tr('recurring_empty_sub'),
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
        label: Text(tr('recurring_add_rule_btn'), style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildRecurringCard(
    BuildContext context,
    WidgetRef ref,
    RecurringTransactionEntity rule,
    bool isDark,
  ) {
    final tr = ref.watch(translationsProvider);
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
                  color: color.withValues(alpha: 0.12),
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
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            tr(rule.isActive ? 'recurring_status_active' : 'recurring_status_paused'),
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
                      '${tr('freq_${rule.frequency.name}')} • ${AppTranslations.translateCategory(rule.category, ref.watch(appLanguageProvider))}',
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
                      '${DateFormatters.formatDate(rule.nextDueDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (rule.lastGeneratedDate != null)
                      Text(
                        '${DateFormatters.formatDate(rule.lastGeneratedDate!)}',
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
                    tooltip: tr(rule.isActive ? 'recurring_pause_tooltip' : 'recurring_resume_tooltip'),
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
    final tr = ref.read(translationsProvider);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr('recurring_delete_dialog_title')),
        content: Text(tr('recurring_delete_dialog_msg')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(tr('common_cancel'))),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.expenseRed),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(recurringRepositoryProvider).deleteRecurring(rule.id);
            },
            child: Text(tr('common_delete')),
          ),
        ],
      ),
    );
  }
}
