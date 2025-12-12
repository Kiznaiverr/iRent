import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/rental_model.dart';

class RentalCard extends StatelessWidget {
  final RentalModel rental;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onReturn;

  const RentalCard({
    super.key,
    required this.rental,
    required this.isActive,
    required this.onTap,
    this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
    final daysRemaining = DateTime.parse(
      rental.endDate,
    ).difference(DateTime.now()).inDays;
    final isLate = rental.isOverdue && rental.isActive;

    Color statusColor;
    IconData statusIcon;

    if (isLate) {
      statusColor = const Color(0xFFF44336);
      statusIcon = Icons.warning_rounded;
    } else if (rental.status == 'returned') {
      statusColor = const Color(0xFF4CAF50);
      statusIcon = Icons.done_all_rounded;
    } else {
      statusColor = const Color(0xFF9C27B0);
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
                      child: Icon(statusIcon, color: statusColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rental.user?.name ?? 'User',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            rental.iphone?.name ?? 'iPhone',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
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
                        gradient: LinearGradient(
                          colors: [
                            statusColor.withValues(alpha: 0.15),
                            statusColor.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        rental.statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_rounded,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Mulai',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat.format(
                                DateTime.parse(rental.startDate),
                              ),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 30, color: Colors.grey[300]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.event_rounded,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Selesai',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              dateFormat.format(DateTime.parse(rental.endDate)),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Days remaining / Late info
                if (isActive) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isLate
                            ? [
                                const Color(0xFFF44336).withValues(alpha: 0.15),
                                const Color(0xFFE57373).withValues(alpha: 0.1),
                              ]
                            : [
                                const Color(0xFF9C27B0).withValues(alpha: 0.1),
                                const Color(0xFFBA68C8).withValues(alpha: 0.05),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isLate
                              ? Icons.warning_rounded
                              : Icons.schedule_rounded,
                          size: 16,
                          color: isLate
                              ? const Color(0xFFF44336)
                              : const Color(0xFF9C27B0),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isLate
                              ? 'Terlambat ${daysRemaining.abs()} hari'
                              : '$daysRemaining hari lagi',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isLate
                                ? const Color(0xFFF44336)
                                : const Color(0xFF9C27B0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Action Buttons
                if (rental.isActive) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (onReturn != null)
                        Expanded(
                          child: _buildActionButton(
                            label: 'Kembalikan',
                            icon: Icons.assignment_return_rounded,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                            ),
                            onPressed: onReturn!,
                          ),
                        ),
                      if (onReturn != null) const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          label: 'Detail',
                          icon: Icons.info_rounded,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6B9FE8), Color(0xFF8AB4F8)],
                          ),
                          onPressed: onTap,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox(height: 16),
                  _buildActionButton(
                    label: 'Lihat Detail',
                    icon: Icons.info_rounded,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6B9FE8), Color(0xFF8AB4F8)],
                    ),
                    onPressed: onTap,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
