import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'reconstitution.g.dart';

@HiveType(typeId: 7)
@JsonSerializable()
class Reconstitution extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String medId;

  @HiveField(2)
  final double powderAmount;

  @HiveField(3)
  final double solventVolume;

  @HiveField(4)
  final double? desiredConcentration;

  @HiveField(5)
  final double? calculatedVolumePerDose;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  Reconstitution({
    required this.id,
    required this.medId,
    required this.powderAmount,
    required this.solventVolume,
    this.desiredConcentration,
    this.calculatedVolumePerDose,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Reconstitution.fromJson(Map<String, dynamic> json) =>
      _$ReconstitutionFromJson(json);

  Map<String, dynamic> toJson() => _$ReconstitutionToJson(this);

  Reconstitution copyWith({
    String? id,
    String? medId,
    double? powderAmount,
    double? solventVolume,
    double? desiredConcentration,
    double? calculatedVolumePerDose,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Reconstitution(
      id: id ?? this.id,
      medId: medId ?? this.medId,
      powderAmount: powderAmount ?? this.powderAmount,
      solventVolume: solventVolume ?? this.solventVolume,
      desiredConcentration: desiredConcentration ?? this.desiredConcentration,
      calculatedVolumePerDose: calculatedVolumePerDose ?? this.calculatedVolumePerDose,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@HiveType(typeId: 10)
@JsonSerializable()
class Profile extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name; // IAP feature for multi-personas

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final DateTime updatedAt;

  Profile({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  Profile copyWith({
    String? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
