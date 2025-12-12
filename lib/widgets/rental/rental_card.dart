import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/rental_model.dart';

class RentalCard extends StatelessWidget {
  final RentalModel rental;
  final VoidCallback onTap;

  const RentalCard({super.key, required this.rental, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final now = DateTime.now();

    DateTime? startDateTime;
    DateTime? endDateTime;

    try {
      startDateTime = DateTime.parse(rental.startDate);
    } catch (e) {
      startDateTime = now;
    }

    try {
      endDateTime = DateTime.parse(rental.endDate);
    } catch (e) {
      endDateTime = now.add(const Duration(days: 1));
    }

    // Calculate days remaining
    final nowDate = DateTime(now.year, now.month, now.day);
    final endDate = DateTime(
      endDateTime.year,
      endDateTime.month,
      endDateTime.day,
    );
    final daysRemaining = endDate.difference(nowDate).inDays;
    final isOverdueByDate = daysRemaining < 0;
    final isActuallyOverdue =
        rental.isOverdue || (rental.isActive && isOverdueByDate);

    Color statusColor;
    IconData statusIcon;

    if (isActuallyOverdue) {
      statusColor = const Color(0xFFF44336);
      statusIcon = Icons.warning_rounded;
    } else if (rental.status == 'returned') {
      statusColor = const Color(0xFF4CAF50);
      statusIcon = Icons.done_all_rounded;
    } else {
      statusColor = const Color(0xFF6B9FE8);
      statusIcon = Icons.phone_iphone_rounded;
    }

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Container
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor.withValues(alpha: 0.15),
                            statusColor.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.devices_rounded,
                        color: statusColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rental.iphone?.name ?? 'iPhone',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${dateFormat.format(startDateTime)} - ${dateFormat.format(endDateTime)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 14, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            rental.statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Days Remaining or Overdue Warning
                if (rental.isActive && !isActuallyOverdue) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: daysRemaining <= 2
                          ? Colors.orange[50]
                          : const Color(0xFF6B9FE8).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: daysRemaining <= 2
                            ? Colors.orange[200]!
                            : const Color(0xFF6B9FE8).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          daysRemaining <= 2
                              ? Icons.warning_amber_rounded
                              : Icons.access_time_rounded,
                          size: 18,
                          color: daysRemaining <= 2
                              ? Colors.orange[700]
                              : const Color(0xFF6B9FE8),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          daysRemaining > 0
                              ? 'Sisa $daysRemaining hari lagi'
                              : 'Jatuh tempo hari ini',
                          style: TextStyle(
                            color: daysRemaining <= 2
                                ? Colors.orange[900]
                                : const Color(0xFF6B9FE8),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Penalty Warning
                if (rental.penalty > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[50]!, Colors.red[100]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 18,
                          color: Colors.red[700],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Denda: Rp ${NumberFormat('#,###').format(rental.penalty)}',
                          style: TextStyle(
                            color: Colors.red[900],
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Overdue Warning
                if (isActuallyOverdue && rental.isActive) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          size: 18,
                          color: Colors.red[700],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sudah melewati tenggat waktu!',
                            style: TextStyle(
                              color: Colors.red[900],
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
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
      ),
    );
  }
}
