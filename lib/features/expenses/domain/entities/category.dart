class CategoryEntity {
  final int id;
  final String name;
  final String type; // 'income' or 'expense'
  final bool isDefault;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.isDefault,
  });
}
