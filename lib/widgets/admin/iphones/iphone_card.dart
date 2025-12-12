import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../models/iphone_model.dart';

class IPhoneCard extends StatelessWidget {
  final IPhoneModel iphone;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAddStock;

  const IPhoneCard({
    super.key,
    required this.iphone,
    this.onEdit,
    this.onDelete,
    this.onAddStock,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

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
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                _buildImage(),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 8),
                      _buildPrice(formatter),
                      const SizedBox(height: 4),
                      _buildStock(),
                      const SizedBox(height: 8),
                      _buildSpecs(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: iphone.images.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CachedNetworkImage(
                imageUrl: iphone.images.first,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.phone_iphone_rounded, size: 32),
              ),
            )
          : const Icon(
              Icons.phone_iphone_rounded,
              size: 32,
              color: Color(0xFF4CAF50),
            ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            iphone.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: iphone.isAvailable
                  ? [
                      const Color(0xFF4CAF50).withValues(alpha: 0.15),
                      const Color(0xFF66BB6A).withValues(alpha: 0.1),
                    ]
                  : [
                      const Color(0xFFF44336).withValues(alpha: 0.15),
                      const Color(0xFFE57373).withValues(alpha: 0.1),
                    ],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            iphone.status.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: iphone.isAvailable
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFF44336),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrice(NumberFormat formatter) {
    return Row(
      children: [
        Icon(Icons.payments_rounded, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '${formatter.format(iphone.pricePerDay)}/hari',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStock() {
    return Row(
      children: [
        Icon(Icons.inventory_2_rounded, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          'Stok: ${iphone.stock} unit',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSpecs() {
    return Text(
      iphone.specs,
      style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.5),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          if (onAddStock != null)
            Expanded(
              child: _buildActionButton(
                icon: Icons.add_circle_outline_rounded,
                label: 'Tambah Stok',
                color: const Color(0xFF4CAF50),
                onTap: onAddStock!,
              ),
            ),
          if (onAddStock != null) const SizedBox(width: 8),
          if (onEdit != null)
            Expanded(
              child: _buildActionButton(
                icon: Icons.edit_rounded,
                label: 'Edit',
                color: const Color(0xFF2196F3),
                onTap: onEdit!,
              ),
            ),
          if (onEdit != null) const SizedBox(width: 8),
          if (onDelete != null)
            Expanded(
              child: _buildActionButton(
                icon: Icons.delete_rounded,
                label: 'Hapus',
                color: const Color(0xFFF44336),
                onTap: onDelete!,
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
      height: 44,
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
