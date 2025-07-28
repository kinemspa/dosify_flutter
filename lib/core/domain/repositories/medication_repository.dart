import '../../../core/data/models/medication.dart';

abstract class MedicationRepository {
  Future<List<Medication>> getAllMedications();
  Future<Medication?> getMedicationById(String id);
  Future<void> addMedication(Medication medication);
  Future<void> updateMedication(Medication medication);
  Future<void> deleteMedication(String id);
  Future<List<Medication>> searchMedications(String query);
  Future<List<Medication>> getLowStockMedications();
  Future<List<Medication>> getExpiringMedications(int daysThreshold);
  Stream<List<Medication>> watchAllMedications();
}
