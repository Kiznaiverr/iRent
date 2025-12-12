import 'package:flutter/material.dart';

class StatsOverview extends StatelessWidget {
  final int usersCount;
  final int iphonesCount;
  final int ordersCount;
  final int activeRentalsCount;
  final int overdueCount;
  final VoidCallback onUsersTap;
  final VoidCallback onIphonesTap;
  final VoidCallback onOrdersTap;
  final VoidCallback onRentalsTap;
  final VoidCallback onOverdueTap;

  const StatsOverview({
    super.key,
    required this.usersCount,
    required this.iphonesCount,
    required this.ordersCount,
    required this.activeRentalsCount,
    required this.overdueCount,
    required this.onUsersTap,
    required this.onIphonesTap,
    required this.onOrdersTap,
    required this.onRentalsTap,
    required this.onOverdueTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6B9FE8).withValues(alpha: 0.15),
                    const Color(0xFF8AB4F8).withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.analytics_rounded,
                color: Color(0xFF6B9FE8),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Statistik',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              icon: Icons.people_rounded,
              title: 'Total Users',
              value: usersCount.toString(),
              primaryColor: const Color(0xFF6B9FE8),
              secondaryColor: const Color(0xFF8AB4F8),
              onTap: onUsersTap,
            ),
            _buildStatCard(
              icon: Icons.phone_iphone_rounded,
              title: 'Total iPhone',
              value: iphonesCount.toString(),
              primaryColor: const Color(0xFF4CAF50),
              secondaryColor: const Color(0xFF66BB6A),
              onTap: onIphonesTap,
            ),
            _buildStatCard(
              icon: Icons.shopping_cart_rounded,
              title: 'Total Orders',
              value: ordersCount.toString(),
              primaryColor: const Color(0xFFFF9800),
              secondaryColor: const Color(0xFFFFB74D),
              onTap: onOrdersTap,
            ),
            _buildStatCard(
              icon: Icons.assignment_rounded,
              title: 'Active Rentals',
              value: activeRentalsCount.toString(),
              primaryColor: const Color(0xFF9C27B0),
              secondaryColor: const Color(0xFFBA68C8),
              onTap: onRentalsTap,
            ),
            _buildStatCard(
              icon: Icons.warning_rounded,
              title: 'Overdue',
              value: overdueCount.toString(),
              primaryColor: const Color(0xFFF44336),
              secondaryColor: const Color(0xFFE57373),
              onTap: onOverdueTap,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color primaryColor,
    required Color secondaryColor,
    required VoidCallback onTap,
  }) {
    return Container(
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
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withValues(alpha: 0.15),
                        secondaryColor.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 26, color: primaryColor),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
