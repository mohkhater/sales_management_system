
class Unit {
  final String id;
  final String name;
  final String? symbol;
  final String type;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Unit({
    required this.id,
    required this.name,
    this.symbol,
    required this.type,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Unit.fromMap(Map<String, dynamic> map) {
    return Unit(
      id: map['id'] as String,
      name: map['name'] as String,
      symbol: map['symbol'] as String?,
      type: map['type'] as String,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'type': type,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

