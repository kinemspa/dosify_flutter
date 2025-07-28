import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dose_schedule.g.dart';

@HiveType(typeId: 2)
@JsonSerializable()
class DoseSchedule extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String medId;

  @HiveField(2)
  final double doseAmount;

  @HiveField(3)
  final String unit;

  @HiveField(4)
  final Frequency frequency;

  @HiveField(5)
  final List<String> times; // TimeOfDay serialized as strings

  @HiveField(6)
  final DateTime startDate;

  @HiveField(7)
  final DateTime? endDate;

  @HiveField(8)
  final bool isActive;

  @HiveField(9)
  final int? cycleWeeks; // IAP feature

  @HiveField(10)
  final int? cycleOffWeeks; // IAP feature

  @HiveField(11)
  final bool? isCycling; // IAP feature

  @HiveField(12)
  final List<TitrationStep>? titrationSteps; // IAP feature

  @HiveField(13)
  final String? reminderSettings; // JSON string

  @HiveField(14)
  final DateTime createdAt;

  @HiveField(15)
  final DateTime updatedAt;

  DoseSchedule({
    required this.id,
    required this.medId,
    required this.doseAmount,
    required this.unit,
    required this.frequency,
    required this.times,
    required this.startDate,
    this.endDate,
    required this.isActive,
    this.cycleWeeks,
    this.cycleOffWeeks,
    this.isCycling,
    this.titrationSteps,
    this.reminderSettings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DoseSchedule.fromJson(Map<String, dynamic> json) =>
      _$DoseScheduleFromJson(json);

  Map<String, dynamic> toJson() => _$DoseScheduleToJson(this);

  DoseSchedule copyWith({
    String? id,
    String? medId,
    double? doseAmount,
    String? unit,
    Frequency? frequency,
    List<String>? times,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? cycleWeeks,
    int? cycleOffWeeks,
    bool? isCycling,
    List<TitrationStep>? titrationSteps,
    String? reminderSettings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoseSchedule(
      id: id ?? this.id,
      medId: medId ?? this.medId,
      doseAmount: doseAmount ?? this.doseAmount,
      unit: unit ?? this.unit,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      cycleWeeks: cycleWeeks ?? this.cycleWeeks,
      cycleOffWeeks: cycleOffWeeks ?? this.cycleOffWeeks,
      isCycling: isCycling ?? this.isCycling,
      titrationSteps: titrationSteps ?? this.titrationSteps,
      reminderSettings: reminderSettings ?? this.reminderSettings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@HiveType(typeId: 3)
enum Frequency {
  @HiveField(0)
  asNeeded,
  @HiveField(1)
  daily,
  @HiveField(2)
  twiceDaily,
  @HiveField(3)
  thriceDaily,
  @HiveField(4)
  fourTimesDaily,
  @HiveField(5)
  everyOtherDay,
  @HiveField(6)
  weekly,
  @HiveField(7)
  biweekly,
  @HiveField(8)
  monthly,
  @HiveField(9)
  custom,
}

@HiveType(typeId: 4)
@JsonSerializable()
class TitrationStep extends HiveObject {
  @HiveField(0)
  final int period; // days

  @HiveField(1)
  final double doseAmount;

  @HiveField(2)
  final String unit;

  @HiveField(3)
  final DateTime createdAt;

  TitrationStep({
    required this.period,
    required this.doseAmount,
    required this.unit,
    required this.createdAt,
  });

  factory TitrationStep.fromJson(Map<String, dynamic> json) =>
      _$TitrationStepFromJson(json);

  Map<String, dynamic> toJson() => _$TitrationStepToJson(this);
}
