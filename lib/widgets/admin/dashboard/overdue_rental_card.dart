import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/overdue_model.dart';

class OverdueRentalCard extends StatelessWidget {
  final OverdueModel overdue;

  const OverdueRentalCard({super.key, required this.overdue});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF44336).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF44336).withValues(alpha: 0.08),
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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF44336).withValues(alpha: 0.3),
                    width: 2,
                  ),
                  gradient:
                      overdue.userProfile == null ||
                          overdue.userProfile!.isEmpty
                      ? LinearGradient(
                          colors: [
                            const Color(0xFFF44336).withValues(alpha: 0.8),
                            const Color(0xFFE57373).withValues(alpha: 0.8),
                          ],
                        )
                      : null,
                ),
                child:
                    overdue.userProfile != null &&
                        overdue.userProfile!.isNotEmpty
                    ? CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(overdue.userProfile!),
                      )
                    : CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.transparent,
                        child: Text(
                          overdue.userName.isNotEmpty
                              ? overdue.userName[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overdue.orderCode,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      overdue.userName,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  Icons.phone_iphone_rounded,
                  'iPhone',
                  overdue.iphoneName,
                ),
                _buildDetailRow(
                  Icons.phone_rounded,
                  'Telepon',
                  overdue.userPhone,
                ),
                _buildDetailRow(
                  Icons.email_rounded,
                  'Email',
                  overdue.userEmail,
                ),
                _buildDetailRow(
                  Icons.event_rounded,
                  'Original End',
                  _formatDate(overdue.originalEndDate),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFF44336).withValues(alpha: 0.15),
                        const Color(0xFFE57373).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Days Overdue',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFF44336),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${overdue.daysOverdue}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF44336),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFF44336).withValues(alpha: 0.15),
                        const Color(0xFFE57373).withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Penalty',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFF44336),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatter.format(
                          int.tryParse(overdue.totalPenalty) ?? 0,
                        ),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFF44336),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final format = DateFormat('dd MMM yyyy', 'id_ID');
      return format.format(date);
    } catch (e) {
      return dateString;
    }
  }
}
