import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/theme.dart';
import '../../models/order_model.dart';
import 'status_badge.dart';

class OrderTrackingResult extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingResult({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.15),
                      AppColors.secondary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.phone_iphone_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.iphoneName ?? order.iphone?.name ?? 'iPhone',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.orderCode,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(status: order.status, label: order.statusLabel),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            Icons.calendar_month_rounded,
            'Tanggal Mulai',
            dateFormat.format(DateTime.parse(order.startDate)),
          ),
          _buildDetailRow(
            Icons.event_rounded,
            'Tanggal Selesai',
            dateFormat.format(DateTime.parse(order.endDate)),
          ),
          _buildDetailRow(
            Icons.attach_money_rounded,
            'Total Pembayaran',
            formatter.format(order.totalPrice),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor().withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(_getStatusIcon(), color: _getStatusColor(), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getStatusMessage(),
                    style: TextStyle(
                      fontSize: 14,
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (order.status) {
      case 'pre_ordered':
        return Colors.orange[700]!;
      case 'approved':
        return Colors.green[700]!;
      case 'rejected':
        return Colors.red[700]!;
      case 'completed':
        return Colors.blue[700]!;
      case 'cancelled':
        return Colors.grey[700]!;
      default:
        return AppColors.primary;
    }
  }

  IconData _getStatusIcon() {
    switch (order.status) {
      case 'pre_ordered':
        return Icons.schedule_rounded;
      case 'approved':
        return Icons.check_circle_outline_rounded;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'completed':
        return Icons.done_all_rounded;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _getStatusMessage() {
    switch (order.status) {
      case 'pre_ordered':
        return 'Pesanan Anda sedang menunggu persetujuan admin. Anda akan mendapat notifikasi via WhatsApp.';
      case 'approved':
        return 'Pesanan Anda telah disetujui! Silakan ambil iPhone di toko kami.';
      case 'rejected':
        return 'Maaf, pesanan Anda ditolak. Silakan hubungi admin untuk informasi lebih lanjut.';
      case 'completed':
        return 'Pesanan telah selesai. Terima kasih telah menggunakan layanan kami!';
      case 'cancelled':
        return 'Pesanan telah dibatalkan.';
      default:
        return 'Status pesanan tidak diketahui.';
    }
  }
}
