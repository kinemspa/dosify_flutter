import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/themes/app_theme.dart';
import '../domain/providers/medication_providers.dart';
import 'medication_form_screen.dart';

class MedicationDetailScreen extends ConsumerWidget {
  final String medicationId;

  const MedicationDetailScreen({required this.medicationId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationAsync = ref.watch(medicationProvider(medicationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication Details'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              medicationAsync.whenData((medication) {
                if (medication != null) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MedicationFormScreen(medication: medication),
                    ),
                  );
                }
              });
            },
          ),
        ],
      ),
      body: medicationAsync.when(
        data: (medication) {
          if (medication == null) {
            return const Center(
              child: Text('Medication not found.'),
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _DetailItem(label: 'Name', value: medication.name),
              _DetailItem(label: 'Type', value: medication.type.name),
              _DetailItem(label: 'Strength', value: '${medication.strength} ${medication.unit}'),
              _DetailItem(label: 'Stock', value: medication.stock.toString()),
              if (medication.expirationDate != null)
                _DetailItem(
                  label: 'Expiration Date',
                  value:
                      '${medication.expirationDate!.day}/${medication.expirationDate!.month}/${medication.expirationDate!.year}',
                ),
              if (medication.reconstitution != null && medication.reconstitution!) ...[
                const SizedBox(height: 16),
                const Divider(),
                const Text(
                  'Reconstitution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                medication.components != null
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: medication.components!
                            .map((component) => _DetailItem(label: 'Component', value: component))
                            .toList(),
                      )
                    : const Text('No components specified'),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              const Text('Error loading medication.'),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;

  const _DetailItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
