import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'inventory_item.g.dart';

@HiveType(typeId: 10)
class InventoryItem extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String medicationId;

  @HiveField(2)
  late String batchNumber;

  @HiveField(3)
  late DateTime expirationDate;

  @HiveField(4)
  late double quantity;

  @HiveField(5)
  late String unit;

  @HiveField(6)
  late double costPerUnit;

  @HiveField(7)
  late String supplier;

  @HiveField(8)
  late DateTime purchaseDate;

  @HiveField(9)
  late String storageLocation;

  @HiveField(10)
  late InventoryStatus status;

  @HiveField(11)
  late double alertThreshold;

  @HiveField(12)
  late DateTime createdAt;

  @HiveField(13)
  late DateTime updatedAt;

  @HiveField(14)
  String? notes;

  @HiveField(15)
  late double originalQuantity;

  @HiveField(16)
  String? lotNumber;

  @HiveField(17)
  String? manufacturerName;

  @HiveField(18)
  DateTime? openedDate;

  @HiveField(19)
  int? shelfLifeAfterOpening; // days

  InventoryItem({
    String? id,
    required this.medicationId,
    required this.batchNumber,
    required this.expirationDate,
    required this.quantity,
    required this.unit,
    required this.costPerUnit,
    required this.supplier,
    required this.purchaseDate,
    required this.storageLocation,
    this.status = InventoryStatus.available,
    required this.alertThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.notes,
    double? originalQuantity,
    this.lotNumber,
    this.manufacturerName,
    this.openedDate,
    this.shelfLifeAfterOpening,
  }) {
    this.id = id ?? const Uuid().v4();
    this.originalQuantity = originalQuantity ?? quantity;
    this.createdAt = createdAt ?? DateTime.now();
    this.updatedAt = updatedAt ?? DateTime.now();
  }

  // Business logic methods
  bool get isExpired => DateTime.now().isAfter(expirationDate);
  
  bool get isExpiringSoon {
    final now = DateTime.now();
    final daysUntilExpiry = expirationDate.difference(now).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry >= 0;
  }

  bool get isLowStock => quantity <= alertThreshold;

  bool get isOutOfStock => quantity <= 0;

  bool get isOpened => openedDate != null;

  bool get isExpiredAfterOpening {
    if (openedDate == null || shelfLifeAfterOpening == null) return false;
    final expiryAfterOpening = openedDate!.add(Duration(days: shelfLifeAfterOpening!));
    return DateTime.now().isAfter(expiryAfterOpening);
  }

  DateTime? get effectiveExpirationDate {
    if (openedDate != null && shelfLifeAfterOpening != null) {
      final expiryAfterOpening = openedDate!.add(Duration(days: shelfLifeAfterOpening!));
      return expirationDate.isBefore(expiryAfterOpening) ? expirationDate : expiryAfterOpening;
    }
    return expirationDate;
  }

  double get usedQuantity => originalQuantity - quantity;

  double get usagePercentage => (usedQuantity / originalQuantity) * 100;

  double get totalValue => quantity * costPerUnit;

  int get daysUntilExpiry => effectiveExpirationDate!.difference(DateTime.now()).inDays;

  void updateQuantity(double newQuantity, {String? reason}) {
    quantity = newQuantity;
    updatedAt = DateTime.now();
    
    if (newQuantity <= 0) {
      status = InventoryStatus.depleted;
    } else if (newQuantity <= alertThreshold) {
      status = InventoryStatus.lowStock;
    } else if (isExpired || isExpiredAfterOpening) {
      status = InventoryStatus.expired;
    } else {
      status = InventoryStatus.available;
    }
  }

  void markAsOpened() {
    openedDate = DateTime.now();
    updatedAt = DateTime.now();
  }

  void updateStatus() {
    if (quantity <= 0) {
      status = InventoryStatus.depleted;
    } else if (isExpired || isExpiredAfterOpening) {
      status = InventoryStatus.expired;
    } else if (isLowStock) {
      status = InventoryStatus.lowStock;
    } else {
      status = InventoryStatus.available;
    }
    updatedAt = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'medicationId': medicationId,
    'batchNumber': batchNumber,
    'expirationDate': expirationDate.toIso8601String(),
    'quantity': quantity,
    'unit': unit,
    'costPerUnit': costPerUnit,
    'supplier': supplier,
    'purchaseDate': purchaseDate.toIso8601String(),
    'storageLocation': storageLocation,
    'status': status.name,
    'alertThreshold': alertThreshold,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'notes': notes,
    'originalQuantity': originalQuantity,
    'lotNumber': lotNumber,
    'manufacturerName': manufacturerName,
    'openedDate': openedDate?.toIso8601String(),
    'shelfLifeAfterOpening': shelfLifeAfterOpening,
  };

  factory InventoryItem.fromJson(Map<String, dynamic> json) => InventoryItem(
    id: json['id'],
    medicationId: json['medicationId'],
    batchNumber: json['batchNumber'],
    expirationDate: DateTime.parse(json['expirationDate']),
    quantity: json['quantity'].toDouble(),
    unit: json['unit'],
    costPerUnit: json['costPerUnit'].toDouble(),
    supplier: json['supplier'],
    purchaseDate: DateTime.parse(json['purchaseDate']),
    storageLocation: json['storageLocation'],
    status: InventoryStatus.values.byName(json['status']),
    alertThreshold: json['alertThreshold'].toDouble(),
    createdAt: DateTime.parse(json['createdAt']),
    updatedAt: DateTime.parse(json['updatedAt']),
    notes: json['notes'],
    originalQuantity: json['originalQuantity']?.toDouble(),
    lotNumber: json['lotNumber'],
    manufacturerName: json['manufacturerName'],
    openedDate: json['openedDate'] != null ? DateTime.parse(json['openedDate']) : null,
    shelfLifeAfterOpening: json['shelfLifeAfterOpening'],
  );

  @override
  String toString() => 'InventoryItem(id: $id, medicationId: $medicationId, quantity: $quantity $unit, status: $status)';
}

@HiveType(typeId: 11)
enum InventoryStatus {
  @HiveField(0)
  available,
  
  @HiveField(1)
  lowStock,
  
  @HiveField(2)
  expired,
  
  @HiveField(3)
  depleted,
  
  @HiveField(4)
  reserved,
  
  @HiveField(5)
  quarantined,
}
