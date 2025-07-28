import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'medication_schedule.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class MedicationSchedule extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String medicationId;

  @HiveField(2)
  final String medicationName;

  @HiveField(3)
  final List<DateTime> scheduledTimes;

  @HiveField(4)
  final String frequency; // 'daily', 'weekly', 'monthly', 'custom'

  @HiveField(5)
  final int dosageAmount;

  @HiveField(6)
  final String dosageUnit;

  @HiveField(7)
  final DateTime startDate;

  @HiveField(8)
  final DateTime? endDate;

  @HiveField(9)
  final bool isActive;

  @HiveField(10)
  final String? notes;

  @HiveField(11)
  final List<int> weekdays; // For weekly schedules (0=Sunday, 6=Saturday)

  @HiveField(12)
  final int intervalDays; // For custom intervals

  @HiveField(13)
  final bool reminderEnabled;

  @HiveField(14)
  final int reminderMinutesBefore;

  @HiveField(15)
  final DateTime createdAt;

  @HiveField(16)
  final DateTime updatedAt;

  MedicationSchedule({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.scheduledTimes,
    required this.frequency,
    required this.dosageAmount,
    required this.dosageUnit,
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.notes,
    this.weekdays = const [],
    this.intervalDays = 1,
    this.reminderEnabled = true,
    this.reminderMinutesBefore = 15,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicationSchedule.fromJson(Map<String, dynamic> json) =>
      _$MedicationScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$MedicationScheduleToJson(this);

  MedicationSchedule copyWith({
    String? id,
    String? medicationId,
    String? medicationName,
    List<DateTime>? scheduledTimes,
    String? frequency,
    int? dosageAmount,
    String? dosageUnit,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    String? notes,
    List<int>? weekdays,
    int? intervalDays,
    bool? reminderEnabled,
    int? reminderMinutesBefore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MedicationSchedule(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      medicationName: medicationName ?? this.medicationName,
      scheduledTimes: scheduledTimes ?? this.scheduledTimes,
      frequency: frequency ?? this.frequency,
      dosageAmount: dosageAmount ?? this.dosageAmount,
      dosageUnit: dosageUnit ?? this.dosageUnit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      weekdays: weekdays ?? this.weekdays,
      intervalDays: intervalDays ?? this.intervalDays,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderMinutesBefore: reminderMinutesBefore ?? this.reminderMinutesBefore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  List<DateTime> getNextScheduledDoses(DateTime from, int count) {
    final List<DateTime> nextDoses = [];
    DateTime current = from;
    
    while (nextDoses.length < count) {
      for (final scheduledTime in scheduledTimes) {
        final nextDose = DateTime(
          current.year,
          current.month,
          current.day,
          scheduledTime.hour,
          scheduledTime.minute,
        );
        
        if (nextDose.isAfter(from) && _shouldTakeDoseOnDate(nextDose)) {
          nextDoses.add(nextDose);
          if (nextDoses.length >= count) break;
        }
      }
      current = current.add(const Duration(days: 1));
    }
    
    nextDoses.sort();
    return nextDoses.take(count).toList();
  }

  bool _shouldTakeDoseOnDate(DateTime date) {
    if (!isActive) return false;
    if (date.isBefore(startDate)) return false;
    if (endDate != null && date.isAfter(endDate!)) return false;

    switch (frequency) {
      case 'daily':
        return true;
      case 'weekly':
        return weekdays.contains(date.weekday % 7);
      case 'monthly':
        return date.day == startDate.day;
      case 'custom':
        final daysDifference = date.difference(startDate).inDays;
        return daysDifference % intervalDays == 0;
      default:
        return false;
    }
  }

  bool isScheduledForTime(DateTime dateTime) {
    if (!_shouldTakeDoseOnDate(dateTime)) return false;
    
    return scheduledTimes.any((scheduledTime) =>
        scheduledTime.hour == dateTime.hour &&
        scheduledTime.minute == dateTime.minute);
  }
}
