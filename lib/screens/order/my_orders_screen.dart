import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../widgets/order/index.dart';

class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(orderProvider.notifier).getUserOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(orderProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const OrderAppBar(),
      body: _buildContent(orderState),
    );
  }

  Widget _buildContent(dynamic orderState) {
    if (orderState.isLoading) {
      return const OrderLoadingState();
    } else if (orderState.orders.isEmpty) {
      return const OrderEmptyState();
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: orderState.orders.length,
        itemBuilder: (context, index) {
          final order = orderState.orders[index];
          return OrderCard(order: order, onTap: () => _showOrderDetails(order));
        },
      );
    }
  }

  void _showOrderDetails(OrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderDetailModal(order: order),
    );
  }
}
