import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/budget_providers.dart';
import '../widgets/set_budget_modal.dart';

class BudgetManagementScreen extends ConsumerWidget {
  const BudgetManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedMonthYear = ref.watch(selectedBudgetMonthYearProvider);
    final budgetProgressList = ref.watch(categoryBudgetProgressListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Management'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month Navigation Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      final prev = DateTime(selectedMonthYear.year, selectedMonthYear.month - 1, 1);
                      ref.read(selectedBudgetMonthYearProvider.notifier).state = prev;
                    },
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, color: AppColors.primaryBlue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMMM yyyy').format(selectedMonthYear),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      final next = DateTime(selectedMonthYear.year, selectedMonthYear.month + 1, 1);
                      ref.read(selectedBudgetMonthYearProvider.notifier).state = next;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Category Budgets Header & Set Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Category Budgets',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => SetBudgetModal.show(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Set Budget', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Budget Items List
            if (budgetProgressList.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 48,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No budgets set for ${DateFormat('MMMM yyyy').format(selectedMonthYear)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap "Set Budget" to set spending limits for categories.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: budgetProgressList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final progress = budgetProgressList[index];
                  return _buildBudgetCard(context, ref, progress, isDark);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard(BuildContext context, WidgetRef ref, CategoryBudgetProgress progress, bool isDark) {
    final pct = progress.percentage;

    // Color logic: <70% Success Green, 70-99% Warning Amber, 100%+ Expense Red
    Color progressColor;
    if (pct < 70) {
      progressColor = AppColors.successGreen;
    } else if (pct < 100) {
      progressColor = AppColors.warningAmber;
    } else {
      progressColor = AppColors.expenseRed;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: progressColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.pie_chart_outline, color: progressColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    progress.budget.category,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () => SetBudgetModal.show(context, existingBudget: progress.budget),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.expenseRed, size: 18),
                    onPressed: () {
                      final repo = ref.read(budgetRepositoryProvider);
                      repo.deleteBudget(progress.budget.id);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: progressColor.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          const SizedBox(height: 10),

          // Budget Numbers Display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${CurrencyFormatter.formatCents(progress.spentCents)} spent of ${CurrencyFormatter.formatCents(progress.budget.monthlyLimitCents)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              Text(
                '${pct.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),

          if (progress.isOverBudget) ...[
            const SizedBox(height: 6),
            Text(
              '⚠️ Over budget by ${CurrencyFormatter.formatCents(progress.spentCents - progress.budget.monthlyLimitCents)}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.expenseRed),
            ),
          ],
        ],
      ),
    );
  }
}
