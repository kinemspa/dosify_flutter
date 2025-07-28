import '../models/medication.dart';

abstract class MedicationRepository {
  Future<List<Medication>> getAllMedications();
  Future<Medication?> getMedicationById(String id);
  Future<void> saveMedication(Medication medication);
  Future<void> updateMedication(Medication medication);
  Future<void> deleteMedication(String id);
  Future<void> deleteAllMedications();
}
