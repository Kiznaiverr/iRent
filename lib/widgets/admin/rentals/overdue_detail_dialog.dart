import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/overdue_model.dart';
import '../../../providers/admin_provider.dart';

class OverdueDetailDialog extends ConsumerStatefulWidget {
  final OverdueModel overdue;

  const OverdueDetailDialog({super.key, required this.overdue});

  static void show(BuildContext context, OverdueModel overdue) {
    showDialog(
      context: context,
      builder: (context) => OverdueDetailDialog(overdue: overdue),
    );
  }

  @override
  ConsumerState<OverdueDetailDialog> createState() =>
      _OverdueDetailDialogState();
}

class _OverdueDetailDialogState extends ConsumerState<OverdueDetailDialog> {
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFF44336), Color(0xFFE57373)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Detail Overdue Rental',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info with Avatar
                    Row(
                      children: [
                        widget.overdue.userProfile != null &&
                                widget.overdue.userProfile!.isNotEmpty
                            ? CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(
                                  widget.overdue.userProfile!,
                                ),
                              )
                            : CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.red[100],
                                child: Text(
                                  widget.overdue.userName.isNotEmpty
                                      ? widget.overdue.userName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: Color(0xFFC62828),
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.overdue.userName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.overdue.userEmail,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                widget.overdue.userPhone,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // iPhone & Order Info
                    _buildDetailRow('iPhone', widget.overdue.iphoneName),
                    _buildDetailRow('Order Code', widget.overdue.orderCode),
                    _buildDetailRow(
                      'Order Total',
                      'Rp ${NumberFormat('#,###').format(double.tryParse(widget.overdue.orderTotal) ?? 0)}',
                    ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Rental Dates
                    _buildDetailRow(
                      'Rental Start',
                      dateFormat.format(
                        DateTime.parse(widget.overdue.rentalStartDate),
                      ),
                    ),
                    _buildDetailRow(
                      'Rental End',
                      dateFormat.format(
                        DateTime.parse(widget.overdue.rentalEndDate),
                      ),
                    ),
                    _buildDetailRow(
                      'Original End Date',
                      dateFormat.format(
                        DateTime.parse(widget.overdue.originalEndDate),
                      ),
                    ),
                    if (widget.overdue.actualReturnDate != null)
                      _buildDetailRow(
                        'Actual Return',
                        dateFormat.format(
                          DateTime.parse(widget.overdue.actualReturnDate!),
                        ),
                      ),

                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Penalty Info (Highlighted)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red[50]!, Colors.red[100]!],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[300]!),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 20,
                                    color: Colors.red[700],
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Days Overdue',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${widget.overdue.daysOverdue} hari',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red[900],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.payment_rounded,
                                    size: 20,
                                    color: Colors.red[700],
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Penalty per Day',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Rp ${NumberFormat('#,###').format(widget.overdue.penaltyPerDay)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[900],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet_rounded,
                                    size: 22,
                                    color: Colors.red[900],
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Total Penalty',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Rp ${NumberFormat('#,###').format(int.tryParse(widget.overdue.totalPenalty) ?? 0)}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red[900],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Tutup',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showReturnDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Kembalikan Rental',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
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

  void _showReturnDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Pengembalian'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rental: ${widget.overdue.orderCode}'),
            Text('User: ${widget.overdue.userName}'),
            Text('iPhone: ${widget.overdue.iphoneName}'),
            const SizedBox(height: 16),
            const Text(
              'Apakah Anda yakin ingin mengembalikan rental ini?',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => _returnRental(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Kembalikan'),
          ),
        ],
      ),
    );
  }

  Future<void> _returnRental(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      // Send only date part, not full date-time
      final returnDate = DateTime.now().toIso8601String().split('T')[0];
      final success = await ref
          .read(adminProvider.notifier)
          .returnRental(widget.overdue.id, returnDate);

      if (success && mounted) {
        navigator.pop(); // Close return dialog
        navigator.pop(); // Close detail dialog
        messenger.showSnackBar(
          const SnackBar(content: Text('Rental berhasil dikembalikan')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
