import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class TrackOrderScreen extends ConsumerStatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  ConsumerState<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends ConsumerState<TrackOrderScreen> {
  final _codeController = TextEditingController();
  bool _hasSearched = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _trackOrder() async {
    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Masukkan kode pesanan')));
      return;
    }

    await ref
        .read(orderProvider.notifier)
        .trackOrder(_codeController.text.trim());
    setState(() => _hasSearched = true);
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final order = orderState.selectedOrder;

    return Scaffold(
      appBar: AppBar(title: const Text('Lacak Pesanan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _codeController,
              decoration: InputDecoration(
                labelText: 'Kode Pesanan',
                hintText: 'Masukkan kode pesanan Anda',
                prefixIcon: const Icon(Icons.confirmation_number),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _trackOrder,
                ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _trackOrder(),
            ),
            const SizedBox(height: 24),
            if (orderState.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_hasSearched && order == null)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Pesanan tidak ditemukan',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              )
            else if (order != null)
              _buildOrderDetails(order),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetails(OrderModel order) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

    Color statusColor;
    IconData statusIcon;

    switch (order.status) {
      case 'pre_ordered':
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        break;
      case 'approved':
        statusColor = Colors.blue;
        statusIcon = Icons.check_circle;
        break;
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.done_all;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, size: 48, color: statusColor),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                order.statusLabel,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),
            const Divider(height: 32),
            _buildDetailRow('iPhone', order.iphone?.name ?? '-'),
            _buildDetailRow('Kode Pesanan', order.orderCode),
            _buildDetailRow(
              'Tanggal Mulai',
              dateFormat.format(DateTime.parse(order.startDate)),
            ),
            _buildDetailRow(
              'Tanggal Selesai',
              dateFormat.format(DateTime.parse(order.endDate)),
            ),
            _buildDetailRow(
              'Total Harga',
              formatter.format(order.totalPrice),
              isTotal: true,
            ),
            const SizedBox(height: 16),
            if (order.status == 'pre_ordered')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pesanan Anda sedang menunggu persetujuan admin.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
                fontSize: isTotal ? 18 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
