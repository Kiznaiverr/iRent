import 'package:flutter/material.dart';
import '../../models/iphone_model.dart';

class ProductStockSection extends StatelessWidget {
  final IPhoneModel iphone;

  const ProductStockSection({super.key, required this.iphone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iphone.isAvailable
                  ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              iphone.isAvailable
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: iphone.isAvailable ? const Color(0xFF4CAF50) : Colors.red,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  iphone.isAvailable ? 'Tersedia' : 'Stok Habis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: iphone.isAvailable
                        ? const Color(0xFF4CAF50)
                        : Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Stok tersedia: ${iphone.stock} unit',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
