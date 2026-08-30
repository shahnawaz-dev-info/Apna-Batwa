import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/utils/formatters.dart';
import '../providers/savings_providers.dart';
import '../widgets/add_savings_contribution_modal.dart';
import '../widgets/add_savings_goal_modal.dart';
import 'savings_goal_detail_screen.dart';

class SavingsGoalsScreen extends ConsumerWidget {
  const SavingsGoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final goalsProgress = ref.watch(goalWithProgressListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Goals'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Goals',
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
                  onPressed: () => AddSavingsGoalModal.show(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('New Goal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (goalsProgress.isEmpty)
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
                      Icons.savings_outlined,
                      size: 48,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No savings goals created yet',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap "New Goal" to set target savings for your future plans.',
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
                itemCount: goalsProgress.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final progress = goalsProgress[index];
                  return _buildGoalCard(context, ref, progress, isDark);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, WidgetRef ref, GoalWithProgress progress, bool isDark) {
    final goal = progress.goal;
    final savedCents = progress.savedCents;
    final pct = progress.percentage;
    final isAchieved = progress.isAchieved;

    String deadlineText = '';
    Color deadlineColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    if (goal.targetDate != null) {
      final now = DateTime.now();
      final diffDays = goal.targetDate!.difference(DateTime(now.year, now.month, now.day)).inDays;
      if (diffDays < 0) {
        deadlineText = 'Overdue by ${diffDays.abs()} days';
        deadlineColor = AppColors.expenseRed;
      } else if (diffDays == 0) {
        deadlineText = 'Due Today!';
        deadlineColor = AppColors.warningAmber;
      } else {
        deadlineText = '$diffDays days left';
        deadlineColor = AppColors.primaryBlue;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => SavingsGoalDetailScreen(goalId: goal.id)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                          color: (isAchieved ? AppColors.successGreen : AppColors.primaryBlue).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isAchieved ? Icons.verified : Icons.savings_outlined,
                          color: isAchieved ? AppColors.successGreen : AppColors.primaryBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        goal.name,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                        ),
                      ),
                    ],
                  ),
                  if (isAchieved)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.successGreen.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Goal Achieved! 🎉', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.successGreen)),
                    )
                  else if (deadlineText.isNotEmpty)
                    Text(deadlineText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: deadlineColor)),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Saved: ${CurrencyFormatter.formatCents(savedCents)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                    ),
                  ),
                  Text(
                    'Target: ${CurrencyFormatter.formatCents(goal.targetAmountCents)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: (pct / 100).clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: AppColors.primaryBlue.withOpacity(0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(isAchieved ? AppColors.successGreen : AppColors.primaryBlue),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${pct.toStringAsFixed(0)}% Saved',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isAchieved ? AppColors.successGreen : AppColors.primaryBlue,
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.successGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () => AddSavingsContributionModal.show(context, goalId: goal.id, goalName: goal.name),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('Add Money', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
