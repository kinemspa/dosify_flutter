import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/report_providers.dart';

class InventoryReportScreen extends ConsumerWidget {
  final DateTime startDate;
  final DateTime endDate;

  const InventoryReportScreen({
    Key? key,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryReport = ref.watch(
      inventoryReportProvider({'startDate': startDate, 'endDate': endDate}),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Report')),
      body: inventoryReport.when(
        data: (report) => _buildReportView(context, report),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildReportView(BuildContext context, InventoryReport report) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard('Total Value', _formatCurrency(report.totalValue)),
        _buildStatCard('Total Items', report.totalItems.toString()),
        _buildStatCard('Low Stock Items', report.lowStockItems.toString()),
        _buildStatCard('Needs Reorder Items', report.reorderItems.toString()),
        _buildStatCard('Expiring Soon Items', report.expiringSoonItems.toString()),
        _buildStatCard('Expired Items', report.expiredItems.toString()),
        const SizedBox(height: 30),
        _buildSectionTitle('Low Stock Entries'),
        ...report.lowStockEntries.map((e) => _buildInventoryEntryTile(e)),
        const SizedBox(height: 30),
        _buildSectionTitle('Expiring Soon Entries'),
        ...report.expiringSoonEntries.map((e) => _buildInventoryEntryTile(e)),
      ],
    );
  }

  Card _buildStatCard(String title, String value) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInventoryEntryTile(InventoryEntry entry) {
    return ListTile(
      contentPadding: const EdgeInsets.all(8.0),
      leading: CircleAvatar(
        child: Text(entry.medicationId[0]),
      ),
      title: Text(entry.medicationId),
      subtitle: Text('Quantity: ${entry.currentQuantity}'),
      trailing: entry.isLowStock
          ? const Icon(Icons.warning, color: Colors.red)
          : const Icon(Icons.check_circle, color: Colors.green),
    );
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat.simpleCurrency();
    return format.format(amount);
  }
}
