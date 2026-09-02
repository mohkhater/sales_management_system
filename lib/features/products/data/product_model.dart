class Product {
  final String id;
  final String name;
  final String baseUnitId;
  final String? categoryId;
  final double defaultPrice;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.baseUnitId,
    this.categoryId,
    required this.defaultPrice,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as String,
      name: map['name'] as String,
      baseUnitId: map['base_unit_id'] as String,
      categoryId: map['category_id'] as String?,
      defaultPrice: (map['default_price'] as num).toDouble(),
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'base_unit_id': baseUnitId,
      'category_id': categoryId,
      'default_price': defaultPrice,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}