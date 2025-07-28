import '../models/medication_schedule.dart';

abstract class ScheduleRepository {
  // Create
  Future<void> createSchedule(MedicationSchedule schedule);

  // Read
  Future<List<MedicationSchedule>> getAllSchedules();
  Future<MedicationSchedule?> getScheduleById(String id);
  Future<List<MedicationSchedule>> getSchedulesByMedicationId(String medicationId);
  Future<List<MedicationSchedule>> getActiveSchedules();
  Future<List<MedicationSchedule>> getSchedulesForDate(DateTime date);
  Future<List<MedicationSchedule>> getSchedulesForDateRange(DateTime start, DateTime end);

  // Update
  Future<void> updateSchedule(MedicationSchedule schedule);
  Future<void> toggleScheduleActive(String id, bool isActive);

  // Delete
  Future<void> deleteSchedule(String id);
  Future<void> deleteSchedulesByMedicationId(String medicationId);

  // Utility
  Future<bool> hasActiveScheduleForMedication(String medicationId);
  Future<List<DateTime>> getUpcomingDoses(int count, {DateTime? from});
  Future<int> getScheduleCount();
}
