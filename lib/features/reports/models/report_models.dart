import '../../../core/data/models/medication.dart';
import '../../../features/inventory/models/inventory_entry.dart';
import '../../../features/inventory/models/inventory_transaction.dart';
import '../../../features/scheduling/models/medication_schedule.dart';

class MedicationReport {
  final Medication medication;
  final List<InventoryEntry> inventoryEntries;
  final List<InventoryTransaction> transactions;
  final List<MedicationSchedule> schedules;
  final DateTime startDate;
  final DateTime endDate;

  const MedicationReport({
    required this.medication,
    required this.inventoryEntries,
    required this.transactions,
    required this.schedules,
    required this.startDate,
    required this.endDate,
  });

  double get totalPurchaseCost {
    return transactions
        .where((t) => t.type == TransactionType.purchase)
        .fold(0.0, (sum, t) => sum + (t.metadata['price'] ?? 0.0));
  }

  int get totalConsumption {
    return transactions
        .where((t) => t.type == TransactionType.consumption)
        .fold(0, (sum, t) => sum + t.quantity);
  }

  int get totalDisposal {
    return transactions
        .where((t) => t.type == TransactionType.disposal)
        .fold(0, (sum, t) => sum + t.quantity);
  }

  int get currentStock {
    return inventoryEntries.fold(0, (sum, e) => sum + e.currentQuantity);
  }

  bool get hasLowStock {
    return inventoryEntries.any((e) => e.isLowStock);
  }

  bool get needsReorder {
    return inventoryEntries.any((e) => e.needsReorder);
  }

  bool get hasExpiringSoon {
    return inventoryEntries.any((e) => e.isExpiringSoon);
  }
}

class InventoryReport {
  final List<InventoryEntry> entries;
  final List<InventoryTransaction> transactions;
  final DateTime startDate;
  final DateTime endDate;

  const InventoryReport({
    required this.entries,
    required this.transactions,
    required this.startDate,
    required this.endDate,
  });

  double get totalValue {
    return entries.fold(
      0.0,
      (sum, e) => sum + (e.currentQuantity * e.purchasePrice),
    );
  }

  int get totalItems => entries.length;
  int get lowStockItems => entries.where((e) => e.isLowStock).length;
  int get reorderItems => entries.where((e) => e.needsReorder).length;
  int get expiringSoonItems => entries.where((e) => e.isExpiringSoon).length;
  int get expiredItems => entries.where((e) => e.isExpired).length;

  List<InventoryEntry> get lowStockEntries =>
      entries.where((e) => e.isLowStock).toList();
  List<InventoryEntry> get reorderEntries =>
      entries.where((e) => e.needsReorder).toList();
  List<InventoryEntry> get expiringSoonEntries =>
      entries.where((e) => e.isExpiringSoon).toList();
  List<InventoryEntry> get expiredEntries =>
      entries.where((e) => e.isExpired).toList();

  double get totalPurchaseCost {
    return transactions
        .where((t) => t.type == TransactionType.purchase)
        .fold(0.0, (sum, t) => sum + (t.metadata['price'] ?? 0.0));
  }

  int get totalConsumption {
    return transactions
        .where((t) => t.type == TransactionType.consumption)
        .fold(0, (sum, t) => sum + t.quantity);
  }

  int get totalDisposal {
    return transactions
        .where((t) => t.type == TransactionType.disposal)
        .fold(0, (sum, t) => sum + t.quantity);
  }
}

class AdherenceReport {
  final List<MedicationSchedule> schedules;
  final List<InventoryTransaction> transactions;
  final DateTime startDate;
  final DateTime endDate;

  const AdherenceReport({
    required this.schedules,
    required this.transactions,
    required this.startDate,
    required this.endDate,
  });

  Map<String, double> get adherenceRates {
    final Map<String, double> rates = {};
    for (final schedule in schedules) {
      final expectedDoses = schedule
          .getNextScheduledDoses(startDate, 1000)
          .where((dose) => dose.isBefore(endDate))
          .length;

      final actualDoses = transactions
          .where((t) =>
              t.medicationId == schedule.medicationId &&
              t.type == TransactionType.consumption &&
              t.timestamp.isAfter(startDate) &&
              t.timestamp.isBefore(endDate))
          .length;

      if (expectedDoses > 0) {
        rates[schedule.medicationId] = actualDoses / expectedDoses;
      }
    }
    return rates;
  }

  double get overallAdherenceRate {
    if (adherenceRates.isEmpty) return 0.0;
    final sum = adherenceRates.values.reduce((a, b) => a + b);
    return sum / adherenceRates.length;
  }

  List<MedicationSchedule> get missedDoseSchedules {
    return schedules
        .where((schedule) => (adherenceRates[schedule.medicationId] ?? 0) < 0.8)
        .toList();
  }
}
