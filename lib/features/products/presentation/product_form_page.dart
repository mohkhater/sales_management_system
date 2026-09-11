import 'package:flutter/material.dart';

import '../../units/data/unit_model.dart';
import '../../units/data/unit_repository.dart';
import '../data/product_repository.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  final UnitRepository _unitRepository = UnitRepository();
  final ProductRepository _productRepository = ProductRepository();

  List<Unit> _units = const [];
  Unit? _selectedUnit;

  bool _isLoadingUnits = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUnits();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadUnits() async {
    try {
      final units = await _unitRepository.getAll(
        activeOnly: true,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _units = units;
        _selectedUnit = units.isNotEmpty ? units.first : null;
        _isLoadingUnits = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingUnits = false;
        _errorMessage = 'تعذر تحميل الوحدات.';
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedUnit == null) {
      setState(() {
        _errorMessage = 'يرجى اختيار الوحدة الأساسية.';
      });
      return;
    }

    final price = double.parse(
      _priceController.text.trim(),
    );

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await _productRepository.insert(
        name: _nameController.text.trim(),
        baseUnitId: _selectedUnit!.id,
        defaultPrice: price,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _errorMessage = 'تعذر حفظ المنتج.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة منتج'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 32 : 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 700,
            ),
            child: _buildForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    if (_isLoadingUnits) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null && _units.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loadUnits,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_units.isEmpty) {
      return const Center(
        child: Text('لا توجد وحدات نشطة متاحة.'),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'اسم المنتج',
              hintText: 'أدخل اسم المنتج',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال اسم المنتج';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Unit>(
            initialValue: _selectedUnit,
            decoration: const InputDecoration(
              labelText: 'الوحدة الأساسية',
              border: OutlineInputBorder(),
            ),
            items: _units.map((unit) {
              return DropdownMenuItem<Unit>(
                value: unit,
                child: Text(
                  unit.symbol == null || unit.symbol!.isEmpty
                      ? unit.name
                      : '${unit.name} (${unit.symbol})',
                ),
              );
            }).toList(),
            onChanged: _isSaving
                ? null
                : (unit) {
                    setState(() {
                      _selectedUnit = unit;
                    });
                  },
            validator: (value) {
              if (value == null) {
                return 'يرجى اختيار الوحدة الأساسية';
              }

              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            decoration: const InputDecoration(
              labelText: 'السعر الافتراضي',
              hintText: '0.00',
              suffixText: '₪',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'يرجى إدخال السعر';
              }

              final price = double.tryParse(value.trim());

              if (price == null || price < 0) {
                return 'يرجى إدخال سعر صحيح';
              }

              return null;
            },
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(
              _isSaving ? 'جارٍ الحفظ...' : 'حفظ المنتج',
            ),
          ),
        ],
      ),
    );
  }
}