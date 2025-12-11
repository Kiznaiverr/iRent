import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
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
    // Load data setelah frame pertama
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
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: adminState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : adminState.error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${adminState.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Statistik',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        _buildStatCard(
                          icon: Icons.people,
                          title: 'Total Users',
                          value: adminState.users.length.toString(),
                          color: Colors.blue,
                        ),
                        _buildStatCard(
                          icon: Icons.phone_iphone,
                          title: 'Total iPhone',
                          value: adminState.iphones.length.toString(),
                          color: Colors.green,
                        ),
                        _buildStatCard(
                          icon: Icons.shopping_cart,
                          title: 'Total Orders',
                          value: adminState.orders.length.toString(),
                          color: Colors.orange,
                        ),
                        _buildStatCard(
                          icon: Icons.assignment,
                          title: 'Active Rentals',
                          value: adminState.rentals
                              .where((r) => r.isActive)
                              .length
                              .toString(),
                          color: Colors.purple,
                        ),
                        _buildStatCard(
                          icon: Icons.warning,
                          title: 'Overdue Rentals',
                          value: adminState.overdueRentals.length.toString(),
                          color: Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (adminState.overdueRentals.isNotEmpty) ...[
                      const Text(
                        'Overdue Rentals Details',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: adminState.overdueRentals.length,
                        itemBuilder: (context, index) {
                          final overdue = adminState.overdueRentals[index];
                          return Card(
                            color: Colors.red[50],
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      overdue.userProfile != null &&
                                              overdue.userProfile!.isNotEmpty
                                          ? CircleAvatar(
                                              radius: 20,
                                              backgroundImage: NetworkImage(
                                                overdue.userProfile!,
                                              ),
                                            )
                                          : CircleAvatar(
                                              radius: 20,
                                              backgroundColor: const Color(
                                                0xFFFFCDD2,
                                              ),
                                              child: Text(
                                                overdue.userName.isNotEmpty
                                                    ? overdue.userName[0]
                                                          .toUpperCase()
                                                    : 'U',
                                                style: const TextStyle(
                                                  color: Color(0xFFC62828),
                                                ),
                                              ),
                                            ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Order: ${overdue.orderCode}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              overdue.userName,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text('iPhone: ${overdue.iphoneName}'),
                                  Text('Phone: ${overdue.userPhone}'),
                                  Text('Email: ${overdue.userEmail}'),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Days Overdue: ${overdue.daysOverdue}',
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Penalty: Rp ${overdue.totalPenalty}',
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Original End: ${_formatDate(overdue.originalEndDate)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildActionCard(
                      icon: Icons.people,
                      title: 'Kelola Users',
                      subtitle: 'Lihat dan kelola pengguna',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageUsersScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      icon: Icons.phone_iphone,
                      title: 'Kelola iPhone',
                      subtitle: 'Tambah dan kelola produk iPhone',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageIphonesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      icon: Icons.shopping_cart,
                      title: 'Kelola Orders',
                      subtitle: 'Kelola pesanan pelanggan',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageOrdersScreen(),
                          ),
                        );
                      },
                    ),
                    _buildActionCard(
                      icon: Icons.assignment,
                      title: 'Kelola Rentals',
                      subtitle: 'Kelola penyewaan aktif',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ManageRentalsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
