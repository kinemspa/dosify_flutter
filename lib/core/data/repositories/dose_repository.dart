import '../models/dose.dart';

abstract class DoseRepository {
  // Basic CRUD operations
  Future<List<Dose>> getAllDoses();
  Future<Dose?> getDoseById(String id);
  Future<void> saveDose(Dose dose);
  Future<void> updateDose(Dose dose);
  Future<void> deleteDose(String id);
  Future<void> deleteAllDoses();

  // Medication-specific operations
  Future<List<Dose>> getDosesByMedicationId(String medicationId);
  Future<void> deleteDosesByMedicationId(String medicationId);

  // Schedule-specific operations
  Future<List<Dose>> getDosesByScheduleId(String scheduleId);
  Future<void> deleteDosesByScheduleId(String scheduleId);

  // Time-based queries
  Future<List<Dose>> getDosesInDateRange(DateTime start, DateTime end);
  Future<List<Dose>> getDosesForDate(DateTime date);
  Future<List<Dose>> getUpcomingDoses({int limitHours = 24});
  Future<List<Dose>> getOverdueDoses();
  Future<List<Dose>> getTodaysDoses();

  // Status-based queries
  Future<List<Dose>> getDosesByStatus(DoseStatus status);
  Future<List<Dose>> getCompletedDoses();
  Future<List<Dose>> getPendingDoses();
  Future<List<Dose>> getMissedDoses();

  // Advanced queries
  Future<List<Dose>> getDosesWithSideEffects();
  Future<List<Dose>> getDosesWithEffectivenessRating({int? minRating, int? maxRating});
  Future<List<Dose>> getLateDoses({Duration? threshold});
  Future<List<Dose>> getDosesRequiringReconstitution();

  // Analytics and reporting
  Future<double> getAverageEffectivenessRating(String medicationId, {DateTime? startDate, DateTime? endDate});
  Future<double> getComplianceRate(String medicationId, {DateTime? startDate, DateTime? endDate});
  Future<Map<DoseStatus, int>> getDoseStatusCounts({DateTime? startDate, DateTime? endDate});
  Future<List<String>> getCommonSideEffects(String medicationId);
  Future<Duration> getAverageTimingVariance(String medicationId);

  // Bulk operations
  Future<void> saveDoses(List<Dose> doses);
  Future<void> updateDoses(List<Dose> doses);
  Future<void> markDosesAsStatus(List<String> doseIds, DoseStatus status);

  // Search and filtering
  Future<List<Dose>> searchDoses(String query);
  Future<List<Dose>> getDosesWithNotes();
  Future<List<Dose>> getDosesByInjectionSite(String site);

  // Stock management related
  Future<List<Dose>> getDosesAffectingStock(String medicationId);
  Future<double?> getLastRecordedStock(String medicationId);

  // Reconstitution tracking
  Future<List<Dose>> getDosesByReconstitutionId(String reconstitutionId);
  Future<List<Dose>> getDosesFromExpiredReconstitutions();

  // Data integrity
  Future<void> cleanupOrphanedDoses(); // Remove doses with invalid medication/schedule IDs
  Future<List<String>> validateDoseIntegrity(); // Return list of issues found
}
