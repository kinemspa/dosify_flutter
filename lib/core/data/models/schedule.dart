import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'medication.dart';

part 'schedule.g.dart';

@HiveType(typeId: 30)
@JsonSerializable()
class Schedule extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String medicationId; // Foreign key to Medication

  @HiveField(2)
  final String name;

  @HiveField(3)
  final double doseAmount;

  @HiveField(4)
  final DoseUnit doseUnit;

  @HiveField(5)
  final ScheduleFrequency frequency;

  @HiveField(6)
  final List<TimeOfDay> times;

  @HiveField(7)
  final DateTime startDate;

  @HiveField(8)
  final DateTime? endDate;

  @HiveField(9)
  final List<DayOfWeek>? specificDays; // For weekly schedules

  @HiveField(10)
  final int? intervalDays; // For "every X days" schedules

  @HiveField(11)
  final bool isActive;

  @HiveField(12)
  final String? notes;

  @HiveField(13)
  final DateTime createdAt;

  @HiveField(14)
  final DateTime updatedAt;

  @HiveField(15)
  final ScheduleType scheduleType;

  @HiveField(16)
  final InjectionSite? injectionSite; // For injection medications

  @HiveField(17)
  final ReconstitutionInfo? reconstitutionInfo; // For lyophilized vials

  Schedule({
    required this.id,
    required this.medicationId,
    required this.name,
    required this.doseAmount,
    required this.doseUnit,
    required this.frequency,
    required this.times,
    required this.startDate,
    this.endDate,
    this.specificDays,
    this.intervalDays,
    required this.isActive,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.scheduleType,
    this.injectionSite,
    this.reconstitutionInfo,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$ScheduleToJson(this);

  Schedule copyWith({
    String? id,
    String? medicationId,
    String? name,
    double? doseAmount,
    DoseUnit? doseUnit,
    ScheduleFrequency? frequency,
    List<TimeOfDay>? times,
    DateTime? startDate,
    DateTime? endDate,
    List<DayOfWeek>? specificDays,
    int? intervalDays,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    ScheduleType? scheduleType,
    InjectionSite? injectionSite,
    ReconstitutionInfo? reconstitutionInfo,
  }) {
    return Schedule(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      name: name ?? this.name,
      doseAmount: doseAmount ?? this.doseAmount,
      doseUnit: doseUnit ?? this.doseUnit,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      specificDays: specificDays ?? this.specificDays,
      intervalDays: intervalDays ?? this.intervalDays,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      scheduleType: scheduleType ?? this.scheduleType,
      injectionSite: injectionSite ?? this.injectionSite,
      reconstitutionInfo: reconstitutionInfo ?? this.reconstitutionInfo,
    );
  }
}

@HiveType(typeId: 31)
@JsonSerializable()
class TimeOfDay {
  @HiveField(0)
  final int hour;

  @HiveField(1)
  final int minute;

  TimeOfDay({required this.hour, required this.minute});

  factory TimeOfDay.fromJson(Map<String, dynamic> json) =>
      _$TimeOfDayFromJson(json);

  Map<String, dynamic> toJson() => _$TimeOfDayToJson(this);

  @override
  String toString() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  bool operator ==(Object other) =>
      other is TimeOfDay && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => hour.hashCode ^ minute.hashCode;
}

@HiveType(typeId: 32)
@JsonSerializable()
class ReconstitutionInfo {
  @HiveField(0)
  final double diluent; // ml of diluent to add

  @HiveField(1)
  final String diluentType; // e.g., "Bacteriostatic Water", "Saline"

  @HiveField(2)
  final double finalConcentration; // mg/ml after reconstitution

  @HiveField(3)
  final int shelfLifeHours; // How long it's stable after reconstitution

  @HiveField(4)
  final StorageConditions storageAfterReconstitution;

  ReconstitutionInfo({
    required this.diluent,
    required this.diluentType,
    required this.finalConcentration,
    required this.shelfLifeHours,
    required this.storageAfterReconstitution,
  });

  factory ReconstitutionInfo.fromJson(Map<String, dynamic> json) =>
      _$ReconstitutionInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ReconstitutionInfoToJson(this);
}

@HiveType(typeId: 33)
enum ScheduleFrequency {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  everyXDays,
  @HiveField(4)
  asNeeded,
  @HiveField(5)
  specificDays,
}

@HiveType(typeId: 34)
enum ScheduleType {
  @HiveField(0)
  regular, // Normal scheduled doses
  @HiveField(1)
  prn, // As needed
  @HiveField(2)
  tapering, // Gradually decreasing dose
  @HiveField(3)
  loading, // Loading dose followed by maintenance
}

@HiveType(typeId: 35)
enum DayOfWeek {
  @HiveField(0)
  monday,
  @HiveField(1)
  tuesday,
  @HiveField(2)
  wednesday,
  @HiveField(3)
  thursday,
  @HiveField(4)
  friday,
  @HiveField(5)
  saturday,
  @HiveField(6)
  sunday,
}

@HiveType(typeId: 36)
enum InjectionSite {
  @HiveField(0)
  abdomen,
  @HiveField(1)
  thigh,
  @HiveField(2)
  arm,
  @HiveField(3)
  buttocks,
  @HiveField(4)
  rotatingSites, // Automatically rotate between sites
}

// Helper extensions
extension DayOfWeekExtension on DayOfWeek {
  String get displayName {
    switch (this) {
      case DayOfWeek.monday:
        return 'Monday';
      case DayOfWeek.tuesday:
        return 'Tuesday';
      case DayOfWeek.wednesday:
        return 'Wednesday';
      case DayOfWeek.thursday:
        return 'Thursday';
      case DayOfWeek.friday:
        return 'Friday';
      case DayOfWeek.saturday:
        return 'Saturday';
      case DayOfWeek.sunday:
        return 'Sunday';
    }
  }

  int get weekdayNumber {
    switch (this) {
      case DayOfWeek.monday:
        return 1;
      case DayOfWeek.tuesday:
        return 2;
      case DayOfWeek.wednesday:
        return 3;
      case DayOfWeek.thursday:
        return 4;
      case DayOfWeek.friday:
        return 5;
      case DayOfWeek.saturday:
        return 6;
      case DayOfWeek.sunday:
        return 7;
    }
  }
}

extension ScheduleFrequencyExtension on ScheduleFrequency {
  String get displayName {
    switch (this) {
      case ScheduleFrequency.daily:
        return 'Daily';
      case ScheduleFrequency.weekly:
        return 'Weekly';
      case ScheduleFrequency.monthly:
        return 'Monthly';
      case ScheduleFrequency.everyXDays:
        return 'Every X Days';
      case ScheduleFrequency.asNeeded:
        return 'As Needed';
      case ScheduleFrequency.specificDays:
        return 'Specific Days';
    }
  }
}
