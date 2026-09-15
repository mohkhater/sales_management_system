class ProductBarcode {
  final String id;
  final String productId;
  final String productUnitId;
  final String barcode;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductBarcode({
    required this.id,
    required this.productId,
    required this.productUnitId,
    required this.barcode,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductBarcode.fromMap(Map<String, dynamic> map) {
    return ProductBarcode(
      id: map['id'] as String,
      productId: map['product_id'] as String,
      productUnitId: map['product_unit_id'] as String,
      barcode: map['barcode'] as String,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'product_id': productId,
        'product_unit_id': productUnitId,
        'barcode': barcode,
        'is_active': isActive ? 1 : 0,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
