import '../../../core/data/models/dose_schedule.dart';

abstract class DoseScheduleRepository {
  Future<List<DoseSchedule>> getAllSchedules();
  Future<DoseSchedule?> getScheduleById(String id);
  Future<void> addSchedule(DoseSchedule schedule);
  Future<void> updateSchedule(DoseSchedule schedule);
  Future<void> deleteSchedule(String id);
  Future<List<DoseSchedule>> getActiveSchedules();
  Future<List<DoseSchedule>> getSchedulesForMedication(String medicationId);
  Future<List<DoseSchedule>> getTodaysSchedules();
  Stream<List<DoseSchedule>> watchAllSchedules();
}
