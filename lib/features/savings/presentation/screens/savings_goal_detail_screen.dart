import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/savings_contribution.dart';
import '../providers/savings_providers.dart';
import '../widgets/add_savings_contribution_modal.dart';

class SavingsGoalDetailScreen extends ConsumerWidget {
  final String goalId;

  const SavingsGoalDetailScreen({super.key, required this.goalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressList = ref.watch(goalWithProgressListProvider);
    final match = progressList.where((p) => p.goal.id == goalId);

    if (match.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Savings Goal Detail')),
        body: const Center(child: Text('Savings goal not found')),
      );
    }

    final goalProgress = match.first;
    final goal = goalProgress.goal;
    final savedCents = goalProgress.savedCents;
    final pct = goalProgress.percentage;
    final isAchieved = goalProgress.isAchieved;

    final contributionsAsync = ref.watch(watchContributionsForGoalProvider(goalId));

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.expenseRed),
            onPressed: () => _confirmDeleteGoal(context, ref, goal.id, goal.name),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Goal Overview Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: isDark ? AppColors.balanceGradientDark : AppColors.balanceGradientLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        goal.name,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      if (isAchieved)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Goal Achieved! 🎉',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    CurrencyFormatter.formatCents(savedCents),
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Target: ${CurrencyFormatter.formatCents(goal.targetAmountCents)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (pct / 100).clamp(0.0, 1.0),
                      minHeight: 10,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(isAchieved ? AppColors.successGreen : AppColors.warningAmber),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${pct.toStringAsFixed(0)}% Saved',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      if (goal.targetDate != null)
                        Text(
                          'Target Date: ${DateFormatters.formatDate(goal.targetDate!)}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Contribution History Header & Add Money Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Contribution History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => AddSavingsContributionModal.show(context, goalId: goal.id, goalName: goal.name),
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  label: const Text('Add Money', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Contributions List
            contributionsAsync.when(
              data: (contributions) {
                if (contributions.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.savings_outlined, size: 48, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                        const SizedBox(height: 12),
                        Text('No contributions logged yet', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? AppColors.textMainDark : AppColors.textMainLight)),
                        const SizedBox(height: 4),
                        Text('Tap "+ Add Money" to start setting money aside for this goal.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: contributions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final contrib = contributions[index];
                    return _buildContributionTile(context, ref, contrib, isDark);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error loading contributions: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContributionTile(BuildContext context, WidgetRef ref, SavingsContributionEntity contrib, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.successGreen.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.savings_outlined, color: AppColors.successGreen, size: 20),
        ),
        title: Text(
          CurrencyFormatter.formatCents(contrib.amountCents),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '${DateFormatters.formatDate(contrib.contributionDate)}${contrib.notes != null ? " • ${contrib.notes}" : ""}',
          style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: AppColors.expenseRed, size: 20),
          tooltip: 'Withdraw Contribution',
          onPressed: () => _confirmWithdraw(context, ref, contrib),
        ),
      ),
    );
  }

  void _confirmWithdraw(BuildContext context, WidgetRef ref, SavingsContributionEntity contrib) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Withdraw Contribution'),
        content: Text(
          'Are you sure you want to withdraw ${CurrencyFormatter.formatCents(contrib.amountCents)} from this goal? This will return the money to your available balance.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.expenseRed),
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(savingsRepositoryProvider);
              await repo.deleteSavingsContribution(contrib.id);
            },
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteGoal(BuildContext context, WidgetRef ref, String id, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Savings Goal'),
        content: Text('Are you sure you want to delete goal "$name"? All contribution logs will be removed and returned to your balance.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.expenseRed),
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(savingsRepositoryProvider);
              await repo.deleteSavingsGoal(id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
