import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/reconstitution_calculator.dart';

class ReconstitutionCalculatorScreen extends ConsumerStatefulWidget {
  const ReconstitutionCalculatorScreen({super.key});

  @override
  ConsumerState<ReconstitutionCalculatorScreen> createState() => _ReconstitutionCalculatorScreenState();
}

class _ReconstitutionCalculatorScreenState extends ConsumerState<ReconstitutionCalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _powderAmountController = TextEditingController();
  final _solventVolumeController = TextEditingController();
  final _desiredDoseController = TextEditingController();
  
  Map<String, double>? _results;

  @override
  void dispose() {
    _powderAmountController.dispose();
    _solventVolumeController.dispose();
    _desiredDoseController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    try {
      final results = ReconstitutionCalculator.calculateComplete(
        powderAmount: double.parse(_powderAmountController.text),
        solventVolume: double.parse(_solventVolumeController.text),
        desiredDose: double.parse(_desiredDoseController.text),
      );

      setState(() {
        _results = results;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error in calculation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clear() {
    setState(() {
      _powderAmountController.clear();
      _solventVolumeController.clear();
      _desiredDoseController.clear();
      _results = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconstitution Calculator'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clear,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Enter the medication details to calculate reconstitution:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _powderAmountController,
              decoration: const InputDecoration(
                labelText: 'Powder Amount (mg)',
                hintText: 'e.g., 10',
                prefixIcon: Icon(Icons.medication),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter powder amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _solventVolumeController,
              decoration: const InputDecoration(
                labelText: 'Solvent Volume (ml)',
                hintText: 'e.g., 2.0',
                prefixIcon: Icon(Icons.water_drop),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter solvent volume';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _desiredDoseController,
              decoration: const InputDecoration(
                labelText: 'Desired Dose (mg)',
                hintText: 'e.g., 2.5',
                prefixIcon: Icon(Icons.straighten),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter desired dose';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _calculate,
              child: const Text('Calculate'),
            ),
            if (_results != null) ...[
              const SizedBox(height: 32),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Results',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ResultItem(
                        label: 'Total Solution Volume',
                        value: '${_results!['totalSolutionVolume']!.toStringAsFixed(2)} ml',
                        icon: Icons.science,
                      ),
                      _ResultItem(
                        label: 'Actual Concentration',
                        value: '${_results!['actualConcentration']!.toStringAsFixed(2)} mg/ml',
                        icon: Icons.analytics,
                      ),
                      _ResultItem(
                        label: 'Volume Per Dose',
                        value: '${_results!['volumePerDose']!.toStringAsFixed(2)} ml',
                        icon: Icons.colorize,
                        highlight: true,
                      ),
                      _ResultItem(
                        label: 'Number of Doses',
                        value: '${_results!['numberOfDoses']!.toInt()}',
                        icon: Icons.format_list_numbered,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  border: Border.all(color: Colors.amber),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.amber),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Draw ${_results!['volumePerDose']!.toStringAsFixed(2)} ml from the reconstituted solution for each dose.',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool highlight;

  const _ResultItem({
    required this.label,
    required this.value,
    required this.icon,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight 
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: highlight 
            ? Border.all(color: Theme.of(context).colorScheme.primary)
            : null,
      ),
      child: Row(
        children: [
          Icon(
            icon, 
            color: highlight 
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[600],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: highlight 
                        ? Theme.of(context).colorScheme.primary
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
