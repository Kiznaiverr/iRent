import 'package:flutter/material.dart';

class UserFilterChip extends StatelessWidget {
  final String currentStatus;
  final String currentRole;
  final Function(String) onStatusChanged;
  final Function(String) onRoleChanged;

  const UserFilterChip({
    super.key,
    required this.currentStatus,
    required this.currentRole,
    required this.onStatusChanged,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Row(
          children: [
            // Filter Status
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: PopupMenuButton<String>(
                  icon: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.toggle_on_rounded,
                        color: Color(0xFF6B9FE8),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getStatusLabel(currentStatus),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B9FE8),
                        ),
                      ),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: onStatusChanged,
                  itemBuilder: (context) => [
                    _buildMenuItem('all', 'Semua Status'),
                    _buildMenuItem('active', 'Aktif'),
                    _buildMenuItem('inactive', 'Nonaktif'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Filter Role
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: PopupMenuButton<String>(
                  icon: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.badge_rounded,
                        color: Color(0xFF6B9FE8),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getRoleLabel(currentRole),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6B9FE8),
                        ),
                      ),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  onSelected: onRoleChanged,
                  itemBuilder: (context) => [
                    _buildMenuItem('all', 'Semua Role'),
                    _buildMenuItem('admin', 'Admin'),
                    _buildMenuItem('user', 'User'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, String label) {
    return PopupMenuItem(value: value, child: Text(label));
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Aktif';
      case 'inactive':
        return 'Nonaktif';
      default:
        return 'Semua Status';
    }
  }

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'user':
        return 'User';
      default:
        return 'Semua Role';
    }
  }
}
