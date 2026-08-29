class SavingsGoalEntity {
  final String id;
  final String name;
  final int targetAmountCents;
  final DateTime? targetDate;
  final DateTime createdAt;
  final bool isCompleted;

  SavingsGoalEntity({
    required this.id,
    required this.name,
    required this.targetAmountCents,
    this.targetDate,
    required this.createdAt,
    this.isCompleted = false,
  });
}
