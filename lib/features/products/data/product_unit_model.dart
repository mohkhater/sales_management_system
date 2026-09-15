class ProductUnit {
  final String id;
  final String productId;
  final String unitId;
  final double conversionToBase;
  final double sellingPrice;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductUnit({
    required this.id,
    required this.productId,
    required this.unitId,
    required this.conversionToBase,
    required this.sellingPrice,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductUnit.fromMap(Map<String, dynamic> map) {
    return ProductUnit(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      unitId: map['unit_id'] as String,
      conversionToBase: (map['conversion_to_base'] as num).toDouble(),
      sellingPrice: (map['selling_price'] as num).toDouble(),
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'product_id': productId,
        'unit_id': unitId,
        'conversion_to_base': conversionToBase,
        'selling_price': sellingPrice,
        'is_active': isActive ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
