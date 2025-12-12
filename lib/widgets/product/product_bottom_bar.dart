import 'package:flutter/material.dart';
import '../../models/iphone_model.dart';
import '../../screens/order/order_form_screen.dart';

class ProductBottomBar extends StatelessWidget {
  final IPhoneModel iphone;
  final VoidCallback? onRentNow;

  const ProductBottomBar({super.key, required this.iphone, this.onRentNow});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: iphone.isAvailable
                ? const LinearGradient(
                    colors: [Color(0xFF6B9FE8), Color(0xFF8AB4F8)],
                  )
                : null,
            color: iphone.isAvailable ? null : Colors.grey[400],
            borderRadius: BorderRadius.circular(16),
            boxShadow: iphone.isAvailable
                ? [
                    BoxShadow(
                      color: const Color(0xFF6B9FE8).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: iphone.isAvailable
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderFormScreen(iphone: iphone),
                        ),
                      ).then((result) {
                        if (result == 'orders' && context.mounted) {
                          Navigator.of(context).pushReplacementNamed(
                            '/home',
                            arguments: {'tab': 1},
                          );
                        }
                      });
                    }
                  : null,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      iphone.isAvailable
                          ? Icons.shopping_bag_rounded
                          : Icons.cancel_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      iphone.isAvailable ? 'Sewa Sekarang' : 'Stok Habis',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
