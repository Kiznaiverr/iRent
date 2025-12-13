import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_model.dart';

class StatusWarnings extends ConsumerWidget {
  final UserModel user;
  final VoidCallback onVerifyPhone;
  final VoidCallback onNavigateToRental;

  const StatusWarnings({
    super.key,
    required this.user,
    required this.onVerifyPhone,
    required this.onNavigateToRental,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Inactive Account Warning
        if (!user.isActive) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_rounded, color: Colors.red[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Akun Tidak Aktif',
                    style: TextStyle(
                      color: Colors.red[900],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Penalty Warning
        if (user.penalty > 0) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red[50]!, Colors.red[100]!],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[700],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Denda',
                        style: TextStyle(
                          color: Colors.red[900],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Rp ${user.penalty.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.red[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Overdue Rentals Warning
        if (user.penaltyInfo != null &&
            user.penaltyInfo!.hasPenalty &&
            user.penaltyInfo!.overdueRentals.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[50]!, Colors.orange[100]!],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[700],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Penyewaan Terlambat',
                        style: TextStyle(
                          color: Colors.orange[900],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${user.penaltyInfo!.overdueRentals.length} penyewaan terlambat',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[800],
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: onNavigateToRental,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Lihat',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Phone Verification Warning
        if (user.phoneVerified != null && !user.phoneVerified!) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Colors.orange[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nomor telepon belum diverifikasi',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.orange[900],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onVerifyPhone,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange[700],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Verifikasi',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
