import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'supply.g.dart';

@HiveType(typeId: 6)
@JsonSerializable()
class Supply extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String unit;

  @HiveField(3)
  final double stock;

  @HiveField(4)
  final double lowStockThreshold;

  @HiveField(5)
  final String? linkedMedId;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  Supply({
    required this.id,
    required this.name,
    required this.unit,
    required this.stock,
    required this.lowStockThreshold,
    this.linkedMedId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Supply.fromJson(Map<String, dynamic> json) =>
      _$SupplyFromJson(json);

  Map<String, dynamic> toJson() => _$SupplyToJson(this);

  Supply copyWith({
    String? id,
    String? name,
    String? unit,
    double? stock,
    double? lowStockThreshold,
    String? linkedMedId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Supply(
      id: id ?? this.id,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      linkedMedId: linkedMedId ?? this.linkedMedId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
