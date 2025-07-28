import 'package:hive/hive.dart';
import '../../../core/data/models/dose_schedule.dart';
import '../../../core/domain/repositories/dose_schedule_repository.dart';

class DoseScheduleRepositoryImpl implements DoseScheduleRepository {
  final Box<DoseSchedule> _scheduleBox;

  DoseScheduleRepositoryImpl(this._scheduleBox);

  @override
  Future<List<DoseSchedule>> getAllSchedules() async {
    return _scheduleBox.values.toList();
  }

  @override
  Future<DoseSchedule?> getScheduleById(String id) async {
    return _scheduleBox.get(id);
  }

  @override
  Future<void> addSchedule(DoseSchedule schedule) async {
    await _scheduleBox.put(schedule.id, schedule);
  }

  @override
  Future<void> updateSchedule(DoseSchedule schedule) async {
    await _scheduleBox.put(schedule.id, schedule);
  }

  @override
  Future<void> deleteSchedule(String id) async {
    await _scheduleBox.delete(id);
  }

  @override
  Future<List<DoseSchedule>> getActiveSchedules() async {
    final now = DateTime.now();
    return _scheduleBox.values
        .where((schedule) => 
            schedule.isActive && 
            (schedule.endDate == null || schedule.endDate!.isAfter(now)))
        .toList();
  }

  @override
  Future<List<DoseSchedule>> getSchedulesForMedication(String medicationId) async {
    return _scheduleBox.values
        .where((schedule) => schedule.medId == medicationId)
        .toList();
  }

  @override
  Future<List<DoseSchedule>> getTodaysSchedules() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return _scheduleBox.values
        .where((schedule) => 
            schedule.isActive && 
            schedule.startDate.isBefore(today.add(const Duration(days: 1))) &&
            (schedule.endDate == null || schedule.endDate!.isAfter(today)))
        .toList();
  }

  @override
  Stream<List<DoseSchedule>> watchAllSchedules() {
    return _scheduleBox.watch().map((_) => _scheduleBox.values.toList());
  }
}
