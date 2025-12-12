import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_model.dart';
import '../../widgets/admin/index.dart';
import '../../widgets/admin/users/index.dart';

class ManageUsersScreen extends ConsumerStatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  ConsumerState<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends ConsumerState<ManageUsersScreen> {
  String _filterStatus = 'all';
  String _filterRole = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminProvider.notifier).getAllUsers();
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
    final filteredUsers = _getFilteredUsers(adminState.users);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          // Admin App Bar
          AdminAppBar(
            title: 'Kelola Users',
            icon: Icons.people_rounded,
            primaryColor: const Color(0xFF6B9FE8),
            secondaryColor: const Color(0xFF8AB4F8),
            onRefresh: () async {
              await ref.read(adminProvider.notifier).getAllUsers();
            },
          ),

          // Search Bar
          AdminSearchBar(
            controller: _searchController,
            hintText: 'Cari nama atau email...',
            onChanged: (value) => setState(() => _searchQuery = value),
            onClear: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),

          // Filter Status & Role
          UserFilterChip(
            currentStatus: _filterStatus,
            currentRole: _filterRole,
            onStatusChanged: (value) => setState(() => _filterStatus = value),
            onRoleChanged: (value) => setState(() => _filterRole = value),
          ),

          // Content
          if (adminState.isLoading)
            SliverToBoxAdapter(
              child: Container(
                height: 400,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
            )
          else if (filteredUsers.isEmpty)
            SliverToBoxAdapter(
              child: AdminEmptyState(
                icon: Icons.people_outline_rounded,
                title: 'Tidak ada pengguna',
                subtitle: 'Data pengguna akan muncul di sini',
                color: const Color(0xFF6B9FE8),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final user = filteredUsers[index];
                    return UserCard(
                      user: user,
                      onTap: () => UserDetailDialog.show(
                        context,
                        user,
                        onEdit: () => EditUserDialog.show(context, user),
                      ),
                      onEdit: () => EditUserDialog.show(context, user),
                      onToggleStatus: () => _confirmToggleStatus(user),
                      onDelete: () => _confirmDelete(user),
                    );
                  },
                  childCount: filteredUsers.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<UserModel> _getFilteredUsers(List<UserModel> users) {
    List<UserModel> filtered = users;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        final nameLower = user.name.toLowerCase();
        final emailLower = (user.email ?? '').toLowerCase();
        final searchLower = _searchQuery.toLowerCase();
        return nameLower.contains(searchLower) ||
            emailLower.contains(searchLower);
      }).toList();
    }

    // Status filter
    if (_filterStatus != 'all') {
      filtered = filtered.where((user) => user.status == _filterStatus).toList();
    }

    // Role filter
    if (_filterRole != 'all') {
      filtered = filtered.where((user) => user.role == _filterRole).toList();
    }

    return filtered;
  }

  Future<void> _confirmToggleStatus(UserModel user) async {
    final newStatus = user.isActive ? 'inactive' : 'active';
    final action = user.isActive ? 'Nonaktifkan' : 'Aktifkan';
    final color = user.isActive ? Colors.orange : Colors.green;

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
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  user.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$action User',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: Text(
            'Yakin ingin $action ${user.name}?',
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
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                action,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await ref.read(adminProvider.notifier).updateUser(
            user.id,
            {'status': newStatus},
          );
    }
  }

  Future<void> _confirmDelete(UserModel user) async {
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
                  color: Colors.red.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Hapus User',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: Text(
            'Yakin ingin menghapus ${user.name}? Aksi ini tidak dapat dibatalkan.',
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
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Hapus',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await ref.read(adminProvider.notifier).deleteUser(user.id);
    }
  }
}
