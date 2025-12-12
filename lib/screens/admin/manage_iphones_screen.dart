import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../models/iphone_model.dart';
import '../../widgets/admin/index.dart';
import '../../widgets/admin/iphones/index.dart';

class ManageIphonesScreen extends ConsumerStatefulWidget {
  const ManageIphonesScreen({super.key});

  @override
  ConsumerState<ManageIphonesScreen> createState() =>
      _ManageIphonesScreenState();
}

class _ManageIphonesScreenState extends ConsumerState<ManageIphonesScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminProvider.notifier).getAllIPhones();
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

    // Search filter
    List<IPhoneModel> filteredIphones = adminState.iphones;
    if (_searchQuery.isNotEmpty) {
      filteredIphones = filteredIphones.where((iphone) {
        final nameLower = iphone.name.toLowerCase();
        final specLower = iphone.specs.toLowerCase();
        final searchLower = _searchQuery.toLowerCase();
        return nameLower.contains(searchLower) ||
            specLower.contains(searchLower);
      }).toList();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Admin App Bar
          AdminAppBar(
            title: 'Kelola iPhone',
            icon: Icons.phone_iphone_rounded,
            primaryColor: const Color(0xFF4CAF50),
            secondaryColor: const Color(0xFF66BB6A),
            onRefresh: () async {
              await ref.read(adminProvider.notifier).getAllIPhones();
            },
          ),

          // Search Bar
          AdminSearchBar(
            controller: _searchController,
            hintText: 'Cari nama atau spesifikasi iPhone...',
            onChanged: (value) => setState(() => _searchQuery = value),
            onClear: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
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
          else if (filteredIphones.isEmpty)
            SliverToBoxAdapter(
              child: AdminEmptyState(
                icon: Icons.phone_iphone_rounded,
                title: 'Belum ada produk iPhone',
                subtitle: 'Tambahkan produk pertama Anda',
                color: const Color(0xFF4CAF50),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final iphone = filteredIphones[index];
                    return IPhoneCard(
                      iphone: iphone,
                      onEdit: () => EditIPhoneDialog.show(context, iphone),
                      onDelete: () => _handleDelete(iphone),
                      onAddStock: () => AddStockDialog.show(context, iphone),
                    );
                  },
                  childCount: filteredIphones.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () => CreateIPhoneDialog.show(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Tambah iPhone',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Future<void> _handleDelete(IPhoneModel iphone) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
                    const Color(0xFFF44336).withValues(alpha: 0.15),
                    const Color(0xFFE57373).withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Color(0xFFF44336),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Hapus iPhone',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'Yakin ingin menghapus ${iphone.name}? Aksi ini tidak dapat dibatalkan.',
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
              gradient: const LinearGradient(
                colors: [Color(0xFFF44336), Color(0xFFE57373)],
              ),
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
              child: const Text(
                'Hapus',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(adminProvider.notifier).deleteIPhone(iphone.id);
    }
  }
}
