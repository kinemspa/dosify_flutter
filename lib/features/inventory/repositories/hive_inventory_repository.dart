import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/services/hive_service.dart';
import '../models/inventory_entry.dart';
import '../models/inventory_transaction.dart';
import 'inventory_repository.dart';

class HiveInventoryRepository implements InventoryRepository {
  final HiveService _hiveService;
  late Box<InventoryEntry> _entriesBox;
  late Box<InventoryTransaction> _transactionsBox;

  HiveInventoryRepository(this._hiveService) {
    _entriesBox = _hiveService.box<InventoryEntry>('inventory_entries');
    _transactionsBox = _hiveService.box<InventoryTransaction>('inventory_transactions');
  }

  @override
  Stream<List<InventoryEntry>> watchInventory() {
    return _entriesBox.watch().map((_) => getAllEntries());
  }

  @override
  List<InventoryEntry> getAllEntries() {
    return _entriesBox.values.toList();
  }

  @override
  Future<InventoryEntry?> getEntry(String id) async {
    return _entriesBox.get(id);
  }

  @override
  Future<List<InventoryEntry>> getEntriesForMedication(String medicationId) async {
    return _entriesBox.values
        .where((entry) => entry.medicationId == medicationId)
        .toList();
  }

  @override
  Future<void> addEntry(InventoryEntry entry) async {
    await _entriesBox.put(entry.id, entry);
  }

  @override
  Future<void> updateEntry(InventoryEntry entry) async {
    await _entriesBox.put(entry.id, entry);
  }

  @override
  Future<void> deleteEntry(String id) async {
    await _entriesBox.delete(id);
    // Delete associated transactions
    final transactions = await getTransactionsForEntry(id);
    for (final transaction in transactions) {
      await _transactionsBox.delete(transaction.id);
    }
  }

  @override
  Future<void> recordTransaction(InventoryTransaction transaction) async {
    await _transactionsBox.put(transaction.id, transaction);

    final entry = await getEntry(transaction.inventoryEntryId);
    if (entry != null) {
      int newQuantity = entry.currentQuantity;
      switch (transaction.type) {
        case TransactionType.purchase:
          newQuantity += transaction.quantity;
          break;
        case TransactionType.consumption:
        case TransactionType.disposal:
          newQuantity -= transaction.quantity;
          break;
        case TransactionType.adjustment:
          newQuantity = transaction.quantity; // Direct set
          break;
        case TransactionType.transfer:
          // Handle transfer separately if needed
          break;
      }

      await updateEntry(entry.copyWith(
        currentQuantity: newQuantity,
        updatedAt: DateTime.now(),
      ));
    }
  }

  @override
  Future<List<InventoryTransaction>> getTransactionsForEntry(String entryId) async {
    return _transactionsBox.values
        .where((transaction) => transaction.inventoryEntryId == entryId)
        .toList();
  }

  @override
  Future<List<InventoryTransaction>> getTransactionsForMedication(String medicationId) async {
    return _transactionsBox.values
        .where((transaction) => transaction.medicationId == medicationId)
        .toList();
  }

  @override
  Stream<List<InventoryTransaction>> watchTransactions() {
    return _transactionsBox.watch().map((_) => _transactionsBox.values.toList());
  }

  @override
  Future<List<InventoryEntry>> getLowStockEntries() async {
    return _entriesBox.values
        .where((entry) => entry.isLowStock)
        .toList();
  }

  @override
  Future<List<InventoryEntry>> getExpiringEntries({Duration threshold = const Duration(days: 30)}) async {
    final now = DateTime.now();
    return _entriesBox.values
        .where((entry) =>
            entry.expirationDate != null &&
            entry.expirationDate!.difference(now) <= threshold)
        .toList();
  }

  @override
  Future<void> adjustQuantity(String entryId, int newQuantity, String? note, String? userId) async {
    final entry = await getEntry(entryId);
    if (entry != null) {
      final transaction = InventoryTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        inventoryEntryId: entryId,
        medicationId: entry.medicationId,
        type: TransactionType.adjustment,
        quantity: newQuantity,
        timestamp: DateTime.now(),
        note: note,
        userId: userId,
      );
      await recordTransaction(transaction);
    }
  }

  @override
  Future<void> recordConsumption(String entryId, int quantity, String? note, String? userId) async {
    final entry = await getEntry(entryId);
    if (entry != null) {
      final transaction = InventoryTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        inventoryEntryId: entryId,
        medicationId: entry.medicationId,
        type: TransactionType.consumption,
        quantity: quantity,
        timestamp: DateTime.now(),
        note: note,
        userId: userId,
      );
      await recordTransaction(transaction);
    }
  }

  @override
  Future<void> recordDisposal(String entryId, int quantity, String? reason, String? userId) async {
    final entry = await getEntry(entryId);
    if (entry != null) {
      final transaction = InventoryTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        inventoryEntryId: entryId,
        medicationId: entry.medicationId,
        type: TransactionType.disposal,
        quantity: quantity,
        timestamp: DateTime.now(),
        note: reason,
        userId: userId,
      );
      await recordTransaction(transaction);
    }
  }
}
