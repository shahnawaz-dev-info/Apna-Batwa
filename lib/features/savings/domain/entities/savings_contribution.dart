class SavingsContributionEntity {
  final String id;
  final String savingsGoalId;
  final int amountCents;
  final DateTime contributionDate;
  final String? notes;

  SavingsContributionEntity({
    required this.id,
    required this.savingsGoalId,
    required this.amountCents,
    required this.contributionDate,
    this.notes,
  });
}
