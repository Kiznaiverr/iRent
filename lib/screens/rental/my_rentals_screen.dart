import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/rental_provider.dart';
import '../../models/rental_model.dart';

class MyRentalsScreen extends ConsumerStatefulWidget {
  const MyRentalsScreen({super.key});

  @override
  ConsumerState<MyRentalsScreen> createState() => _MyRentalsScreenState();
}

class _MyRentalsScreenState extends ConsumerState<MyRentalsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(rentalProvider.notifier).getUserRentals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rentalState = ref.watch(rentalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rental Saya')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(rentalProvider.notifier).getUserRentals(),
        child: rentalState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : rentalState.rentals.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.phone_iphone_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada rental aktif',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rental iPhone Anda akan muncul di sini',
                      style: TextStyle(color: Colors.grey[500], fontSize: 14),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: rentalState.rentals.length,
                itemBuilder: (context, index) {
                  final rental = rentalState.rentals[index];
                  return _buildRentalCard(rental);
                },
              ),
      ),
    );
  }

  Widget _buildRentalCard(RentalModel rental) {
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final now = DateTime.now();
    final endDate = DateTime.parse(rental.endDate);
    final daysRemaining = endDate.difference(now).inDays;

    Color statusColor;
    IconData statusIcon;

    if (rental.isOverdue) {
      statusColor = Colors.red;
      statusIcon = Icons.warning;
    } else if (rental.status == 'returned') {
      statusColor = Colors.green;
      statusIcon = Icons.done_all;
    } else {
      statusColor = Colors.blue;
      statusIcon = Icons.phone_iphone;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showRentalDetails(rental),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      rental.iphone?.name ?? 'iPhone',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 16, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          rental.statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${dateFormat.format(DateTime.parse(rental.startDate))} - ${dateFormat.format(endDate)}',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
              if (rental.isActive) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      daysRemaining > 0 ? Icons.access_time : Icons.warning,
                      size: 16,
                      color: daysRemaining > 0 ? Colors.blue : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      daysRemaining > 0
                          ? 'Sisa $daysRemaining hari'
                          : 'Sudah melewati tenggat waktu',
                      style: TextStyle(
                        color: daysRemaining > 0 ? Colors.blue : Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
              if (rental.penalty > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 16,
                        color: Colors.red[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Denda: Rp ${NumberFormat('#,###').format(rental.penalty)}',
                        style: TextStyle(
                          color: Colors.red[900],
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showRentalDetails(RentalModel rental) {
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Detail Rental',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow('iPhone', rental.iphone?.name ?? '-'),
                  _buildDetailRow('Status', rental.statusLabel),
                  _buildDetailRow(
                    'Tanggal Mulai',
                    dateFormat.format(DateTime.parse(rental.startDate)),
                  ),
                  _buildDetailRow(
                    'Tanggal Selesai',
                    dateFormat.format(DateTime.parse(rental.endDate)),
                  ),
                  if (rental.returnDate != null)
                    _buildDetailRow(
                      'Tanggal Pengembalian',
                      dateFormat.format(DateTime.parse(rental.returnDate!)),
                    ),
                  if (rental.penalty > 0)
                    _buildDetailRow(
                      'Denda',
                      formatter.format(rental.penalty),
                      isWarning: true,
                    ),
                  const SizedBox(height: 24),
                  if (rental.isOverdue)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.red[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Rental Anda telah melewati batas waktu. Segera kembalikan untuk menghindari denda tambahan.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (rental.isActive)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Pastikan mengembalikan iPhone dalam kondisi baik sesuai tenggat waktu.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isWarning ? Colors.red[900] : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
