import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../config/api_config.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';
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
      Fluttertoast.showToast(msg: errorMessage);
      return false;
    } catch (e) {
      final error = _apiService.handleError(e);
      state = state.copyWith(isLoading: false, error: error);
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

  // Clear selected order
  void clearSelected() {
    state = state.copyWith(selectedOrder: null);
  }
}

final orderProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) {
  return OrderNotifier(ref.watch(apiServiceProvider));
});
