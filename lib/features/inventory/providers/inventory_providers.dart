import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/hive_provider.dart';
import '../models/inventory_entry.dart';
import '../models/inventory_transaction.dart';
import '../repositories/hive_inventory_repository.dart';
import '../repositories/inventory_repository.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return HiveInventoryRepository(hiveService);
});

final inventoryEntriesProvider = StreamProvider<List<InventoryEntry>>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.watchInventory();
});

final inventoryTransactionsProvider = StreamProvider<List<InventoryTransaction>>((ref) {
  final repository = ref.watch(inventoryRepositoryProvider);
  return repository.watchTransactions();
});

final medicationInventoryProvider = StreamProvider.family<List<InventoryEntry>, String>((ref, medicationId) {
  final entries = ref.watch(inventoryEntriesProvider);
  return entries.when(
    data: (entries) => Stream.value(
      entries.where((entry) => entry.medicationId == medicationId).toList(),
    ),
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

final lowStockEntriesProvider = Provider<AsyncValue<List<InventoryEntry>>>((ref) {
  final entries = ref.watch(inventoryEntriesProvider);
  return entries.whenData(
    (entries) => entries.where((entry) => entry.isLowStock).toList(),
  );
});

final expiringEntriesProvider = Provider<AsyncValue<List<InventoryEntry>>>((ref) {
  final entries = ref.watch(inventoryEntriesProvider);
  return entries.whenData(
    (entries) => entries.where((entry) => entry.isExpiringSoon).toList(),
  );
});

final inventoryStatsProvider = Provider<AsyncValue<InventoryStats>>((ref) {
  final entries = ref.watch(inventoryEntriesProvider);
  return entries.whenData((entries) {
    final lowStock = entries.where((entry) => entry.isLowStock).length;
    final needsReorder = entries.where((entry) => entry.needsReorder).length;
    final expiring = entries.where((entry) => entry.isExpiringSoon).length;
    final expired = entries.where((entry) => entry.isExpired).length;
    
    return InventoryStats(
      totalItems: entries.length,
      lowStockCount: lowStock,
      reorderCount: needsReorder,
      expiringCount: expiring,
      expiredCount: expired,
    );
  });
});

final inventoryActionsProvider = Provider<InventoryActions>((ref) {
  return InventoryActions(ref);
});

class InventoryStats {
  final int totalItems;
  final int lowStockCount;
  final int reorderCount;
  final int expiringCount;
  final int expiredCount;

  const InventoryStats({
    required this.totalItems,
    required this.lowStockCount,
    required this.reorderCount,
    required this.expiringCount,
    required this.expiredCount,
  });
}

class InventoryActions {
  final Ref _ref;

  InventoryActions(this._ref);

  Future<void> addEntry(InventoryEntry entry) async {
    final repository = _ref.read(inventoryRepositoryProvider);
    await repository.addEntry(entry);
  }

  Future<void> updateEntry(InventoryEntry entry) async {
    final repository = _ref.read(inventoryRepositoryProvider);
    await repository.updateEntry(entry);
  }

  Future<void> deleteEntry(String id) async {
    final repository = _ref.read(inventoryRepositoryProvider);
    await repository.deleteEntry(id);
  }

  Future<void> adjustQuantity(String entryId, int newQuantity, {String? note}) async {
    final repository = _ref.read(inventoryRepositoryProvider);
    final userId = _ref.read(currentUserProvider)?.id;
    await repository.adjustQuantity(entryId, newQuantity, note, userId);
  }

  Future<void> recordConsumption(String entryId, int quantity, {String? note}) async {
    final repository = _ref.read(inventoryRepositoryProvider);
    final userId = _ref.read(currentUserProvider)?.id;
    await repository.recordConsumption(entryId, quantity, note, userId);
  }

  Future<void> recordDisposal(String entryId, int quantity, {String? reason}) async {
    final repository = _ref.read(inventoryRepositoryProvider);
    final userId = _ref.read(currentUserProvider)?.id;
    await repository.recordDisposal(entryId, quantity, reason, userId);
  }
}
