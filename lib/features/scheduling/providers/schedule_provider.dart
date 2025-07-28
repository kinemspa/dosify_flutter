import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/hive_provider.dart';
import '../../../core/services/notification_service.dart';
import '../models/medication_schedule.dart';
import '../repositories/hive_schedule_repository.dart';
import '../repositories/schedule_repository.dart';

// Repository provider
final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return HiveScheduleRepository(hiveService);
});

// Schedule state providers
final scheduleListProvider = FutureProvider<List<MedicationSchedule>>((ref) async {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.getAllSchedules();
});

final activeSchedulesProvider = FutureProvider<List<MedicationSchedule>>((ref) async {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.getActiveSchedules();
});

// Schedule for specific medication
final schedulesByMedicationProvider = FutureProvider.family<List<MedicationSchedule>, String>((ref, medicationId) async {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.getSchedulesByMedicationId(medicationId);
});

// Schedules for specific date
final schedulesForDateProvider = FutureProvider.family<List<MedicationSchedule>, DateTime>((ref, date) async {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.getSchedulesForDate(date);
});

// Upcoming doses
final upcomingDosesProvider = FutureProvider.family<List<DateTime>, int>((ref, count) async {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.getUpcomingDoses(count);
});

// Schedule actions provider
final scheduleActionsProvider = Provider<ScheduleActions>((ref) {
  final repository = ref.watch(scheduleRepositoryProvider);
  return ScheduleActions(repository, ref);
});

class ScheduleActions {
  final ScheduleRepository _repository;
  final Ref _ref;
  final NotificationService _notificationService = NotificationService();

  ScheduleActions(this._repository, this._ref);

  Future<void> createSchedule(MedicationSchedule schedule) async {
    await _repository.createSchedule(schedule);
    if (schedule.reminderEnabled && schedule.isActive) {
      await _notificationService.scheduleReminders(schedule);
    }
    _ref.invalidate(scheduleListProvider);
    _ref.invalidate(activeSchedulesProvider);
    _ref.invalidate(schedulesByMedicationProvider(schedule.medicationId));
  }

  Future<void> updateSchedule(MedicationSchedule schedule) async {
    await _repository.updateSchedule(schedule);
    await _notificationService.cancelScheduleReminders(schedule.id);
    if (schedule.reminderEnabled && schedule.isActive) {
      await _notificationService.scheduleReminders(schedule);
    }
    _ref.invalidate(scheduleListProvider);
    _ref.invalidate(activeSchedulesProvider);
    _ref.invalidate(schedulesByMedicationProvider(schedule.medicationId));
  }

  Future<void> toggleScheduleActive(String id, bool isActive) async {
    await _repository.toggleScheduleActive(id, isActive);
    _ref.invalidate(scheduleListProvider);
    _ref.invalidate(activeSchedulesProvider);
    
    // Find and invalidate specific medication schedules
    final schedule = await _repository.getScheduleById(id);
    if (schedule != null) {
      await _notificationService.cancelScheduleReminders(id);
      if (isActive && schedule.reminderEnabled) {
        await _notificationService.scheduleReminders(schedule);
      }
      _ref.invalidate(schedulesByMedicationProvider(schedule.medicationId));
    }
  }

  Future<void> deleteSchedule(String id) async {
    final schedule = await _repository.getScheduleById(id);
    await _repository.deleteSchedule(id);
    await _notificationService.cancelScheduleReminders(id);
    
    _ref.invalidate(scheduleListProvider);
    _ref.invalidate(activeSchedulesProvider);
    
    if (schedule != null) {
      _ref.invalidate(schedulesByMedicationProvider(schedule.medicationId));
    }
  }

  Future<void> deleteSchedulesByMedicationId(String medicationId) async {
    final schedules = await _repository.getSchedulesByMedicationId(medicationId);
    await _repository.deleteSchedulesByMedicationId(medicationId);
    
    for (final schedule in schedules) {
      await _notificationService.cancelScheduleReminders(schedule.id);
    }
    
    _ref.invalidate(scheduleListProvider);
    _ref.invalidate(activeSchedulesProvider);
    _ref.invalidate(schedulesByMedicationProvider(medicationId));
  }

  Future<bool> hasActiveScheduleForMedication(String medicationId) async {
    return _repository.hasActiveScheduleForMedication(medicationId);
  }
}
