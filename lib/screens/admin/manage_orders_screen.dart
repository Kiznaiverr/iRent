import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../models/order_model.dart';
import '../../widgets/admin/index.dart';
import '../../widgets/admin/orders/index.dart';

class ManageOrdersScreen extends ConsumerStatefulWidget {
  const ManageOrdersScreen({super.key});

  @override
  ConsumerState<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends ConsumerState<ManageOrdersScreen> {
  String _filterStatus = 'all';
  String _sortBy = 'newest';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminProvider.notifier).getAllOrders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    List<OrderModel> filteredOrders = _getFilteredOrders(adminState.orders);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Admin App Bar
          AdminAppBar(
            title: 'Kelola Orders',
            icon: Icons.shopping_cart_rounded,
            primaryColor: const Color(0xFFFF9800),
            secondaryColor: const Color(0xFFFFB74D),
            onRefresh: () async {
              await ref.read(adminProvider.notifier).getAllOrders();
            },
          ),

          // Search Bar
          AdminSearchBar(
            controller: _searchController,
            hintText: 'Cari nama user atau iPhone...',
            onChanged: (value) => setState(() => _searchQuery = value),
            onClear: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),

          // Filter & Sort
          OrderFilterChip(
            currentFilter: _filterStatus,
            currentSort: _sortBy,
            onFilterChanged: (value) => setState(() => _filterStatus = value),
            onSortChanged: (value) => setState(() => _sortBy = value),
          ),

          // Content
          if (adminState.isLoading)
            SliverToBoxAdapter(
              child: Container(
                height: 400,
                padding: const EdgeInsets.all(48),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
            )
          else if (filteredOrders.isEmpty)
            SliverToBoxAdapter(
              child: AdminEmptyState(
                icon: Icons.shopping_cart_rounded,
                title: 'Tidak ada order',
                subtitle: _filterStatus == 'all'
                    ? 'Belum ada order masuk'
                    : 'Tidak ada order dengan status ini',
                color: const Color(0xFFFF9800),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final order = filteredOrders[index];
                    return OrderCard(
                      order: order,
                      onTap: () => OrderDetailDialog.show(context, order),
                      onApprove: order.status == 'pre_ordered'
                          ? () => _confirmUpdateStatus(order, 'approved')
                          : null,
                      onComplete: order.status == 'approved'
                          ? () => _confirmUpdateStatus(order, 'completed')
                          : null,
                    );
                  },
                  childCount: filteredOrders.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<OrderModel> _getFilteredOrders(List<OrderModel> orders) {
    List<OrderModel> filtered = orders;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        final userNameLower = (order.userName ?? '').toLowerCase();
        final iphoneNameLower = (order.iphoneName ?? '').toLowerCase();
        final searchLower = _searchQuery.toLowerCase();
        return userNameLower.contains(searchLower) ||
            iphoneNameLower.contains(searchLower);
      }).toList();
    }

    // Status filter
    if (_filterStatus != 'all') {
      filtered = filtered.where((order) => order.status == _filterStatus).toList();
    }

    // Sort
    if (_sortBy == 'newest') {
      filtered.sort((a, b) => b.id.compareTo(a.id));
    } else if (_sortBy == 'oldest') {
      filtered.sort((a, b) => a.id.compareTo(b.id));
    }

    return filtered;
  }

  Future<void> _confirmUpdateStatus(OrderModel order, String newStatus) async {
    final statusLabel = newStatus == 'approved' ? 'Approve' : 'Complete';
    final statusColor = newStatus == 'approved'
        ? const Color(0xFF4CAF50)
        : const Color(0xFF6B9FE8);
    final statusGradient = newStatus == 'approved'
        ? const [Color(0xFF4CAF50), Color(0xFF66BB6A)]
        : const [Color(0xFF6B9FE8), Color(0xFF8AB4F8)];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusGradient[0].withValues(alpha: 0.15),
                      statusGradient[1].withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  newStatus == 'approved'
                      ? Icons.check_circle_rounded
                      : Icons.done_all_rounded,
                  color: statusColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$statusLabel Order',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: Text(
            'Yakin ingin $statusLabel order ${order.orderCode}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: statusGradient),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  statusLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await ref.read(adminProvider.notifier).updateOrderStatus(
            order.id,
            newStatus,
          );
    }
  }
}
