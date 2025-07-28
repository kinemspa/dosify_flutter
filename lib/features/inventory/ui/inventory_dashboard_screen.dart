import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/auth_provider.dart';
import '../models/inventory_entry.dart';
import '../providers/inventory_providers.dart';

class InventoryDashboardScreen extends ConsumerWidget {
  const InventoryDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(inventoryStatsProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory Dashboard')),
      body: stats.when(
        data: (stats) =>
            _buildDashboard(context, ref, stats, user != null && user.photoUrl != null),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to inventory entry form or picker
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    WidgetRef ref,
    InventoryStats stats,
    bool hasUserPhoto,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (hasUserPhoto)
            Align(
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(ref.read(currentUserProvider)!.photoUrl!),
              ),
            ),
          const SizedBox(height: 24),
          _buildStatCard('Total Items', stats.totalItems),
          const SizedBox(height: 8),
          _buildStatCard('Low Stock', stats.lowStockCount),
          const SizedBox(height: 8),
          _buildStatCard('Needs Reorder', stats.reorderCount),
          const SizedBox(height: 8),
          _buildStatCard('Expiring Soon', stats.expiringCount),
          const SizedBox(height: 8),
          _buildStatCard('Expired', stats.expiredCount),
        ],
      ),
    );
  }

  Card _buildStatCard(String title, int count) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                '$count',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
