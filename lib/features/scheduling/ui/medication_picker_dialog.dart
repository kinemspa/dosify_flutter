import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/models/medication.dart';
import '../../medication/domain/providers/medication_providers.dart';

class MedicationPickerDialog extends ConsumerStatefulWidget {
  const MedicationPickerDialog({super.key});

  @override
  ConsumerState<MedicationPickerDialog> createState() =>
      _MedicationPickerDialogState();
}

class _MedicationPickerDialogState extends ConsumerState<MedicationPickerDialog> {
  String _searchQuery = '';
  List<Medication> _filteredMedications = [];

  @override
  Widget build(BuildContext context) {
    final medicationsState = ref.watch(medicationsProvider);

    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Medication',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                  if (medicationsState.hasValue) {
                    _filteredMedications = medicationsState.value!
                        .where((med) =>
                            med.name.toLowerCase().contains(_searchQuery) ||
                            med.description
                                ?.toLowerCase()
                                .contains(_searchQuery) ==
                                true)
                        .toList();
                  }
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search medications...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: medicationsState.when(
                data: (medications) {
                  final displayedMedications =
                      _searchQuery.isEmpty ? medications : _filteredMedications;

                  if (displayedMedications.isEmpty) {
                    return const Center(
                      child: Text('No medications found'),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: displayedMedications.length,
                    itemBuilder: (context, index) {
                      final medication = displayedMedications[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(medication.name[0].toUpperCase()),
                        ),
                        title: Text(medication.name),
                        subtitle: Text(
                          medication.description ?? 'No description',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.of(context).pop(medication);
                        },
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Text('Error: $error'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('CANCEL'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
