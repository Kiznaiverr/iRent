import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../config/api_config.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
import '../screens/rental/my_rentals_screen.dart';
import 'auth_provider.dart';

// Order state
class OrderState {
  final bool isLoading;
  final List<OrderModel> orders;
  final OrderModel? selectedOrder;
  final String? error;

  OrderState({
    this.isLoading = false,
    this.orders = const [],
    this.selectedOrder,
    this.error,
  });

  OrderState copyWith({
    bool? isLoading,
    List<OrderModel>? orders,
    OrderModel? selectedOrder,
    String? error,
  }) {
    return OrderState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      selectedOrder: selectedOrder ?? this.selectedOrder,
      error: error,
    );
  }
}

// Order provider
class OrderNotifier extends StateNotifier<OrderState> {
  final ApiService _apiService;

  OrderNotifier(this._apiService) : super(OrderState());

  // Create order
  Future<bool> createOrder({
    required BuildContext context,
    required int iphoneId,
    required String startDate,
    required String endDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.post(
        ApiConfig.order,
        data: {
          'iphone_id': iphoneId,
          'start_date': startDate,
          'end_date': endDate,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;
        if (responseData != null && responseData['success'] == true) {
          state = state.copyWith(isLoading: false);
          Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Order berhasil dibuat',
          );
          return true;
        }
      }

      // Handle non-success responses
      state = state.copyWith(isLoading: false);
      final errorMessage = response.data?['message'] ?? 'Gagal membuat order';

      // Check for phone verification error
      if (errorMessage.toLowerCase().contains('verify your number') ||
          errorMessage.toLowerCase().contains('verifikasi') ||
          errorMessage.toLowerCase().contains('please verify')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            _showVerificationDialog(context);
          }
        });
        return false;
      }

      // Check for overdue rental error
      if (errorMessage.toLowerCase().contains('overdue') ||
          errorMessage.toLowerCase().contains('penalties') ||
          errorMessage.toLowerCase().contains('settle your outstanding')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            _showOverdueRentalDialog(context);
          }
        });
        return false;
      }

      Fluttertoast.showToast(msg: errorMessage);
      return false;
    } catch (e) {
      final error = _apiService.handleError(e);
      state = state.copyWith(isLoading: false, error: error);

      // Check if it's a phone verification error
      if (error.toLowerCase().contains('verify your number') ||
          error.toLowerCase().contains('verifikasi') ||
          error.toLowerCase().contains('please verify')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            _showVerificationDialog(context);
          }
        });
        return false;
      }

      // Check if it's an overdue rental error
      if (error.toLowerCase().contains('overdue') ||
          error.toLowerCase().contains('penalties') ||
          error.toLowerCase().contains('settle your outstanding')) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            _showOverdueRentalDialog(context);
          }
        });
        return false;
      }

      Fluttertoast.showToast(msg: error);
      return false;
    }
  }

  // Get user orders
  Future<void> getUserOrders() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.get(ApiConfig.userOrders);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        final orders = data.map((e) => OrderModel.fromJson(e)).toList();
        state = state.copyWith(isLoading: false, orders: orders);
      }
    } catch (e) {
      final error = _apiService.handleError(e);
      state = state.copyWith(isLoading: false, error: error);
      Fluttertoast.showToast(msg: error);
    }
  }

  // Track order by code
  Future<void> trackOrder(String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.get(ApiConfig.trackOrder(code));
      if (response.statusCode == 200) {
        final order = OrderModel.fromJson(
          response.data['data'] ?? response.data,
        );
        state = state.copyWith(isLoading: false, selectedOrder: order);
      }
    } catch (e) {
      final error = _apiService.handleError(e);
      state = state.copyWith(isLoading: false, error: error);
      Fluttertoast.showToast(msg: error);
    }
  }

  // Show verification dialog
  void _showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verifikasi Diperlukan'),
        content: const Text(
          'Untuk membuat pesanan, Anda perlu memverifikasi nomor telepon terlebih dahulu.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('Nanti'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/verify-phone');
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Verifikasi'),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  void _showOverdueRentalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Penyewaan Terlambat'),
        content: const Text(
          'Anda tidak dapat membuat pesanan baru karena memiliki penyewaan yang terlambat. Silakan selesaikan denda yang belum dibayar terlebih dahulu.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('Nanti'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to rental screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyRentalsScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text('Lihat Penyewaan'),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier(ref.watch(apiServiceProvider));
});
