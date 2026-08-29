import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/repositories/savings_repository_impl.dart';
import '../../domain/entities/savings_contribution.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/repositories/savings_repository.dart';

final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SavingsRepositoryImpl(db);
});

final watchAllSavingsGoalsProvider = StreamProvider<List<SavingsGoalEntity>>((ref) {
  final repo = ref.watch(savingsRepositoryProvider);
  return repo.watchAllSavingsGoals();
});

final watchAllSavingsContributionsProvider = StreamProvider<List<SavingsContributionEntity>>((ref) {
  final repo = ref.watch(savingsRepositoryProvider);
  return repo.watchAllSavingsContributions();
});

final watchContributionsForGoalProvider =
    StreamProvider.family<List<SavingsContributionEntity>, String>((ref, goalId) {
  final repo = ref.watch(savingsRepositoryProvider);
  return repo.watchContributionsForGoal(goalId);
});

class GoalWithProgress {
  final SavingsGoalEntity goal;
  final int savedCents;
  final List<SavingsContributionEntity> contributions;

  GoalWithProgress({
    required this.goal,
    required this.savedCents,
    required this.contributions,
  });

  double get percentage =>
      goal.targetAmountCents > 0 ? (savedCents / goal.targetAmountCents) * 100 : 0.0;
  bool get isAchieved => savedCents >= goal.targetAmountCents;
}

final goalWithProgressListProvider = Provider<List<GoalWithProgress>>((ref) {
  final goalsAsync = ref.watch(watchAllSavingsGoalsProvider);
  final contributionsAsync = ref.watch(watchAllSavingsContributionsProvider);

  final List<SavingsGoalEntity> goals = goalsAsync.maybeWhen(
    data: (list) => list,
    orElse: () => [],
  );

  final List<SavingsContributionEntity> contributions = contributionsAsync.maybeWhen(
    data: (list) => list,
    orElse: () => [],
  );

  return goals.map((goal) {
    final goalContribs = contributions.where((c) => c.savingsGoalId == goal.id).toList();
    final saved = goalContribs.fold<int>(0, (sum, c) => sum + c.amountCents);
    return GoalWithProgress(
      goal: goal,
      savedCents: saved,
      contributions: goalContribs,
    );
  }).toList();
});

/// Total Active Savings Contributions: Sum of savedCents for all active (!isCompleted) savings goals.
/// Adding money to a savings goal sets cash aside, reducing available Current Balance.
final totalActiveSavingsCentsProvider = Provider<int>((ref) {
  final progressList = ref.watch(goalWithProgressListProvider);
  return progressList
      .where((p) => !p.goal.isCompleted)
      .fold<int>(0, (sum, p) => sum + p.savedCents);
});
