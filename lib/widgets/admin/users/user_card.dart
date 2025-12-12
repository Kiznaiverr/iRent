import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/user_model.dart';

class UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;

  const UserCard({
    super.key,
    required this.user,
    this.onTap,
    this.onEdit,
    this.onToggleStatus,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = user.isActive
        ? const Color(0xFF4CAF50)
        : const Color(0xFF9E9E9E);
    final statusIcon = user.isActive
        ? Icons.check_circle_rounded
        : Icons.cancel_rounded;

    final roleColor = user.role == 'admin'
        ? const Color(0xFF6B9FE8)
        : const Color(0xFF9C27B0);
    final roleIcon = user.role == 'admin'
        ? Icons.admin_panel_settings_rounded
        : Icons.person_rounded;

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(roleColor, roleIcon),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                _buildBadges(roleColor, roleIcon, statusColor, statusIcon),
                if (user.penalty > 0) ...[
                  const SizedBox(height: 12),
                  _buildPenaltyWarning(),
                ],
                const SizedBox(height: 16),
                _buildContactInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(Color roleColor, IconData roleIcon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User Avatar
        user.profile != null && user.profile!.isNotEmpty
            ? CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(user.profile!),
              )
            : CircleAvatar(
                radius: 30,
                backgroundColor: roleColor.withValues(alpha: 0.2),
                child: Text(
                  user.name[0].toUpperCase(),
                  style: TextStyle(
                    color: roleColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
        const SizedBox(width: 16),
        // User Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '@${user.username}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        // More Options Menu
        _buildMoreMenu(),
      ],
    );
  }

  Widget _buildMoreMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit' && onEdit != null) {
          onEdit!();
        } else if (value == 'toggle_status' && onToggleStatus != null) {
          onToggleStatus!();
        } else if (value == 'delete' && onDelete != null) {
          onDelete!();
        }
      },
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.more_vert_rounded, size: 20, color: Colors.grey[700]),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_rounded, size: 20),
              SizedBox(width: 12),
              Text('Edit User'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'toggle_status',
          child: Row(
            children: [
              Icon(
                user.isActive
                    ? Icons.block_rounded
                    : Icons.check_circle_rounded,
                size: 20,
                color: user.isActive ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 12),
              Text(
                user.isActive ? 'Nonaktifkan' : 'Aktifkan',
                style: TextStyle(
                  color: user.isActive ? Colors.orange : Colors.green,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_rounded, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Hapus User', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBadges(
    Color roleColor,
    IconData roleIcon,
    Color statusColor,
    IconData statusIcon,
  ) {
    return Row(
      children: [
        // Role Badge
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  roleColor.withValues(alpha: 0.15),
                  roleColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: roleColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(roleIcon, size: 16, color: roleColor),
                const SizedBox(width: 8),
                Text(
                  user.role == 'admin' ? 'Admin' : 'User',
                  style: TextStyle(
                    color: roleColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Status Badge
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor.withValues(alpha: 0.15),
                  statusColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 8),
                Text(
                  user.isActive ? 'Aktif' : 'Nonaktif',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPenaltyWarning() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.red[50]!, Colors.red[100]!]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_rounded, size: 18, color: Colors.red[700]),
          const SizedBox(width: 8),
          Text(
            'Denda: Rp ${NumberFormat('#,###').format(user.penalty)}',
            style: TextStyle(
              color: Colors.red[900],
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.email_rounded, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  user.email ?? '-',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.phone_rounded, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                user.phone,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
