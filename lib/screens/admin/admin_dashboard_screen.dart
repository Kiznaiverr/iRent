import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/admin/index.dart';
import '../../widgets/admin/dashboard/index.dart';
import 'manage_users_screen.dart';
import 'manage_iphones_screen.dart';
import 'manage_orders_screen.dart';
import 'manage_rentals_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadData());
  }

  Future<void> _loadData() async {
    await Future.wait([
      ref.read(adminProvider.notifier).getAllUsers(),
      ref.read(adminProvider.notifier).getAllIPhones(),
      ref.read(adminProvider.notifier).getAllOrders(),
      ref.read(adminProvider.notifier).getAllRentals(),
      ref.read(adminProvider.notifier).getOverdueRentals(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          AdminAppBar(
            title: 'Admin Dashboard',
            icon: Icons.dashboard_rounded,
            primaryColor: const Color(0xFF6B9FE8),
            secondaryColor: const Color(0xFF8AB4F8),
          ),

          // Content
          if (adminState.isLoading)
            SliverFillRemaining(
              child: Container(
                padding: const EdgeInsets.all(48),
                child: const Center(child: CircularProgressIndicator()),
              ),
            )
          else if (adminState.error != null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Terjadi Kesalahan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        adminState.error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6B9FE8), Color(0xFF8AB4F8)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _loadData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Coba Lagi',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Grid
                    StatsOverview(
                      usersCount: adminState.users.length,
                      iphonesCount: adminState.iphones.length,
                      ordersCount: adminState.orders.length,
                      activeRentalsCount: adminState.rentals
                          .where((r) => r.isActive)
                          .length,
                      overdueCount: adminState.overdueRentals.length,
                      onUsersTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageUsersScreen(),
                        ),
                      ),
                      onIphonesTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageIphonesScreen(),
                        ),
                      ),
                      onOrdersTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageOrdersScreen(),
                        ),
                      ),
                      onRentalsTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageRentalsScreen(),
                        ),
                      ),
                      onOverdueTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageRentalsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const SizedBox(height: 32),

                    // Overdue Rentals Section
                    if (adminState.overdueRentals.isNotEmpty) ...[
                      AdminSectionTitle(title: 'Overdue Rentals'),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: adminState.overdueRentals.length,
                        itemBuilder: (context, index) {
                          return OverdueRentalCard(
                            overdue: adminState.overdueRentals[index],
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Quick Actions Section
                    AdminSectionTitle(title: 'Quick Actions'),
                    QuickActionCard(
                      icon: Icons.people_rounded,
                      title: 'Kelola Users',
                      subtitle: 'Lihat dan kelola pengguna',
                      primaryColor: const Color(0xFF6B9FE8),
                      secondaryColor: const Color(0xFF8AB4F8),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageUsersScreen(),
                        ),
                      ),
                    ),
                    QuickActionCard(
                      icon: Icons.phone_iphone_rounded,
                      title: 'Kelola iPhone',
                      subtitle: 'Tambah dan kelola produk iPhone',
                      primaryColor: const Color(0xFF4CAF50),
                      secondaryColor: const Color(0xFF66BB6A),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageIphonesScreen(),
                        ),
                      ),
                    ),
                    QuickActionCard(
                      icon: Icons.shopping_cart_rounded,
                      title: 'Kelola Orders',
                      subtitle: 'Kelola pesanan pelanggan',
                      primaryColor: const Color(0xFFFF9800),
                      secondaryColor: const Color(0xFFFFB74D),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageOrdersScreen(),
                        ),
                      ),
                    ),
                    QuickActionCard(
                      icon: Icons.assignment_rounded,
                      title: 'Kelola Rentals',
                      subtitle: 'Kelola penyewaan aktif',
                      primaryColor: const Color(0xFF9C27B0),
                      secondaryColor: const Color(0xFFBA68C8),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManageRentalsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
