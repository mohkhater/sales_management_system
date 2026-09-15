import 'package:flutter/material.dart';

import '../../units/data/unit_model.dart';
import '../../units/data/unit_repository.dart';
import '../data/product_barcode_model.dart';
import '../data/product_barcode_repository.dart';
import '../data/product_model.dart';
import '../data/product_unit_model.dart';
import '../data/product_unit_repository.dart';

class ProductUnitsPage extends StatefulWidget {
  final Product product;

  const ProductUnitsPage({
    super.key,
    required this.product,
  });

  @override
  State<ProductUnitsPage> createState() => _ProductUnitsPageState();
}

class _ProductUnitsPageState extends State<ProductUnitsPage> {
  final ProductUnitRepository _unitRepository = ProductUnitRepository();
  final ProductBarcodeRepository _barcodeRepository = ProductBarcodeRepository();
  final UnitRepository _masterUnitRepository = UnitRepository();

  List<ProductUnit> _productUnits = const [];
  List<Unit> _units = const [];
  Map<String, List<ProductBarcode>> _barcodes = const {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _unitRepository.getForProduct(widget.product.id, activeOnly: true),
        _masterUnitRepository.getAll(),
      ]);

      final productUnits = results[0] as List<ProductUnit>;
      final units = results[1] as List<Unit>;
      final barcodeEntries = await Future.wait(
        productUnits.map((item) async {
          return MapEntry(
            item.id,
            await _barcodeRepository.getForProductUnit(
              item.id,
              activeOnly: true,
            ),
          );
        }),
      );

      if (!mounted) return;
      setState(() {
        _productUnits = productUnits;
        _units = units;
        _barcodes = Map<String, List<ProductBarcode>>.fromEntries(
          barcodeEntries,
        );
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'تعذر تحميل وحدات البيع.';
      });
    }
  }

  String _unitName(String id) {
    for (final unit in _units) {
      if (unit.id == id) {
        if (unit.symbol == null || unit.symbol!.isEmpty) return unit.name;
        return '${unit.name} (${unit.symbol})';
      }
    }
    return 'وحدة غير معروفة';
  }

  bool _isBaseUnit(ProductUnit unit) => unit.unitId == widget.product.baseUnitId;

  Future<void> _addUnit() async {
    final available = _units
        .where((unit) => !_productUnits.any((item) => item.unitId == unit.id))
        .toList(growable: false);

    if (available.isEmpty) {
      _showMessage('لا توجد وحدات أخرى متاحة لهذا المنتج.');
      return;
    }

    final result = await showDialog<_ProductUnitInput>(
      context: context,
      builder: (_) => _ProductUnitDialog(units: available),
    );
    if (result == null) return;

    try {
      await _unitRepository.insert(
        productId: widget.product.id,
        unitId: result.unitId,
        conversionToBase: result.conversion,
        sellingPrice: result.price,
      );
      await _loadData();
      _showMessage('تمت إضافة وحدة البيع.');
    } catch (error) {
      _showMessage(_friendlyError(error, 'تعذر إضافة وحدة البيع.'));
    }
  }

  Future<void> _editUnit(ProductUnit unit) async {
    final result = await showDialog<_ProductUnitInput>(
      context: context,
      builder: (_) => _ProductUnitDialog(
        units: _units,
        initialUnitId: unit.unitId,
        initialConversion: unit.conversionToBase,
        initialPrice: unit.sellingPrice,
        lockUnit: _isBaseUnit(unit),
      ),
    );
    if (result == null) return;

    try {
      await _unitRepository.update(
        ProductUnit(
          id: unit.id,
          productId: unit.productId,
          unitId: result.unitId,
          conversionToBase: result.conversion,
          sellingPrice: result.price,
          isActive: unit.isActive,
          createdAt: unit.createdAt,
          updatedAt: unit.updatedAt,
        ),
      );
      await _loadData();
      _showMessage('تم حفظ تعديلات الوحدة.');
    } catch (error) {
      _showMessage(_friendlyError(error, 'تعذر تعديل وحدة البيع.'));
    }
  }

  Future<void> _deactivateUnit(ProductUnit unit) async {
    if (_isBaseUnit(unit)) {
      _showMessage('لا يمكن تعطيل الوحدة الأساسية.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تعطيل وحدة البيع'),
        content: Text('هل تريد تعطيل «${_unitName(unit.unitId)}»؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تعطيل'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _unitRepository.deactivate(unit.id);
      await _loadData();
      _showMessage('تم تعطيل وحدة البيع.');
    } catch (error) {
      _showMessage(_friendlyError(error, 'تعذر تعطيل وحدة البيع.'));
    }
  }

  Future<void> _addBarcode(ProductUnit unit) async {
    final barcode = await showDialog<String>(
      context: context,
      builder: (_) => const _BarcodeDialog(),
    );
    if (barcode == null) return;

    try {
      await _barcodeRepository.insert(
        productId: widget.product.id,
        productUnitId: unit.id,
        barcode: barcode,
      );
      await _loadData();
      _showMessage('تمت إضافة الباركود.');
    } catch (error) {
      _showMessage(_friendlyError(error, 'تعذر إضافة الباركود.'));
    }
  }

  Future<void> _deactivateBarcode(ProductBarcode barcode) async {
    try {
      await _barcodeRepository.deactivate(barcode.id);
      await _loadData();
      _showMessage('تم تعطيل الباركود.');
    } catch (error) {
      _showMessage(_friendlyError(error, 'تعذر تعطيل الباركود.'));
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _friendlyError(Object error, String fallback) {
    final text = error.toString();
    if (text.contains('Product unit already exists')) return 'هذه الوحدة مضافة بالفعل.';
    if (text.contains('Barcode already exists')) return 'هذا الباركود مستخدم بالفعل.';
    if (text.contains('Conversion')) return 'معامل التحويل يجب أن يكون أكبر من صفر.';
    if (text.contains('Selling price')) return 'سعر البيع غير صالح.';
    return fallback;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final desktop = width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: Text('وحدات بيع: ${widget.product.name}'),
        actions: [
          if (desktop)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _addUnit,
                icon: const Icon(Icons.add),
                label: const Text('إضافة وحدة'),
              ),
            )
          else
            IconButton(
              onPressed: _isLoading ? null : _addUnit,
              icon: const Icon(Icons.add),
              tooltip: 'إضافة وحدة',
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(desktop ? 24 : 12),
        child: _buildBody(desktop),
      ),
      floatingActionButton: desktop
          ? null
          : FloatingActionButton.extended(
              onPressed: _isLoading ? null : _addUnit,
              icon: const Icon(Icons.add),
              label: const Text('إضافة وحدة'),
            ),
    );
  }

  Widget _buildBody(bool desktop) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.product.name, style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text('الوحدة الأساسية: ${_unitName(widget.product.baseUnitId)}'),
                    ],
                  ),
                ),
                Text('${_productUnits.length} وحدة', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_productUnits.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('لا توجد وحدات بيع لهذا المنتج.')),
            ),
          )
        else
          ..._productUnits.map(_buildUnitCard),
      ],
    );
  }

  Widget _buildUnitCard(ProductUnit unit) {
    final barcodes = _barcodes[unit.id] ?? const <ProductBarcode>[];
    final base = _isBaseUnit(unit);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        initiallyExpanded: base,
        leading: CircleAvatar(child: Icon(base ? Icons.star : Icons.sell_outlined)),
        title: Row(
          children: [
            Expanded(child: Text(_unitName(unit.unitId))),
            if (base) const Chip(label: Text('أساسية')),
          ],
        ),
        subtitle: Text(
          '1 ${_unitName(unit.unitId)} = ${_formatNumber(unit.conversionToBase)} ${_unitName(widget.product.baseUnitId)} • ${unit.sellingPrice.toStringAsFixed(2)} ₪',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _editUnit(unit),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('تعديل'),
              ),
              if (!base)
                OutlinedButton.icon(
                  onPressed: () => _deactivateUnit(unit),
                  icon: const Icon(Icons.block_outlined),
                  label: const Text('تعطيل'),
                ),
              FilledButton.icon(
                onPressed: () => _addBarcode(unit),
                icon: const Icon(Icons.qr_code_2),
                label: const Text('إضافة باركود'),
              ),
            ],
          ),
          const Divider(height: 28),
          Row(
            children: [
              Text('الباركودات', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(width: 8),
              Text('${barcodes.length}'),
            ],
          ),
          const SizedBox(height: 8),
          if (barcodes.isEmpty)
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text('لا توجد باركودات لهذه الوحدة.'),
            )
          else
            ...barcodes.map(
              (barcode) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.qr_code),
                title: SelectableText(barcode.barcode),
                trailing: IconButton(
                  onPressed: () => _deactivateBarcode(barcode),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'تعطيل الباركود',
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.toStringAsFixed(0);
    return value.toStringAsFixed(4).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
}

