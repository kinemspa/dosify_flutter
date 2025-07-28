import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/data/repositories/medication_repository.dart';
import '../../../../core/data/repositories/hive_medication_repository.dart';
import '../../../../core/data/models/medication.dart';

// Repository provider
final medicationRepositoryProvider = Provider<MedicationRepository>((ref) {
  return HiveMedicationRepository();
});

// All medications provider
final medicationsProvider = FutureProvider<List<Medication>>((ref) async {
  final repository = ref.read(medicationRepositoryProvider);
  return await repository.getAllMedications();
});

// Search medications provider
final searchMedicationsProvider = FutureProvider.family<List<Medication>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final allMedications = await ref.watch(medicationsProvider.future);
  return allMedications.where((med) => 
    med.name.toLowerCase().contains(query.toLowerCase())).toList();
});

// Single medication provider
final medicationProvider = FutureProvider.family<Medication?, String>((ref, id) async {
  final repository = ref.read(medicationRepositoryProvider);
  return await repository.getMedicationById(id);
});

// Medication actions provider
final medicationActionsProvider = Provider((ref) => MedicationActions(ref));

class MedicationActions {
  final Ref _ref;
  
  MedicationActions(this._ref);
  
  MedicationRepository get _repository => _ref.read(medicationRepositoryProvider);

  Future<void> addMedication(Medication medication) async {
    await _repository.saveMedication(medication);
    _ref.invalidate(medicationsProvider);
  }

  Future<void> updateMedication(Medication medication) async {
    await _repository.updateMedication(medication);
    _ref.invalidate(medicationsProvider);
    _ref.invalidate(medicationProvider(medication.id));
  }

  Future<void> deleteMedication(String id) async {
    await _repository.deleteMedication(id);
    _ref.invalidate(medicationsProvider);
    _ref.invalidate(medicationProvider(id));
  }

  Future<void> updateStock(String medicationId, double newStock) async {
    final medication = await _repository.getMedicationById(medicationId);
    if (medication != null) {
      final updatedMedication = medication.copyWith(
        stock: newStock,
        updatedAt: DateTime.now(),
      );
      await updateMedication(updatedMedication);
    }
  }
}
