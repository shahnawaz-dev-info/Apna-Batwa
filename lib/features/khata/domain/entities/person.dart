class PersonEntity {
  final int id;
  final String name;
  final String? phoneNumber;
  final String? note;
  final DateTime createdAt;
  final DateTime updatedAt;

  PersonEntity({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
}
