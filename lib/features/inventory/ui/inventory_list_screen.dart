import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/widgets/rounded_card.dart';
import '../models/inventory_entry.dart';
import '../providers/inventory_providers.dart';

class InventoryListScreen extends ConsumerWidget {
  const InventoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventoryEntries = ref.watch(inventoryEntriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Inventory List')),
      body: inventoryEntries.when(
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(child: Text('No inventory items found.'));
          }
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return InventoryListItem(entry: entry);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to inventory entry form
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class InventoryListItem extends StatelessWidget {
  final InventoryEntry entry;

  const InventoryListItem({required this.entry, super.key});

  @override
  Widget build(BuildContext context) {
    return RoundedCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(entry.medicationId[0].toUpperCase()),
        ),
        title: Text(entry.medicationId),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quantity: ${entry.currentQuantity}'),
            if (entry.isLowStock)
              const Text(
                'Low Stock!',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
          ],
        ),
        trailing: Icon(
          entry.isExpiringSoon ? Icons.warning : Icons.check_circle,
          color: entry.isExpiringSoon ? Colors.red : Colors.green,
        ),
        onTap: () {
          // TODO: Navigate to inventory detail screen
        },
      ),
    );
  }
}
