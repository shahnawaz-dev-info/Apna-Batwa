class BudgetEntity {
  final String id;
  final String category;
  final int monthlyLimitCents;
  final int month;
  final int year;
  final DateTime createdAt;

  BudgetEntity({
    required this.id,
    required this.category,
    required this.monthlyLimitCents,
    required this.month,
    required this.year,
    required this.createdAt,
  });
}
