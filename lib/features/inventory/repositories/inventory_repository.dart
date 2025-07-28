import '../models/inventory_item.dart';

/// Repository interface for inventory item data operations
abstract class InventoryRepository {
  // Basic CRUD operations
  Future<List<InventoryItem>> getAllItems();
  Future<InventoryItem?> getItemById(String id);
  Future<void> addItem(InventoryItem item);
  Future<void> updateItem(InventoryItem item);
  Future<void> deleteItem(String id);
  
  // Medication-specific queries
  Future<List<InventoryItem>> getItemsByMedicationId(String medicationId);
  Future<List<InventoryItem>> getAvailableItemsByMedicationId(String medicationId);
  
  // Status-based queries
  Future<List<InventoryItem>> getItemsByStatus(InventoryStatus status);
  Future<List<InventoryItem>> getExpiredItems();
  Future<List<InventoryItem>> getExpiringSoonItems();
  Future<List<InventoryItem>> getLowStockItems();
  Future<List<InventoryItem>> getOutOfStockItems();
  
  // Location-based queries
  Future<List<InventoryItem>> getItemsByStorageLocation(String location);
  Future<List<String>> getAllStorageLocations();
  
  // Supplier-based queries
  Future<List<InventoryItem>> getItemsBySupplier(String supplier);
  Future<List<String>> getAllSuppliers();
  
  // Batch/Lot queries
  Future<InventoryItem?> getItemByBatchNumber(String batchNumber);
  Future<List<InventoryItem>> getItemsByLotNumber(String lotNumber);
  
  // Date-based queries
  Future<List<InventoryItem>> getItemsExpiringBetween(DateTime start, DateTime end);
  Future<List<InventoryItem>> getItemsPurchasedBetween(DateTime start, DateTime end);
  
  // Value and cost queries
  Future<double> getTotalInventoryValue();
  Future<double> getTotalValueByMedicationId(String medicationId);
  Future<double> getTotalValueBySupplier(String supplier);
  
  // Quantity operations
  Future<void> updateItemQuantity(String id, double newQuantity, {String? reason});
  Future<void> consumeQuantity(String id, double quantity, {String? reason});
  Future<void> addQuantity(String id, double quantity, {String? reason});
  
  // Batch operations
  Future<void> updateMultipleItems(List<InventoryItem> items);
  Future<void> deleteMultipleItems(List<String> ids);
  Future<void> markItemsAsOpened(List<String> ids);
  
  // Search and filtering
  Future<List<InventoryItem>> searchItems(String query);
  Future<List<InventoryItem>> filterItems({
    String? medicationId,
    InventoryStatus? status,
    String? supplier,
    String? storageLocation,
    DateTime? expirationDateStart,
    DateTime? expirationDateEnd,
    double? minQuantity,
    double? maxQuantity,
    bool? isExpired,
    bool? isLowStock,
  });
  
  // Analytics and reporting
  Future<Map<InventoryStatus, int>> getItemCountsByStatus();
  Future<Map<String, int>> getItemCountsByMedication();
  Future<Map<String, double>> getValueByMedication();
  Future<List<InventoryItem>> getMostValuableItems(int limit);
  Future<List<InventoryItem>> getItemsNearingExpiration(int days);
  
  // Maintenance operations
  Future<void> updateAllItemStatuses();
  Future<void> cleanupExpiredItems();
  Future<List<InventoryItem>> getOrphanedItems(); // Items with invalid medication IDs
  
  // Import/Export
  Future<List<Map<String, dynamic>>> exportAllItems();
  Future<void> importItems(List<Map<String, dynamic>> itemsData);
  
  // Utility methods
  Future<bool> itemExists(String id);
  Future<int> getItemCount();
  Future<DateTime?> getLastUpdatedTime();
}
