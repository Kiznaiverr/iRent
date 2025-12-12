import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/order_provider.dart';
import '../../widgets/order/index.dart';

class TrackOrderScreen extends ConsumerStatefulWidget {
  const TrackOrderScreen({super.key});

  @override
  ConsumerState<TrackOrderScreen> createState() => _TrackOrderScreenState();
}

class _TrackOrderScreenState extends ConsumerState<TrackOrderScreen> {
  final _codeController = TextEditingController();
  bool _hasSearched = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _trackOrder() async {
    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Masukkan kode pesanan')),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    await ref
        .read(orderProvider.notifier)
        .trackOrder(_codeController.text.trim());
    setState(() => _hasSearched = true);
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);
    final order = orderState.selectedOrder;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          const TrackOrderAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Box
                  OrderSearchBox(
                    controller: _codeController,
                    onSearch: _trackOrder,
                    isLoading: orderState.isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Results
                  if (_hasSearched) ...[
                    if (orderState.isLoading)
                      const OrderLoadingState()
                    else if (order != null)
                      OrderTrackingResult(order: order)
                    else
                      const OrderNotFoundState(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
