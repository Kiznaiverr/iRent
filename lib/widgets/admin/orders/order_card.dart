import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  final VoidCallback? onApprove;
  final VoidCallback? onComplete;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onApprove,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final statusColor = _getStatusColor(order.status);
    final statusGradient = _getStatusGradient(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(statusColor, statusGradient),
                const SizedBox(height: 16),
                _buildDetails(dateFormat),
                const SizedBox(height: 16),
                _buildTotalPrice(formatter),
              ],
            ),
          ),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader(Color statusColor, List<Color> statusGradient) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusGradient[0].withValues(alpha: 0.15),
                statusGradient[1].withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            _getStatusIcon(order.status),
            color: statusColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.orderCode,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusGradient[0].withValues(alpha: 0.15),
                      statusGradient[1].withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  order.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetails(DateFormat dateFormat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            Icons.person_rounded,
            'User',
            order.userName ?? order.user?.name ?? '-',
          ),
          _buildDetailRow(
            Icons.phone_iphone_rounded,
            'iPhone',
            order.iphoneName ?? order.iphone?.name ?? '-',
          ),
          _buildDetailRow(
            Icons.event_rounded,
            'Periode',
            '${dateFormat.format(DateTime.parse(order.startDate))} - ${dateFormat.format(DateTime.parse(order.endDate))}',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPrice(NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF9800).withValues(alpha: 0.1),
            const Color(0xFFFFB74D).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF9800).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Harga',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF9800),
            ),
          ),
          Text(
            formatter.format(order.totalPrice),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFFFF9800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    if (order.status == 'pre_ordered' || order.status == 'approved') {
      return Column(
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.grey[200]!,
                  Colors.grey[100]!,
                  Colors.grey[200]!,
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (order.status == 'pre_ordered' && onApprove != null)
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.check_circle_rounded,
                      label: 'Approve',
                      color: const Color(0xFF4CAF50),
                      onTap: onApprove!,
                    ),
                  ),
                if (order.status == 'approved' && onComplete != null)
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.done_all_rounded,
                      label: 'Complete',
                      color: const Color(0xFF6B9FE8),
                      onTap: onComplete!,
                    ),
                  ),
                if ((order.status == 'pre_ordered' && onApprove != null) ||
                    (order.status == 'approved' && onComplete != null))
                  const SizedBox(width: 8),
                if (onTap != null)
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.info_rounded,
                      label: 'Detail',
                      color: const Color(0xFF9C27B0),
                      onTap: onTap!,
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: onTap != null
            ? _buildActionButton(
                icon: Icons.info_rounded,
                label: 'Lihat Detail',
                color: const Color(0xFF9C27B0),
                onTap: onTap!,
              )
            : const SizedBox.shrink(),
      );
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pre_ordered':
        return const Color(0xFFFF9800);
      case 'approved':
        return const Color(0xFF6B9FE8);
      case 'completed':
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }

  List<Color> _getStatusGradient(String status) {
    switch (status) {
      case 'pre_ordered':
        return const [Color(0xFFFF9800), Color(0xFFFFB74D)];
      case 'approved':
        return const [Color(0xFF6B9FE8), Color(0xFF8AB4F8)];
      case 'completed':
        return const [Color(0xFF4CAF50), Color(0xFF66BB6A)];
      default:
        return [Colors.grey, Colors.grey[400]!];
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pre_ordered':
        return Icons.schedule_rounded;
      case 'approved':
        return Icons.check_circle_rounded;
      case 'completed':
        return Icons.done_all_rounded;
      default:
        return Icons.info_rounded;
    }
  }
}
