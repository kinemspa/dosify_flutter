import 'package:hive/hive.dart';
import '../../../core/data/models/medication.dart';
import '../../../core/domain/repositories/medication_repository.dart';

class MedicationRepositoryImpl implements MedicationRepository {
  final Box<Medication> _medicationBox;

  MedicationRepositoryImpl(this._medicationBox);

  @override
  Future<List<Medication>> getAllMedications() async {
    return _medicationBox.values.toList();
  }

  @override
  Future<Medication?> getMedicationById(String id) async {
    return _medicationBox.get(id);
  }

  @override
  Future<void> addMedication(Medication medication) async {
    await _medicationBox.put(medication.id, medication);
  }

  @override
  Future<void> updateMedication(Medication medication) async {
    await _medicationBox.put(medication.id, medication);
  }

  @override
  Future<void> deleteMedication(String id) async {
    await _medicationBox.delete(id);
  }

  @override
  Future<List<Medication>> searchMedications(String query) async {
    return _medicationBox.values
        .where((med) => med.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<Medication>> getLowStockMedications() async {
    return _medicationBox.values
        .where((med) => med.stock <= med.lowStockThreshold)
        .toList();
  }

  @override
  Future<List<Medication>> getExpiringMedications(int daysThreshold) async {
    final now = DateTime.now();
    return _medicationBox.values
        .where((med) => med.expirationDate != null && med.expirationDate!.difference(now).inDays <= daysThreshold)
        .toList();
  }

  @override
  Stream<List<Medication>> watchAllMedications() {
    return _medicationBox.watch().map((_) => _medicationBox.values.toList());
  }
}

