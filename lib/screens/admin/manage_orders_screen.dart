import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_provider.dart';
import '../../models/order_model.dart';

class ManageOrdersScreen extends ConsumerStatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  ConsumerState<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends ConsumerState<ManageOrdersScreen> {
  String _filterStatus = 'all';
  String _sortBy = 'newest';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminProvider.notifier).getAllOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    List<OrderModel> filteredOrders = adminState.orders;

    // Filter
    if (_filterStatus != 'all') {
      filteredOrders = filteredOrders
          .where((order) => order.status == _filterStatus)
          .toList();
    }

    // Sort by ID as proxy for creation order
    if (_sortBy == 'newest') {
      filteredOrders.sort((a, b) => b.id.compareTo(a.id));
    } else if (_sortBy == 'oldest') {
      filteredOrders.sort((a, b) => a.id.compareTo(b.id));
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Orders'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Status',
            onSelected: (value) {
              setState(() => _filterStatus = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Semua')),
              const PopupMenuItem(
                value: 'pre_ordered',
                child: Text('Pre-Ordered'),
              ),
              const PopupMenuItem(value: 'approved', child: Text('Approved')),
              const PopupMenuItem(value: 'completed', child: Text('Completed')),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (value) {
              setState(() => _sortBy = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'newest', child: Text('Terbaru')),
              const PopupMenuItem(value: 'oldest', child: Text('Terlama')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminProvider.notifier).getAllOrders(),
        child: adminState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : filteredOrders.isEmpty
            ? const Center(child: Text('Tidak ada order'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            order.orderCode,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('User: ${order.user?.name ?? '-'}'),
                              Text('iPhone: ${order.iphone?.name ?? '-'}'),
                              Text(
                                'Tanggal: ${DateFormat('dd MMM yyyy').format(DateTime.parse(order.startDate))} - ${DateFormat('dd MMM yyyy').format(DateTime.parse(order.endDate))}',
                              ),
                              Text(
                                'Total: Rp ${order.totalPrice}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          trailing: Chip(
                            label: Text(
                              order.statusLabel,
                              style: const TextStyle(fontSize: 12),
                            ),
                            backgroundColor: _getStatusColor(order.status),
                          ),
                        ),
                        if (order.status == 'pre_ordered') ...[
                          const Divider(height: 1),
                          OverflowBar(
                            children: [
                              TextButton.icon(
                                onPressed: () =>
                                    _confirmUpdateStatus(order, 'approved'),
                                icon: const Icon(Icons.check, size: 20),
                                label: const Text('Approve'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.green,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _showDetailsDialog(order),
                                icon: const Icon(Icons.info, size: 20),
                                label: const Text('Detail'),
                              ),
                            ],
                          ),
                        ] else if (order.status == 'approved') ...[
                          const Divider(height: 1),
                          OverflowBar(
                            children: [
                              TextButton.icon(
                                onPressed: () =>
                                    _confirmUpdateStatus(order, 'completed'),
                                icon: const Icon(Icons.done_all, size: 20),
                                label: const Text('Complete'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _showDetailsDialog(order),
                                icon: const Icon(Icons.info, size: 20),
                                label: const Text('Detail'),
                              ),
                            ],
                          ),
                        ] else ...[
                          const Divider(height: 1),
                          OverflowBar(
                            children: [
                              TextButton.icon(
                                onPressed: () => _showDetailsDialog(order),
                                icon: const Icon(Icons.info, size: 20),
                                label: const Text('Detail'),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pre_ordered':
        return Colors.orange.shade100;
      case 'approved':
        return Colors.blue.shade100;
      case 'completed':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  void _showDetailsDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Order ${order.orderCode}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('User', order.user?.name ?? '-'),
                _buildDetailRow('Email', order.user?.email ?? '-'),
                _buildDetailRow('Phone', order.user?.phone ?? '-'),
                const Divider(),
                _buildDetailRow('iPhone', order.iphone?.name ?? '-'),
                _buildDetailRow(
                  'Harga/Hari',
                  'Rp ${order.iphone?.pricePerDay ?? 0}',
                ),
                const Divider(),
                _buildDetailRow(
                  'Tanggal Mulai',
                  DateFormat(
                    'dd MMM yyyy',
                  ).format(DateTime.parse(order.startDate)),
                ),
                _buildDetailRow(
                  'Tanggal Selesai',
                  DateFormat(
                    'dd MMM yyyy',
                  ).format(DateTime.parse(order.endDate)),
                ),
                _buildDetailRow(
                  'Durasi',
                  '${DateTime.parse(order.endDate).difference(DateTime.parse(order.startDate)).inDays} hari',
                ),
                const Divider(),
                _buildDetailRow(
                  'Total Harga',
                  'Rp ${order.totalPrice}',
                  isBold: true,
                ),
                _buildDetailRow('Status', order.statusLabel, isBold: true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmUpdateStatus(OrderModel order, String newStatus) {
    String statusLabel = newStatus == 'approved' ? 'Approve' : 'Complete';
    String message = newStatus == 'approved'
        ? 'Order akan disetujui dan pengguna dapat mengambil iPhone.'
        : 'Order akan ditandai sebagai selesai.';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$statusLabel Order'),
          content: Text(
            'Apakah Anda yakin ingin $statusLabel order ${order.orderCode}?\n\n$message',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await ref
                    .read(adminProvider.notifier)
                    .updateOrderStatus(order.id, newStatus);

                if (success && context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(statusLabel),
            ),
          ],
        );
      },
    );
  }
}
