import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/admin_provider.dart';
import '../../models/order_model.dart';

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
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    List<OrderModel> filteredOrders = adminState.orders;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filteredOrders = filteredOrders.where((order) {
        final userNameLower = (order.userName ?? '').toLowerCase();
        final iphoneNameLower = (order.iphoneName ?? '').toLowerCase();
        final searchLower = _searchQuery.toLowerCase();
        return userNameLower.contains(searchLower) ||
            iphoneNameLower.contains(searchLower);
      }).toList();
    }

    // Filter
    if (_filterStatus != 'all') {
      filteredOrders = filteredOrders
          .where((order) => order.status == _filterStatus)
          .toList();
    }

    // Sort by ID as proxy for creation order
    if (_sortBy == 'newest') {
      filteredOrders.sort((a, b) => b.id.compareTo(a.id));
    } else if (_sortBy == 'oldest') {
      filteredOrders.sort((a, b) => a.id.compareTo(b.id));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFFFF9800),
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.filter_list_rounded,
                    color: Color(0xFFFF9800),
                  ),
                  tooltip: 'Filter Status',
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    setState(() => _filterStatus = value);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'all', child: Text('Semua')),
                    const PopupMenuItem(
                      value: 'pre_ordered',
                      child: Text('Pre-Ordered'),
                    ),
                    const PopupMenuItem(
                      value: 'approved',
                      child: Text('Approved'),
                    ),
                    const PopupMenuItem(
                      value: 'completed',
                      child: Text('Completed'),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.sort_rounded,
                    color: Color(0xFFFF9800),
                  ),
                  tooltip: 'Sort',
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: (value) {
                    setState(() => _sortBy = value);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'newest',
                      child: Text('Terbaru'),
                    ),
                    const PopupMenuItem(
                      value: 'oldest',
                      child: Text('Terlama'),
                    ),
                  ],
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Kelola Orders',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w700,
                ),
              ),
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFFFF9800).withValues(alpha: 0.05),
                      const Color(0xFFFFB74D).withValues(alpha: 0.02),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFF9800).withValues(alpha: 0.15),
                              const Color(0xFFFFB74D).withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.shopping_cart_rounded,
                          size: 40,
                          color: Color(0xFFFF9800),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Cari nama user atau iPhone...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.grey[400],
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear_rounded,
                            color: Colors.grey[400],
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),
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
              child: Container(
                padding: const EdgeInsets.all(48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_cart_rounded,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Tidak ada order',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _filterStatus == 'all'
                          ? 'Belum ada order masuk'
                          : 'Tidak ada order dengan status ini',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final order = filteredOrders[index];
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
                              // Header with status
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          statusGradient[0].withValues(
                                            alpha: 0.15,
                                          ),
                                          statusGradient[1].withValues(
                                            alpha: 0.1,
                                          ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                statusGradient[0].withValues(
                                                  alpha: 0.15,
                                                ),
                                                statusGradient[1].withValues(
                                                  alpha: 0.1,
                                                ),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                              ),
                              const SizedBox(height: 16),
                              // Details
                              Container(
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
                                      order.iphoneName ??
                                          order.iphone?.name ??
                                          '-',
                                    ),
                                    _buildDetailRow(
                                      Icons.event_rounded,
                                      'Periode',
                                      '${dateFormat.format(DateTime.parse(order.startDate))} - ${dateFormat.format(DateTime.parse(order.endDate))}',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Total Price
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(
                                        0xFFFF9800,
                                      ).withValues(alpha: 0.1),
                                      const Color(
                                        0xFFFFB74D,
                                      ).withValues(alpha: 0.05),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFFF9800,
                                    ).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                              ),
                            ],
                          ),
                        ),
                        // Actions
                        if (order.status == 'pre_ordered' ||
                            order.status == 'approved') ...[
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
                                if (order.status == 'pre_ordered')
                                  Expanded(
                                    child: _buildActionButton(
                                      icon: Icons.check_circle_rounded,
                                      label: 'Approve',
                                      color: const Color(0xFF4CAF50),
                                      onTap: () => _confirmUpdateStatus(
                                        order,
                                        'approved',
                                      ),
                                    ),
                                  ),
                                if (order.status == 'approved')
                                  Expanded(
                                    child: _buildActionButton(
                                      icon: Icons.done_all_rounded,
                                      label: 'Complete',
                                      color: const Color(0xFF6B9FE8),
                                      onTap: () => _confirmUpdateStatus(
                                        order,
                                        'completed',
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildActionButton(
                                    icon: Icons.info_rounded,
                                    label: 'Detail',
                                    color: const Color(0xFF9C27B0),
                                    onTap: () => _showDetailsDialog(order),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: _buildActionButton(
                              icon: Icons.info_rounded,
                              label: 'Lihat Detail',
                              color: const Color(0xFF9C27B0),
                              onTap: () => _showDetailsDialog(order),
                            ),
                          ),
                      ],
                    ),
                  );
                }, childCount: filteredOrders.length),
              ),
            ),
        ],
      ),
    );
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
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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

  void _showDetailsDialog(OrderModel order) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');

    showDialog(
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
                      const Color(0xFF9C27B0).withValues(alpha: 0.15),
                      const Color(0xFFBA68C8).withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.info_rounded,
                  color: Color(0xFF9C27B0),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Detail Order',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDialogDetailRow('Order Code', order.orderCode),
                _buildDialogDetailRow(
                  'User',
                  order.userName ?? order.user?.name ?? '-',
                ),
                _buildDialogDetailRow(
                  'iPhone',
                  order.iphoneName ?? order.iphone?.name ?? '-',
                ),
                _buildDialogDetailRow(
                  'Start Date',
                  dateFormat.format(DateTime.parse(order.startDate)),
                ),
                _buildDialogDetailRow(
                  'End Date',
                  dateFormat.format(DateTime.parse(order.endDate)),
                ),
                _buildDialogDetailRow('Status', order.statusLabel),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF9C27B0).withValues(alpha: 0.1),
                        const Color(0xFFBA68C8).withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Price',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                      Text(
                        formatter.format(order.totalPrice),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Tutup',
                  style: TextStyle(
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
  }

  Widget _buildDialogDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
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

  void _confirmUpdateStatus(OrderModel order, String newStatus) {
    final statusLabel = newStatus == 'approved' ? 'Approve' : 'Complete';
    final statusColor = newStatus == 'approved'
        ? const Color(0xFF4CAF50)
        : const Color(0xFF6B9FE8);
    final statusGradient = newStatus == 'approved'
        ? const [Color(0xFF4CAF50), Color(0xFF66BB6A)]
        : const [Color(0xFF6B9FE8), Color(0xFF8AB4F8)];

    showDialog(
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Apakah Anda yakin ingin $statusLabel order ${order.orderCode}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
                onPressed: () async {
                  final success = await ref
                      .read(adminProvider.notifier)
                      .updateOrderStatus(order.id, newStatus);

                  if (success && context.mounted) {
                    Navigator.pop(context);
                  }
                },
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
  }
}
