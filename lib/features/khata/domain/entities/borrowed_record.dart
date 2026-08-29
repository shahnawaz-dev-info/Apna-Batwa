enum DebtStatus {
  pending,
  partiallyPaid,
  fullyPaid,
  overpaid,
}

class BorrowedRecordEntity {
  final int id;
  final int personId;
  final String personName;
  final int totalAmountCents;
  final int paidAmountCents;
  final int remainingCents;
  final DebtStatus status;
  final DateTime date;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  BorrowedRecordEntity({
    required this.id,
    required this.personId,
    required this.personName,
    required this.totalAmountCents,
    required this.paidAmountCents,
    required this.remainingCents,
    required this.status,
    required this.date,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
}
