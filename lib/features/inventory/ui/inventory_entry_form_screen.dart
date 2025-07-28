import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/inventory_entry.dart';
import '../providers/inventory_providers.dart';

class InventoryEntryFormScreen extends ConsumerStatefulWidget {
  final String medicationId;
  final InventoryEntry? existingEntry;

  const InventoryEntryFormScreen({
    required this.medicationId,
    this.existingEntry,
    super.key,
  });

  @override
  ConsumerState<InventoryEntryFormScreen> createState() =>
      _InventoryEntryFormScreenState();
}

class _InventoryEntryFormScreenState
    extends ConsumerState<InventoryEntryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _quantityController;
  late TextEditingController _minimumQuantityController;
  late TextEditingController _reorderPointController;
  late TextEditingController _batchNumberController;
  late TextEditingController _priceController;
  late TextEditingController _supplierController;
  late TextEditingController _locationController;
  late DateTime _purchaseDate;
  DateTime? _expirationDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final entry = widget.existingEntry;
    _quantityController = TextEditingController(
      text: entry?.currentQuantity.toString() ?? '',
    );
    _minimumQuantityController = TextEditingController(
      text: entry?.minimumQuantity.toString() ?? '',
    );
    _reorderPointController = TextEditingController(
      text: entry?.reorderPoint.toString() ?? '',
    );
    _batchNumberController = TextEditingController(
      text: entry?.batchNumber ?? '',
    );
    _priceController = TextEditingController(
      text: entry?.purchasePrice.toString() ?? '',
    );
    _supplierController = TextEditingController(
      text: entry?.supplier ?? '',
    );
    _locationController = TextEditingController(
      text: entry?.storageLocation ?? '',
    );
    _purchaseDate = entry?.purchaseDate ?? DateTime.now();
    _expirationDate = entry?.expirationDate;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _minimumQuantityController.dispose();
    _reorderPointController.dispose();
    _batchNumberController.dispose();
    _priceController.dispose();
    _supplierController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectPurchaseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _purchaseDate = date);
    }
  }

  Future<void> _selectExpirationDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (date != null) {
      setState(() => _expirationDate = date);
    }
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final entry = InventoryEntry(
        id: widget.existingEntry?.id ?? const Uuid().v4(),
        medicationId: widget.medicationId,
        currentQuantity: int.parse(_quantityController.text),
        minimumQuantity: int.parse(_minimumQuantityController.text),
        reorderPoint: int.parse(_reorderPointController.text),
        batchNumber: _batchNumberController.text.isEmpty
            ? null
            : _batchNumberController.text,
        purchaseDate: _purchaseDate,
        expirationDate: _expirationDate,
        purchasePrice: double.parse(_priceController.text),
        supplier:
            _supplierController.text.isEmpty ? null : _supplierController.text,
        storageLocation:
            _locationController.text.isEmpty ? null : _locationController.text,
        createdAt: widget.existingEntry?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final inventoryActions = ref.read(inventoryActionsProvider);
      if (widget.existingEntry != null) {
        await inventoryActions.updateEntry(entry);
      } else {
        await inventoryActions.addEntry(entry);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving entry: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingEntry == null
              ? 'Add Inventory Entry'
              : 'Edit Inventory Entry',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _quantityController,
              decoration: const InputDecoration(
                labelText: 'Current Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the quantity';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minimumQuantityController,
              decoration: const InputDecoration(
                labelText: 'Minimum Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the minimum quantity';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reorderPointController,
              decoration: const InputDecoration(
                labelText: 'Reorder Point',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the reorder point';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _batchNumberController,
              decoration: const InputDecoration(
                labelText: 'Batch Number (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Purchase Date'),
              subtitle: Text(_purchaseDate.toString().split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectPurchaseDate,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Expiration Date (Optional)'),
              subtitle: Text(
                _expirationDate?.toString().split(' ')[0] ?? 'Not set',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_expirationDate != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() => _expirationDate = null);
                      },
                    ),
                  const Icon(Icons.calendar_today),
                ],
              ),
              onTap: _selectExpirationDate,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Purchase Price',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the purchase price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _supplierController,
              decoration: const InputDecoration(
                labelText: 'Supplier (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Storage Location (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveEntry,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Entry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
