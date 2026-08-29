import '../entities/savings_contribution.dart';
import '../entities/savings_goal.dart';

abstract class SavingsRepository {
  // Goals
  Stream<List<SavingsGoalEntity>> watchAllSavingsGoals();
  Future<List<SavingsGoalEntity>> getAllSavingsGoals();
  Future<String> addSavingsGoal({
    required String name,
    required int targetAmountCents,
    DateTime? targetDate,
  });
  Future<bool> updateSavingsGoal(SavingsGoalEntity goal);
  Future<void> deleteSavingsGoal(String id);

  // Contributions
  Stream<List<SavingsContributionEntity>> watchContributionsForGoal(String goalId);
  Stream<List<SavingsContributionEntity>> watchAllSavingsContributions();
  Future<String> addSavingsContribution({
    required String savingsGoalId,
    required int amountCents,
    required DateTime contributionDate,
    String? notes,
  });
  Future<void> deleteSavingsContribution(String id);
}
