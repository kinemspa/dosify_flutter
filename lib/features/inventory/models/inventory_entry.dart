import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../../core/data/models/medication.dart';

part 'inventory_entry.g.dart';

@HiveType(typeId: 9)
@JsonSerializable()
class InventoryEntry extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String medicationId;

  @HiveField(2)
  final int currentQuantity;

  @HiveField(3)
  final int minimumQuantity;

  @HiveField(4)
  final int reorderPoint;

  @HiveField(5)
  final DateTime? expirationDate;

  @HiveField(6)
  final String? batchNumber;

  @HiveField(7)
  final DateTime purchaseDate;

  @HiveField(8)
  final double purchasePrice;

  @HiveField(9)
  final String? supplier;

  @HiveField(10)
  final String? storageLocation;

  @HiveField(11)
  final Map<String, dynamic> customFields;

  @HiveField(12)
  final DateTime createdAt;

  @HiveField(13)
  final DateTime updatedAt;

  const InventoryEntry({
    required this.id,
    required this.medicationId,
    required this.currentQuantity,
    required this.minimumQuantity,
    required this.reorderPoint,
    this.expirationDate,
    this.batchNumber,
    required this.purchaseDate,
    required this.purchasePrice,
    this.supplier,
    this.storageLocation,
    Map<String, dynamic>? customFields,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : customFields = customFields ?? const {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory InventoryEntry.fromJson(Map<String, dynamic> json) =>
      _$InventoryEntryFromJson(json);

  Map<String, dynamic> toJson() => _$InventoryEntryToJson(this);

  InventoryEntry copyWith({
    String? id,
    String? medicationId,
    int? currentQuantity,
    int? minimumQuantity,
    int? reorderPoint,
    DateTime? expirationDate,
    String? batchNumber,
    DateTime? purchaseDate,
    double? purchasePrice,
    String? supplier,
    String? storageLocation,
    Map<String, dynamic>? customFields,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryEntry(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      currentQuantity: currentQuantity ?? this.currentQuantity,
      minimumQuantity: minimumQuantity ?? this.minimumQuantity,
      reorderPoint: reorderPoint ?? this.reorderPoint,
      expirationDate: expirationDate ?? this.expirationDate,
      batchNumber: batchNumber ?? this.batchNumber,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      supplier: supplier ?? this.supplier,
      storageLocation: storageLocation ?? this.storageLocation,
      customFields: customFields ?? this.customFields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isLowStock => currentQuantity <= minimumQuantity;
  bool get needsReorder => currentQuantity <= reorderPoint;
  bool get isExpired =>
      expirationDate != null && expirationDate!.isBefore(DateTime.now());
  bool get isExpiringSoon =>
      expirationDate != null &&
      expirationDate!.isBefore(
        DateTime.now().add(const Duration(days: 30)),
      );

  Duration? get timeUntilExpiration =>
      expirationDate?.difference(DateTime.now());
}
