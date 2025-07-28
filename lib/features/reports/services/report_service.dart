import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/models/medication.dart';
import '../../../features/inventory/models/inventory_entry.dart';
import '../../../features/inventory/models/inventory_transaction.dart';
import '../../../features/scheduling/models/medication_schedule.dart';
import '../models/report_models.dart';

class ReportService {
  final List<Medication> medications;
  final List<InventoryEntry> inventoryEntries;
  final List<InventoryTransaction> transactions;
  final List<MedicationSchedule> schedules;

  ReportService({
    required this.medications,
    required this.inventoryEntries,
    required this.transactions,
    required this.schedules,
  });

  MedicationReport generateMedicationReport(
    String medicationId,
    DateTime startDate,
    DateTime endDate,
  ) {
    final medication = medications.firstWhere((m) => m.id == medicationId);
    final entries = inventoryEntries.where((e) => e.medicationId == medicationId).toList();
    final txns = transactions
        .where((t) =>
            t.medicationId == medicationId &&
            t.timestamp.isAfter(startDate) &&
            t.timestamp.isBefore(endDate))
        .toList();
    final meds = schedules.where((s) => s.medicationId == medicationId).toList();

    return MedicationReport(
      medication: medication,
      inventoryEntries: entries,
      transactions: txns,
      schedules: meds,
      startDate: startDate,
      endDate: endDate,
    );
  }

  InventoryReport generateInventoryReport(
    DateTime startDate,
    DateTime endDate,
  ) {
    final txns = transactions
        .where((t) =>
            t.timestamp.isAfter(startDate) && t.timestamp.isBefore(endDate))
        .toList();

    return InventoryReport(
      entries: inventoryEntries,
      transactions: txns,
      startDate: startDate,
      endDate: endDate,
    );
  }

  AdherenceReport generateAdherenceReport(
    DateTime startDate,
    DateTime endDate, {
    String? medicationId,
  }) {
    final filteredSchedules = medicationId != null
        ? schedules.where((s) => s.medicationId == medicationId).toList()
        : schedules;

    final txns = transactions
        .where((t) =>
            t.type == TransactionType.consumption &&
            t.timestamp.isAfter(startDate) &&
            t.timestamp.isBefore(endDate) &&
            (medicationId == null || t.medicationId == medicationId))
        .toList();

    return AdherenceReport(
      schedules: filteredSchedules,
      transactions: txns,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<String> exportToCSV(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final buffer = StringBuffer();
    
    // Write headers
    buffer.writeln(
      'Date,Medication,Transaction Type,Quantity,Stock Level,Notes',
    );

    // Get all transactions in the date range
    final txns = transactions
        .where((t) =>
            t.timestamp.isAfter(startDate) && t.timestamp.isBefore(endDate))
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // Write transaction data
    for (final txn in txns) {
      final medication =
          medications.firstWhere((m) => m.id == txn.medicationId);
      final entry = inventoryEntries
          .firstWhere((e) => e.id == txn.inventoryEntryId);

      buffer.writeln(
        '${_formatDate(txn.timestamp)},'
        '"${medication.name}",'
        '${txn.type.toString().split('.').last},'
        '${_formatQuantity(txn)},'
        '${entry.currentQuantity},'
        '"${txn.note ?? ''}"',
      );
    }

    return buffer.toString();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatQuantity(InventoryTransaction txn) {
    switch (txn.type) {
      case TransactionType.purchase:
        return '+${txn.quantity}';
      case TransactionType.consumption:
      case TransactionType.disposal:
        return '-${txn.quantity}';
      case TransactionType.adjustment:
        return '=${txn.quantity}';
      case TransactionType.transfer:
        return '±${txn.quantity}';
    }
  }
}
