import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'medication.dart';
import 'schedule.dart';

part 'dose.g.dart';

@HiveType(typeId: 40)
@JsonSerializable()
class Dose extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String medicationId; // Foreign key to Medication

  @HiveField(2)
  final String scheduleId; // Foreign key to Schedule

  @HiveField(3)
  final DateTime scheduledTime;

  @HiveField(4)
  final DateTime? actualTime; // When the dose was actually taken

  @HiveField(5)
  final double scheduledAmount;

  @HiveField(6)
  final double? actualAmount; // In case different from scheduled

  @HiveField(7)
  final DoseUnit unit;

  @HiveField(8)
  final DoseStatus status;

  @HiveField(9)
  final String? notes; // Patient notes about the dose

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final DateTime updatedAt;

  @HiveField(12)
  final InjectionSite? injectionSite; // For injections

  @HiveField(13)
  final SideEffects? sideEffects; // Track any adverse reactions

  @HiveField(14)
  final Effectiveness? effectiveness; // Patient-reported effectiveness

  @HiveField(15)
  final double? remainingStock; // Stock remaining after this dose

  @HiveField(16)
  final ReconstitutionRecord? reconstitutionUsed; // If reconstituted medication was used

  Dose({
    required this.id,
    required this.medicationId,
    required this.scheduleId,
    required this.scheduledTime,
    this.actualTime,
    required this.scheduledAmount,
    this.actualAmount,
    required this.unit,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.injectionSite,
    this.sideEffects,
    this.effectiveness,
    this.remainingStock,
    this.reconstitutionUsed,
  });

  factory Dose.fromJson(Map<String, dynamic> json) => _$DoseFromJson(json);

  Map<String, dynamic> toJson() => _$DoseToJson(this);

  Dose copyWith({
    String? id,
    String? medicationId,
    String? scheduleId,
    DateTime? scheduledTime,
    DateTime? actualTime,
    double? scheduledAmount,
    double? actualAmount,
    DoseUnit? unit,
    DoseStatus? status,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    InjectionSite? injectionSite,
    SideEffects? sideEffects,
    Effectiveness? effectiveness,
    double? remainingStock,
    ReconstitutionRecord? reconstitutionUsed,
  }) {
    return Dose(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      scheduleId: scheduleId ?? this.scheduleId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      actualTime: actualTime ?? this.actualTime,
      scheduledAmount: scheduledAmount ?? this.scheduledAmount,
      actualAmount: actualAmount ?? this.actualAmount,
      unit: unit ?? this.unit,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      injectionSite: injectionSite ?? this.injectionSite,
      sideEffects: sideEffects ?? this.sideEffects,
      effectiveness: effectiveness ?? this.effectiveness,
      remainingStock: remainingStock ?? this.remainingStock,
      reconstitutionUsed: reconstitutionUsed ?? this.reconstitutionUsed,
    );
  }

  // Helper methods
  bool get isTaken => status == DoseStatus.taken;
  bool get isMissed => status == DoseStatus.missed;
  bool get isScheduled => status == DoseStatus.scheduled;
  bool get isSkipped => status == DoseStatus.skipped;
  
  double get effectiveAmount => actualAmount ?? scheduledAmount;
  DateTime get effectiveTime => actualTime ?? scheduledTime;
  
  Duration? get timingVariance {
    if (actualTime == null) return null;
    return actualTime!.difference(scheduledTime);
  }

  bool get isLate {
    if (actualTime == null) return false;
    return actualTime!.isAfter(scheduledTime.add(const Duration(minutes: 15)));
  }

  bool get isEarly {
    if (actualTime == null) return false;
    return actualTime!.isBefore(scheduledTime.subtract(const Duration(minutes: 15)));
  }
}

@HiveType(typeId: 41)
@JsonSerializable()
class SideEffects {
  @HiveField(0)
  final SeverityLevel severity;

  @HiveField(1)
  final List<String> symptoms;

  @HiveField(2)
  final DateTime onsetTime;

