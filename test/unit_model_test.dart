
import 'package:flutter_test/flutter_test.dart';

import 'package:sales_management_system/features/units/data/unit_model.dart';

void main() {
  test('unit map round-trip', () {
    final createdAt = DateTime.parse('2026-09-08T10:00:00.000');
    final updatedAt = DateTime.parse('2026-09-08T11:00:00.000');

    final unit = Unit(
      id: 'piece',
      name: 'حبة',
      symbol: 'حبة',
      type: 'count',
      isActive: true,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );

    final map = unit.toMap();
    final restored = Unit.fromMap(map);

    expect(restored.id, unit.id);
    expect(restored.name, unit.name);
    expect(restored.symbol, unit.symbol);
    expect(restored.type, unit.type);
    expect(restored.isActive, unit.isActive);
    expect(restored.createdAt, unit.createdAt);
    expect(restored.updatedAt, unit.updatedAt);
  });
}

