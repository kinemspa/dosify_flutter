import '../models/medication.dart';
import '../hive/hive_service.dart';
import 'medication_repository.dart';

class HiveMedicationRepository implements MedicationRepository {
  @override
  Future<List<Medication>> getAllMedications() async {
    return HiveService.medicationBox.values.toList();
  }

  @override
  Future<Medication?> getMedicationById(String id) async {
    return HiveService.medicationBox.get(id);
  }

  @override
  Future<void> saveMedication(Medication medication) async {
    await HiveService.medicationBox.put(medication.id, medication);
  }

  @override
  Future<void> updateMedication(Medication medication) async {
    await HiveService.medicationBox.put(medication.id, medication);
  }

  @override
  Future<void> deleteMedication(String id) async {
    await HiveService.medicationBox.delete(id);
  }

  @override
  Future<void> deleteAllMedications() async {
    await HiveService.medicationBox.clear();
  }
}