  @HiveField(3)
  final Duration? duration;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final bool requiresMedicalAttention;

  SideEffects({
    required this.severity,
    required this.symptoms,
    required this.onsetTime,
    this.duration,
    this.notes,
    required this.requiresMedicalAttention,
  });

  factory SideEffects.fromJson(Map<String, dynamic> json) =>
      _$SideEffectsFromJson(json);

  Map<String, dynamic> toJson() => _$SideEffectsToJson(this);
}

@HiveType(typeId: 42)
@JsonSerializable()
class Effectiveness {
  @HiveField(0)
  final int rating; // 1-10 scale

  @HiveField(1)
  final String? notes;

  @HiveField(2)
  final DateTime assessmentTime;

  @HiveField(3)
  final List<String>? improvementAreas; // What improved

  @HiveField(4)
  final Duration? onsetTime; // How long until effect was felt

  Effectiveness({
    required this.rating,
    this.notes,
    required this.assessmentTime,
    this.improvementAreas,
    this.onsetTime,
  });

  factory Effectiveness.fromJson(Map<String, dynamic> json) =>
      _$EffectivenessFromJson(json);

  Map<String, dynamic> toJson() => _$EffectivenessToJson(this);
}

@HiveType(typeId: 43)
@JsonSerializable()
class ReconstitutionRecord {
  @HiveField(0)
  final String reconstitutionId; // Unique ID for this reconstitution batch

  @HiveField(1)
  final DateTime reconstitutedAt;

  @HiveField(2)
  final DateTime expiresAt;

  @HiveField(3)
  final double finalConcentration; // mg/ml

  @HiveField(4)
  final double totalVolumeReconstituted; // ml

  @HiveField(5)
  final double volumeUsedForThisDose; // ml used for this specific dose

  @HiveField(6)
  final double remainingVolume; // ml remaining after this dose

  ReconstitutionRecord({
    required this.reconstitutionId,
    required this.reconstitutedAt,
    required this.expiresAt,
    required this.finalConcentration,
    required this.totalVolumeReconstituted,
    required this.volumeUsedForThisDose,
    required this.remainingVolume,
  });

  factory ReconstitutionRecord.fromJson(Map<String, dynamic> json) =>
      _$ReconstitutionRecordFromJson(json);

  Map<String, dynamic> toJson() => _$ReconstitutionRecordToJson(this);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isExpiringSoon => 
      DateTime.now().isAfter(expiresAt.subtract(const Duration(hours: 2)));
}

@HiveType(typeId: 44)
enum DoseStatus {
  @HiveField(0)
  scheduled, // Future dose that's planned
  @HiveField(1)
  taken, // Dose was taken
  @HiveField(2)
  missed, // Dose was not taken when scheduled
  @HiveField(3)
  skipped, // Intentionally skipped (e.g., doctor's orders)
  @HiveField(4)
  partial, // Only part of the dose was taken
}

@HiveType(typeId: 45)
enum SeverityLevel {
  @HiveField(0)
  mild,
  @HiveField(1)
  moderate,
  @HiveField(2)
  severe,
  @HiveField(3)
  critical,
}

// Helper extensions
extension DoseStatusExtension on DoseStatus {
  String get displayName {
    switch (this) {
      case DoseStatus.scheduled:
        return 'Scheduled';
      case DoseStatus.taken:
        return 'Taken';
      case DoseStatus.missed:
        return 'Missed';
      case DoseStatus.skipped:
        return 'Skipped';
      case DoseStatus.partial:
        return 'Partial';
    }
  }

  bool get isCompleted => this == DoseStatus.taken || this == DoseStatus.partial;
  bool get requiresAction => this == DoseStatus.scheduled;
}

extension SeverityLevelExtension on SeverityLevel {
  String get displayName {
    switch (this) {
      case SeverityLevel.mild:
        return 'Mild';
      case SeverityLevel.moderate:
        return 'Moderate';
      case SeverityLevel.severe:
        return 'Severe';
      case SeverityLevel.critical:
        return 'Critical';
    }
  }
}
