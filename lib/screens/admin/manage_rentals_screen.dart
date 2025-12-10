import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_provider.dart';
import '../../models/rental_model.dart';

class ManageRentalsScreen extends ConsumerStatefulWidget {
  const ManageRentalsScreen({super.key});

  @override
  ConsumerState<ManageRentalsScreen> createState() =>
      _ManageRentalsScreenState();
}

class _ManageRentalsScreenState extends ConsumerState<ManageRentalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      ref.read(adminProvider.notifier).getAllRentals();
      ref.read(adminProvider.notifier).getOverdueRentals();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    final activeRentals = adminState.rentals.where((r) => r.isActive).toList();
    final returnedRentals = adminState.rentals
        .where((r) => r.status == 'returned')
        .toList();
    final overdueRentals = adminState.overdueRentals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Rentals'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Aktif (${activeRentals.length})'),
            Tab(text: 'Terlambat (${overdueRentals.length})'),
            Tab(text: 'Dikembalikan (${returnedRentals.length})'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(adminProvider.notifier).getAllRentals();
          await ref.read(adminProvider.notifier).getOverdueRentals();
        },
        child: adminState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildRentalList(activeRentals, isActive: true),
                  _buildRentalList(overdueRentals, isOverdue: true),
                  _buildRentalList(returnedRentals),
                ],
              ),
      ),
    );
  }

  Widget _buildRentalList(
    List<RentalModel> rentals, {
    bool isActive = false,
    bool isOverdue = false,
  }) {
    if (rentals.isEmpty) {
      return Center(
        child: Text(
          isActive
              ? 'Tidak ada rental aktif'
              : isOverdue
              ? 'Tidak ada rental terlambat'
              : 'Tidak ada rental yang dikembalikan',
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rentals.length,
      itemBuilder: (context, index) {
        final rental = rentals[index];
        final daysRemaining = DateTime.parse(
          rental.endDate,
        ).difference(DateTime.now()).inDays;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  rental.user?.name ?? 'User',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('iPhone: ${rental.iphone?.name ?? '-'}'),
                    Text(
                      'Mulai: ${DateFormat('dd MMM yyyy').format(DateTime.parse(rental.startDate))}',
                    ),
                    Text(
                      'Selesai: ${DateFormat('dd MMM yyyy').format(DateTime.parse(rental.endDate))}',
                    ),
                    if (rental.returnDate != null)
                      Text(
                        'Dikembalikan: ${DateFormat('dd MMM yyyy').format(DateTime.parse(rental.returnDate!))}',
                      ),
                    if (rental.isOverdue && rental.isActive)
                      Text(
                        'Terlambat ${daysRemaining.abs()} hari',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else if (rental.isActive)
                      Text(
                        'Sisa $daysRemaining hari',
                        style: TextStyle(
                          color: daysRemaining <= 2
                              ? Colors.orange
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (rental.penalty > 0)
                      Text(
                        'Denda: Rp ${rental.penalty}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                trailing: Chip(
                  label: Text(
                    rental.statusLabel,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: _getStatusColor(rental.status),
                ),
              ),
              if (rental.isActive) ...[
                const Divider(height: 1),
                OverflowBar(
                  children: [
                    TextButton.icon(
                      onPressed: () => _showReturnDialog(rental),
                      icon: const Icon(Icons.assignment_return, size: 20),
                      label: const Text('Kembalikan'),
                      style: TextButton.styleFrom(foregroundColor: Colors.blue),
                    ),
                    TextButton.icon(
                      onPressed: () => _showDetailsDialog(rental),
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
                      onPressed: () => _showDetailsDialog(rental),
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
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green.shade100;
      case 'overdue':
        return Colors.red.shade100;
      case 'returned':
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  void _showDetailsDialog(RentalModel rental) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Detail Rental'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('User', rental.user?.name ?? '-'),
                _buildDetailRow('Email', rental.user?.email ?? '-'),
                _buildDetailRow('Phone', rental.user?.phone ?? '-'),
                const Divider(),
                _buildDetailRow('iPhone', rental.iphone?.name ?? '-'),
                _buildDetailRow('Rental ID', rental.id.toString()),
                const Divider(),
                _buildDetailRow(
                  'Tanggal Mulai',
                  DateFormat(
                    'dd MMM yyyy',
                  ).format(DateTime.parse(rental.startDate)),
                ),
                _buildDetailRow(
                  'Tanggal Selesai',
                  DateFormat(
                    'dd MMM yyyy',
                  ).format(DateTime.parse(rental.endDate)),
                ),
                if (rental.returnDate != null)
                  _buildDetailRow(
                    'Tanggal Kembali',
                    DateFormat(
                      'dd MMM yyyy',
                    ).format(DateTime.parse(rental.returnDate!)),
                  ),
                const Divider(),
                _buildDetailRow('Status', rental.statusLabel, isBold: true),
                if (rental.penalty > 0)
                  _buildDetailRow(
                    'Denda',
                    'Rp ${rental.penalty}',
                    isBold: true,
                  ),
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

  void _showReturnDialog(RentalModel rental) {
    final penaltyController = TextEditingController();
    final now = DateTime.now();
    final endDate = DateTime.parse(rental.endDate);
    final isLate = now.isAfter(endDate);
    final daysLate = isLate ? now.difference(endDate).inDays : 0;

    if (isLate) {
      // Calculate suggested penalty (e.g., 50000 per day)
      final suggestedPenalty = daysLate * 50000;
      penaltyController.text = suggestedPenalty.toString();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Kembalikan Rental'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('User: ${rental.user?.name ?? '-'}'),
                Text('iPhone: ${rental.iphone?.name ?? '-'}'),
                const SizedBox(height: 16),
                if (isLate) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.warning,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Rental Terlambat',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Terlambat: $daysLate hari'),
                        Text(
                          'Denda disarankan: Rp ${daysLate * 50000}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                TextField(
                  controller: penaltyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Denda',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                    helperText: 'Masukkan 0 jika tidak ada denda',
                  ),
                ),
              ],
            ),
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
                    .returnRental(rental.id, DateTime.now().toIso8601String());

                if (success && context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Kembalikan'),
            ),
          ],
        );
      },
    );
  }
}
