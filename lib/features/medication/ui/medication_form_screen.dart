import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/models/medication.dart';
import '../domain/providers/medication_providers.dart';

class MedicationFormScreen extends ConsumerStatefulWidget {
  final Medication? medication;

  const MedicationFormScreen({this.medication, super.key});

  @override
  ConsumerState<MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends ConsumerState<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _strengthController = TextEditingController();
  final _unitController = TextEditingController();
  final _stockController = TextEditingController();
  final _lowStockThresholdController = TextEditingController();

  MedicationType _selectedType = MedicationType.tablet;
  bool _isReconstitution = false;
  DateTime? _expirationDate;
  List<String> _components = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _populateFields(widget.medication!);
    }
  }

  void _populateFields(Medication medication) {
    _nameController.text = medication.name;
    _strengthController.text = medication.strength.toString();
    _unitController.text = medication.unit;
    _stockController.text = medication.stock.toString();
    _lowStockThresholdController.text = medication.lowStockThreshold.toString();
    _selectedType = medication.type;
    _isReconstitution = medication.reconstitution ?? false;
    _expirationDate = medication.expirationDate;
    _components = medication.components ?? [];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _strengthController.dispose();
    _unitController.dispose();
    _stockController.dispose();
    _lowStockThresholdController.dispose();
    super.dispose();
  }

  Future<void> _selectExpirationDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expirationDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _expirationDate = picked;
      });
    }
  }

  Future<void> _saveMedication() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final medication = Medication(
        id: widget.medication?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        type: _selectedType,
        category: MedicationCategory.oralMedication, // Adjust accordingly
        form: MedicationForm.tablet, // Adjust accordingly
        stockUnit: StockUnit.tablets, // Adjust accordingly
        strengthUnit: StrengthUnit.mg, // Adjust accordingly
        strength: double.parse(_strengthController.text),
        unit: _unitController.text.trim(),
        stock: double.parse(_stockController.text),
        lowStockThreshold: double.parse(_lowStockThresholdController.text),
        reconstitution: _isReconstitution,
        components: _components.isNotEmpty ? _components : null,
        expirationDate: _expirationDate,
        createdAt: widget.medication?.createdAt ?? now,
        updatedAt: now,
      );

      final actions = ref.read(medicationActionsProvider);
      if (widget.medication != null) {
        await actions.updateMedication(medication);
      } else {
        await actions.addMedication(medication);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.medication != null 
                  ? 'Medication updated successfully' 
                  : 'Medication added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving medication: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addComponent() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Add Component'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Component name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final component = controller.text.trim();
                if (component.isNotEmpty) {
                  setState(() {
                    _components.add(component);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medication != null ? 'Edit Medication' : 'Add Medication'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          if (widget.medication != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteDialog(),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Medication Name',
                hintText: 'Enter medication name',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter medication name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MedicationType>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
              ),
              items: MedicationType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _strengthController,
                    decoration: const InputDecoration(
                      labelText: 'Strength',
                      hintText: '10',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      hintText: 'mg',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'Current Stock',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid number';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lowStockThresholdController,
                    decoration: const InputDecoration(
                      labelText: 'Low Stock Alert',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid number';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Expiration Date'),
              subtitle: Text(
                _expirationDate != null
                    ? '${_expirationDate!.day}/${_expirationDate!.month}/${_expirationDate!.year}'
                    : 'Not set',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectExpirationDate,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Requires Reconstitution'),
              subtitle: const Text('For injectable medications'),
              value: _isReconstitution,
              onChanged: (value) {
                setState(() {
                  _isReconstitution = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            if (_isReconstitution) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Components',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _addComponent,
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
              if (_components.isNotEmpty)
                Column(
                  children: _components.map((component) {
                    return ListTile(
                      title: Text(component),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          setState(() {
                            _components.remove(component);
                          });
                        },
                      ),
                      contentPadding: EdgeInsets.zero,
                    );
                  }).toList(),
                ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _saveMedication,
          child: _isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.medication != null ? 'Update' : 'Save'),
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Medication'),
          content: const Text('Are you sure you want to delete this medication?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final actions = ref.read(medicationActionsProvider);
                await actions.deleteMedication(widget.medication!.id);
                if (mounted) {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close form
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Medication deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
