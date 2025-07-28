import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'dose_log.g.dart';

@HiveType(typeId: 5)
@JsonSerializable()
class DoseLog extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String scheduleId;

  @HiveField(2)
  final DateTime takenTime;

  @HiveField(3)
  final double amountTaken;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final String? reaction;

  @HiveField(6)
  final List<int>? usedSupplies; // Supply IDs

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  DoseLog({
    required this.id,
    required this.scheduleId,
    required this.takenTime,
    required this.amountTaken,
    this.notes,
    this.reaction,
    this.usedSupplies,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DoseLog.fromJson(Map<String, dynamic> json) =>
      _$DoseLogFromJson(json);

  Map<String, dynamic> toJson() => _$DoseLogToJson(this);

  DoseLog copyWith({
    String? id,
    String? scheduleId,
    DateTime? takenTime,
    double? amountTaken,
    String? notes,
    String? reaction,
    List<int>? usedSupplies,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DoseLog(
      id: id ?? this.id,
      scheduleId: scheduleId ?? this.scheduleId,
      takenTime: takenTime ?? this.takenTime,
      amountTaken: amountTaken ?? this.amountTaken,
      notes: notes ?? this.notes,
      reaction: reaction ?? this.reaction,
      usedSupplies: usedSupplies ?? this.usedSupplies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
