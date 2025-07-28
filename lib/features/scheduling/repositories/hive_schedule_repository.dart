import 'package:hive/hive.dart';
import '../../../core/services/hive_service.dart';
import '../models/medication_schedule.dart';
import 'schedule_repository.dart';

class HiveScheduleRepository implements ScheduleRepository {
  final HiveService _hiveService;
  static const String _boxName = 'medication_schedules';

  HiveScheduleRepository(this._hiveService);

  Box<MedicationSchedule> get _box => _hiveService.getBox<MedicationSchedule>(_boxName);

  @override
  Future<void> createSchedule(MedicationSchedule schedule) async {
    await _box.put(schedule.id, schedule);
  }

  @override
  Future<List<MedicationSchedule>> getAllSchedules() async {
    return _box.values.toList();
  }

  @override
  Future<MedicationSchedule?> getScheduleById(String id) async {
    return _box.get(id);
  }

  @override
  Future<List<MedicationSchedule>> getSchedulesByMedicationId(String medicationId) async {
    return _box.values
        .where((schedule) => schedule.medicationId == medicationId)
        .toList();
  }

  @override
  Future<List<MedicationSchedule>> getActiveSchedules() async {
    final now = DateTime.now();
    return _box.values
        .where((schedule) => 
            schedule.isActive && 
            (schedule.endDate == null || schedule.endDate!.isAfter(now)))
        .toList();
  }

  @override
  Future<List<MedicationSchedule>> getSchedulesForDate(DateTime date) async {
    final schedules = await getActiveSchedules();
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    return schedules.where((schedule) {
      // Check if schedule is active on this date
      if (schedule.startDate.isAfter(dateOnly)) return false;
      if (schedule.endDate != null && schedule.endDate!.isBefore(dateOnly)) return false;
      
      // Check if schedule has doses on this date
      final upcomingDoses = schedule.getUpcomingDoses(from: dateOnly, limit: 50);
      return upcomingDoses.any((dose) => 
          DateTime(dose.year, dose.month, dose.day) == dateOnly);
    }).toList();
  }

  @override
  Future<List<MedicationSchedule>> getSchedulesForDateRange(DateTime start, DateTime end) async {
    final schedules = await getActiveSchedules();
    
    return schedules.where((schedule) {
      // Check if schedule overlaps with date range
      if (schedule.startDate.isAfter(end)) return false;
      if (schedule.endDate != null && schedule.endDate!.isBefore(start)) return false;
      
      return true;
    }).toList();
  }

  @override
  Future<void> updateSchedule(MedicationSchedule schedule) async {
    await _box.put(schedule.id, schedule);
  }

  @override
  Future<void> toggleScheduleActive(String id, bool isActive) async {
    final schedule = await getScheduleById(id);
    if (schedule != null) {
      final updatedSchedule = MedicationSchedule(
        id: schedule.id,
        medicationId: schedule.medicationId,
        medicationName: schedule.medicationName,
        scheduledTimes: schedule.scheduledTimes,
        frequency: schedule.frequency,
        dosageAmount: schedule.dosageAmount,
        dosageUnit: schedule.dosageUnit,
        startDate: schedule.startDate,
        endDate: schedule.endDate,
        isActive: isActive,
        reminderEnabled: schedule.reminderEnabled,
        customInterval: schedule.customInterval,
        notes: schedule.notes,
        createdAt: schedule.createdAt,
        updatedAt: DateTime.now(),
      );
      await updateSchedule(updatedSchedule);
    }
  }

  @override
  Future<void> deleteSchedule(String id) async {
    await _box.delete(id);
  }

  @override
  Future<void> deleteSchedulesByMedicationId(String medicationId) async {
    final schedules = await getSchedulesByMedicationId(medicationId);
    for (final schedule in schedules) {
      await deleteSchedule(schedule.id);
    }
  }

  @override
  Future<bool> hasActiveScheduleForMedication(String medicationId) async {
    final schedules = await getSchedulesByMedicationId(medicationId);
    return schedules.any((schedule) => 
        schedule.isActive && 
        (schedule.endDate == null || schedule.endDate!.isAfter(DateTime.now())));
  }

  @override
  Future<List<DateTime>> getUpcomingDoses(int count, {DateTime? from}) async {
    final schedules = await getActiveSchedules();
    final allDoses = <DateTime>[];
    
    for (final schedule in schedules) {
      final doses = schedule.getUpcomingDoses(from: from, limit: count * 2);
      allDoses.addAll(doses);
    }
    
    // Sort and return the requested count
    allDoses.sort();
    return allDoses.take(count).toList();
  }

  @override
  Future<int> getScheduleCount() async {
    return _box.length;
  }
}
