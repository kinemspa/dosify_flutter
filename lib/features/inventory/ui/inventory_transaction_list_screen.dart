import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/inventory_transaction.dart';
import '../providers/inventory_providers.dart';

class InventoryTransactionListScreen extends ConsumerWidget {
  final String? inventoryEntryId;
  final String? medicationId;

  const InventoryTransactionListScreen({
    this.inventoryEntryId,
    this.medicationId,
    super.key,
  }) : assert(inventoryEntryId != null || medicationId != null);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(inventoryTransactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: transactions.when(
        data: (allTransactions) {
          final filteredTransactions = allTransactions.where((t) {
            if (inventoryEntryId != null) {
              return t.inventoryEntryId == inventoryEntryId;
            }
            return t.medicationId == medicationId;
          }).toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (filteredTransactions.isEmpty) {
            return const Center(
              child: Text('No transactions found.'),
            );
          }

          return ListView.builder(
            itemCount: filteredTransactions.length,
            itemBuilder: (context, index) {
              final transaction = filteredTransactions[index];
              return TransactionListItem(transaction: transaction);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class TransactionListItem extends StatelessWidget {
  final InventoryTransaction transaction;

  const TransactionListItem({
    required this.transaction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTransactionColor(transaction.type),
          child: Icon(
            _getTransactionIcon(transaction.type),
            color: Colors.white,
          ),
        ),
        title: Text(_getTransactionTitle(transaction)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quantity: ${_formatQuantity(transaction)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              _formatDateTime(transaction.timestamp),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (transaction.note != null)
              Text(
                'Note: ${transaction.note}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Color _getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.purchase:
        return Colors.green;
      case TransactionType.consumption:
        return Colors.blue;
      case TransactionType.disposal:
        return Colors.red;
      case TransactionType.adjustment:
        return Colors.orange;
      case TransactionType.transfer:
        return Colors.purple;
    }
  }

  IconData _getTransactionIcon(TransactionType type) {
    switch (type) {
      case TransactionType.purchase:
        return Icons.add_shopping_cart;
      case TransactionType.consumption:
        return Icons.remove_circle_outline;
      case TransactionType.disposal:
        return Icons.delete_outline;
      case TransactionType.adjustment:
        return Icons.edit;
      case TransactionType.transfer:
        return Icons.swap_horiz;
    }
  }

  String _getTransactionTitle(InventoryTransaction transaction) {
    switch (transaction.type) {
      case TransactionType.purchase:
        return 'Purchase';
      case TransactionType.consumption:
        return 'Consumption';
      case TransactionType.disposal:
        return 'Disposal';
      case TransactionType.adjustment:
        return 'Adjustment';
      case TransactionType.transfer:
        return 'Transfer';
    }
  }

  String _formatQuantity(InventoryTransaction transaction) {
    switch (transaction.type) {
      case TransactionType.purchase:
        return '+${transaction.quantity}';
      case TransactionType.consumption:
      case TransactionType.disposal:
        return '-${transaction.quantity}';
      case TransactionType.adjustment:
        return '=${transaction.quantity}';
      case TransactionType.transfer:
        return '±${transaction.quantity}';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
