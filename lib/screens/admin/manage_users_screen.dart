import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../models/user_model.dart';

class ManageUsersScreen extends ConsumerStatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  ConsumerState<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends ConsumerState<ManageUsersScreen> {
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(adminProvider.notifier).getAllUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);

    List<UserModel> filteredUsers = adminState.users;
    if (_filterStatus != 'all') {
      filteredUsers = filteredUsers
          .where((user) => user.status == _filterStatus)
          .toList();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Users'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() => _filterStatus = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Semua')),
              const PopupMenuItem(value: 'active', child: Text('Aktif')),
              const PopupMenuItem(value: 'inactive', child: Text('Nonaktif')),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(adminProvider.notifier).getAllUsers(),
        child: adminState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : filteredUsers.isEmpty
            ? const Center(child: Text('Tidak ada pengguna'))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: user.profile != null && user.profile!.isNotEmpty
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(user.profile!),
                            )
                          : CircleAvatar(
                              backgroundColor: user.isActive
                                  ? Colors.green
                                  : Colors.grey,
                              child: Text(
                                user.name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                      title: Text(user.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('@${user.username}'),
                          Text('Role: ${user.role}'),
                          if (user.penalty > 0)
                            Text(
                              'Denda: Rp ${user.penalty}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditDialog(user);
                          } else if (value == 'soft_delete') {
                            _confirmSoftDelete(user);
                          } else if (value == 'delete') {
                            _confirmHardDelete(user);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'soft_delete',
                            child: Row(
                              children: [
                                const Icon(Icons.block, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  user.isActive ? 'Nonaktifkan' : 'Aktifkan',
                                ),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 8),
                                Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _showEditDialog(UserModel user) {
    final roleController = TextEditingController(text: user.role);
    String selectedStatus = user.status;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit ${user.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: roleController.text,
                    decoration: const InputDecoration(labelText: 'Role'),
                    items: const [
                      DropdownMenuItem(value: 'user', child: Text('User')),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (value) {
                      roleController.text = value!;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                      DropdownMenuItem(
                        value: 'inactive',
                        child: Text('Inactive'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => selectedStatus = value!);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final success = await ref
                        .read(adminProvider.notifier)
                        .updateUser(user.id, {
                          'role': roleController.text,
                          'status': selectedStatus,
                        });

                    if (success && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmSoftDelete(UserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user.isActive ? 'Nonaktifkan User' : 'Aktifkan User'),
          content: Text(
            user.isActive
                ? 'Apakah Anda yakin ingin menonaktifkan ${user.name}?'
                : 'Apakah Anda yakin ingin mengaktifkan ${user.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await ref
                    .read(adminProvider.notifier)
                    .softDeleteUser(user.id);

                if (success && context.mounted) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: user.isActive ? Colors.orange : Colors.green,
              ),
              child: Text(user.isActive ? 'Nonaktifkan' : 'Aktifkan'),
            ),
          ],
        );
      },
    );
  }

  void _confirmHardDelete(UserModel user) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus User'),
          content: Text(
            'Apakah Anda yakin ingin menghapus ${user.name}? Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final success = await ref
                    .read(adminProvider.notifier)
                    .deleteUser(user.id);

                if (success && context.mounted) {
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }
}
