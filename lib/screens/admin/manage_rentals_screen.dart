import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../models/rental_model.dart';
import '../../models/overdue_model.dart';
import '../../widgets/admin/index.dart';
import '../../widgets/admin/rentals/index.dart';

class ManageRentalsScreen extends ConsumerStatefulWidget {
  const ManageRentalsScreen({super.key});

  @override
  ConsumerState<ManageRentalsScreen> createState() =>
      _ManageRentalsScreenState();
}

class _ManageRentalsScreenState extends ConsumerState<ManageRentalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      ref.read(adminProvider.notifier).getAllRentals();
      ref.read(adminProvider.notifier).getOverdueRentals();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    // Search filter helper for RentalModel
    List<RentalModel> filterRentals(List<RentalModel> rentals) {
      if (_searchQuery.isEmpty) return rentals;
      return rentals.where((rental) {
        final userNameLower = (rental.userName ?? '').toLowerCase();
        final iphoneNameLower = (rental.iphone?.name ?? '').toLowerCase();
        final searchLower = _searchQuery.toLowerCase();
        return userNameLower.contains(searchLower) ||
            iphoneNameLower.contains(searchLower);
      }).toList();
    }

    // Search filter helper for OverdueModel
    List<OverdueModel> filterOverdueRentals(List<OverdueModel> rentals) {
      if (_searchQuery.isEmpty) return rentals;
      return rentals.where((rental) {
        final userNameLower = rental.userName.toLowerCase();
        final iphoneNameLower = rental.iphoneName.toLowerCase();
        final searchLower = _searchQuery.toLowerCase();
        return userNameLower.contains(searchLower) ||
            iphoneNameLower.contains(searchLower);
      }).toList();
    }

    final activeRentals = filterRentals(
      adminState.rentals.where((r) => r.isActive).toList(),
    );
    final returnedRentals = filterRentals(
      adminState.rentals.where((r) => r.status == 'returned').toList(),
    );
    final overdueRentals = filterOverdueRentals(adminState.overdueRentals);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Modern SliverAppBar with TabBar
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
                  color: Color(0xFF9C27B0),
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
                child: IconButton(
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: Color(0xFF9C27B0),
                  ),
                  onPressed: () async {
                    await ref.read(adminProvider.notifier).getAllRentals();
                    await ref.read(adminProvider.notifier).getOverdueRentals();
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Kelola Rentals',
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
                      const Color(0xFF9C27B0).withValues(alpha: 0.15),
                      const Color(0xFFBA68C8).withValues(alpha: 0.08),
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
                              const Color(0xFF9C27B0).withValues(alpha: 0.25),
                              const Color(0xFFBA68C8).withValues(alpha: 0.18),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.book_online_rounded,
                          size: 40,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF9C27B0),
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: const Color(0xFF9C27B0),
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: [
                    Tab(text: 'Aktif (${activeRentals.length})'),
                    Tab(text: 'Terlambat (${overdueRentals.length})'),
                    Tab(text: 'Dikembalikan (${returnedRentals.length})'),
                  ],
                ),
              ),
            ),
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

          // TabBarView Content
          SliverFillRemaining(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(adminProvider.notifier).getAllRentals();
                await ref.read(adminProvider.notifier).getOverdueRentals();
              },
              child: adminState.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildRentalList(activeRentals, isActive: true),
                        _buildOverdueList(overdueRentals),
                        _buildRentalList(returnedRentals),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRentalList(List<RentalModel> rentals, {bool isActive = false}) {
    if (rentals.isEmpty) {
      return AdminEmptyState(
        icon: Icons.book_online_rounded,
        title: isActive
            ? 'Tidak ada rental aktif'
            : 'Tidak ada rental yang dikembalikan',
        subtitle: 'Data rental akan muncul di sini',
        color: const Color(0xFF9C27B0),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: rentals.length,
      itemBuilder: (context, index) {
        final rental = rentals[index];
        return RentalCard(
          rental: rental,
          isActive: isActive,
          onTap: () => RentalDetailDialog.show(context, rental),
          onReturn: isActive
              ? () => RentalReturnDialog.show(context, rental)
              : null,
        );
      },
    );
  }

  Widget _buildOverdueList(List<OverdueModel> overdues) {
    if (overdues.isEmpty) {
      return AdminEmptyState(
        icon: Icons.warning_rounded,
        title: 'Tidak ada rental terlambat',
        subtitle: 'Semua rental sesuai jadwal',
        color: const Color(0xFFF44336),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: overdues.length,
      itemBuilder: (context, index) {
        final overdue = overdues[index];
        return OverdueCard(
          overdue: overdue,
          onTap: () => OverdueDetailDialog.show(context, overdue),
        );
      },
    );
  }
}