class _ProductUnitInput {
  final String unitId;
  final double conversion;
  final double price;

  const _ProductUnitInput(this.unitId, this.conversion, this.price);
}

class _ProductUnitDialog extends StatefulWidget {
  final List<Unit> units;
  final String? initialUnitId;
  final double? initialConversion;
  final double? initialPrice;
  final bool lockUnit;

  const _ProductUnitDialog({
    required this.units,
    this.initialUnitId,
    this.initialConversion,
    this.initialPrice,
    this.lockUnit = false,
  });

  @override
  State<_ProductUnitDialog> createState() => _ProductUnitDialogState();
}

class _ProductUnitDialogState extends State<_ProductUnitDialog> {
  final _formKey = GlobalKey<FormState>();
  late String? _unitId = widget.initialUnitId;
  late final TextEditingController _conversion = TextEditingController(
    text: widget.initialConversion == null ? '' : _number(widget.initialConversion!),
  );
  late final TextEditingController _price = TextEditingController(
    text: widget.initialPrice == null ? '' : widget.initialPrice!.toStringAsFixed(2),
  );

  @override
  void dispose() {
    _conversion.dispose();
    _price.dispose();
    super.dispose();
  }

  static String _number(double value) => value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toString();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialUnitId == null ? 'إضافة وحدة بيع' : 'تعديل وحدة بيع'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 430,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _unitId,
                decoration: const InputDecoration(labelText: 'وحدة البيع', border: OutlineInputBorder()),
                items: widget.units.map((unit) => DropdownMenuItem(value: unit.id, child: Text(unit.name))).toList(),
                onChanged: widget.lockUnit ? null : (value) => setState(() => _unitId = value),
                validator: (value) => value == null ? 'اختر الوحدة' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _conversion,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'معامل التحويل إلى الوحدة الأساسية', border: OutlineInputBorder()),
                validator: (value) {
                  final number = double.tryParse(value?.trim() ?? '');
                  return number == null || !number.isFinite || number <= 0 ? 'أدخل معاملًا أكبر من صفر' : null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _price,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'سعر البيع', suffixText: '₪', border: OutlineInputBorder()),
                validator: (value) {
                  final number = double.tryParse(value?.trim() ?? '');
                  return number == null || !number.isFinite || number < 0 ? 'أدخل سعرًا صحيحًا' : null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              _ProductUnitInput(
                _unitId!,
                double.parse(_conversion.text.trim()),
                double.parse(_price.text.trim()),
              ),
            );
          },
          child: const Text('حفظ'),
        ),
      ],
    );
  }
}

class _BarcodeDialog extends StatefulWidget {
  const _BarcodeDialog();

  @override
  State<_BarcodeDialog> createState() => _BarcodeDialogState();
}

class _BarcodeDialogState extends State<_BarcodeDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إضافة باركود'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: const InputDecoration(
          labelText: 'الباركود',
          hintText: 'أدخل أو امسح الباركود',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
        FilledButton(onPressed: _submit, child: const Text('إضافة')),
      ],
    );
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    Navigator.pop(context, value);
  }
}
