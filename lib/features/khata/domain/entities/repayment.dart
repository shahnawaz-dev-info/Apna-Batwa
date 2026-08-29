class RepaymentEntity {
  final int id;
  final String recordType; // 'borrowed' or 'lent'
  final int recordId;
  final int amountCents;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  RepaymentEntity({
    required this.id,
    required this.recordType,
    required this.recordId,
    required this.amountCents,
    required this.date,
    this.note,
    required this.createdAt,
  });
}
