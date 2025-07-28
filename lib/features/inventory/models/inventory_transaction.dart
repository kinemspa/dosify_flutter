import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'inventory_transaction.g.dart';

@HiveType(typeId: 10)
enum TransactionType {
  @HiveField(0)
  purchase,
  @HiveField(1)
  consumption,
  @HiveField(2)
  disposal,
  @HiveField(3)
  adjustment,
  @HiveField(4)
  transfer
}

@HiveType(typeId: 11)
@JsonSerializable()
class InventoryTransaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String inventoryEntryId;

  @HiveField(2)
  final String medicationId;

  @HiveField(3)
  final TransactionType type;

  @HiveField(4)
  final int quantity;

  @HiveField(5)
  final DateTime timestamp;

  @HiveField(6)
  final String? note;

  @HiveField(7)
  final String? userId;

  @HiveField(8)
  final Map<String, dynamic> metadata;

  const InventoryTransaction({
    required this.id,
    required this.inventoryEntryId,
    required this.medicationId,
    required this.type,
    required this.quantity,
    required this.timestamp,
    this.note,
    this.userId,
    Map<String, dynamic>? metadata,
  }) : metadata = metadata ?? const {};

  factory InventoryTransaction.fromJson(Map<String, dynamic> json) =>
      _$InventoryTransactionFromJson(json);

  Map<String, dynamic> toJson() => _$InventoryTransactionToJson(this);

  InventoryTransaction copyWith({
    String? id,
    String? inventoryEntryId,
    String? medicationId,
    TransactionType? type,
    int? quantity,
    DateTime? timestamp,
    String? note,
    String? userId,
    Map<String, dynamic>? metadata,
  }) {
    return InventoryTransaction(
      id: id ?? this.id,
      inventoryEntryId: inventoryEntryId ?? this.inventoryEntryId,
      medicationId: medicationId ?? this.medicationId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      userId: userId ?? this.userId,
      metadata: metadata ?? this.metadata,
    );
  }
}
