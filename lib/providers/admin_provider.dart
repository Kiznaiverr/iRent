import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../models/iphone_model.dart';
import '../models/order_model.dart';
import '../models/rental_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

// Admin state
class AdminState {
  final bool isLoading;
  final List<UserModel> users;
  final List<IPhoneModel> iphones;
  final List<OrderModel> orders;
  final List<RentalModel> rentals;
  final List<RentalModel> overdueRentals;
  final String? error;

  AdminState({
    this.isLoading = false,
    this.users = const [],
    this.iphones = const [],
    this.orders = const [],
    this.rentals = const [],
    this.overdueRentals = const [],
    this.error,
  });

  AdminState copyWith({
    bool? isLoading,
    List<UserModel>? users,
    List<IPhoneModel>? iphones,
    List<OrderModel>? orders,
    List<RentalModel>? rentals,
    List<RentalModel>? overdueRentals,
    String? error,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      iphones: iphones ?? this.iphones,
      orders: orders ?? this.orders,
      rentals: rentals ?? this.rentals,
      overdueRentals: overdueRentals ?? this.overdueRentals,
      error: error,
    );
  }
}

// Admin provider
class AdminNotifier extends StateNotifier<AdminState> {
  final ApiService _apiService;

  AdminNotifier(this._apiService) : super(AdminState());

  // ========== USER MANAGEMENT ==========

  // Get all users
  Future<void> getAllUsers({String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.get(
        ApiConfig.adminUsers,
        queryParameters: status != null ? {'status': status} : null,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        final users = data.map((e) => UserModel.fromJson(e)).toList();
        state = state.copyWith(isLoading: false, users: users);
      }
    } catch (e) {
      final error = _apiService.handleError(e);
      state = state.copyWith(isLoading: false, error: error);
      Fluttertoast.showToast(msg: error);
    }
  }

  // Update user
  Future<bool> updateUser(int id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.put(
        ApiConfig.adminUserById(id),
        data: data,
      );
      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        Fluttertoast.showToast(msg: 'User berhasil diperbarui');
        await getAllUsers(); // Refresh list
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      final error = _apiService.handleError(e);
      state = state.copyWith(isLoading: false, error: error);
      Fluttertoast.showToast(msg: error);
      return false;
    }
  }

  // Soft delete user
  Future<bool> softDeleteUser(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.put(ApiConfig.adminUserSoftDelete(id));
      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        Fluttertoast.showToast(msg: 'User berhasil dinonaktifkan');
        await getAllUsers(); // Refresh list
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      final error = _apiService.handleError(e);
      state = state.copyWith(isLoading: false, error: error);
      Fluttertoast.showToast(msg: error);
      return false;
    }
  }

  // Hard delete user
  Future<bool> deleteUser(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.delete(ApiConfig.adminUserById(id));
      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        Fluttertoast.showToast(msg: 'User berhasil dihapus');
        await getAllUsers(); // Refresh list
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      final error = _apiService.handleError(e);
      state = state.copyWith(isLoading: false, error: error);
      Fluttertoast.showToast(msg: error);
      return false;
    }
  }

  // ========== IPHONE MANAGEMENT ==========

  // Get all iPhones (admin)
  Future<void> getAllIPhones({String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.get(
        status != null ? ApiConfig.adminAllIphones : ApiConfig.adminIphones,
        queryParameters: status != null ? {'status': status} : null,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        final iphones = data.map((e) => IPhoneModel.fromJson(e)).toList();
        state = state.copyWith(isLoading: false, iphones: iphones);
      }
    } catch (e) {
      final error = _apiService.handleError(e);
      state = state.copyWith(isLoading: false, error: error);
      Fluttertoast.showToast(msg: error);
    }
  }

  // Create iPhone
  Future<bool> createIPhone({
    required String name,
    required double pricePerDay,
    required String specs,
    required int stock,
    String? imagePath,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.uploadFile(
        ApiConfig.adminIphones,
        imagePath ?? '',
        'images',
        data: {
          'name': name,
          'price_per_day': pricePerDay,
          'specs': specs,
          'stock': stock,
        },
      );
      if (response.statusCode == 201) {
        state = state.copyWith(isLoading: false);
        Fluttertoast.showToast(msg: 'iPhone berhasil ditambahkan');
        await getAllIPhones(); // Refresh list
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      final error = _apiService.handleError(e);
      state = state.copyWith(isLoading: false, error: error);
      Fluttertoast.showToast(msg: error);
      return false;
    }
  }

  // Update iPhone
  Future<bool> updateIPhone(int id, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.put(
        ApiConfig.adminIphoneById(id),
        data: data,
      );
      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        Fluttertoast.showToast(msg: 'iPhone berhasil diperbarui');
        await getAllIPhones(); // Refresh list
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      final error = _apiService.handleError(e);
      state = state.copyWith(isLoading: false, error: error);
      Fluttertoast.showToast(msg: error);
      return false;
    }
  }

  // Delete iPhone
  Future<bool> deleteIPhone(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.delete(ApiConfig.adminIphoneById(id));
      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        Fluttertoast.showToast(msg: 'iPhone berhasil dihapus');
        await getAllIPhones(); // Refresh list
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      final error = _apiService.handleError(e);
      state = state.copyWith(isLoading: false, error: error);
      Fluttertoast.showToast(msg: error);
      return false;
    }
  }

  // Add stock
  Future<bool> addStock(int id, int stock) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.put(
        ApiConfig.adminIphoneStock(id),
        data: {'stock': stock},
      );
      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        Fluttertoast.showToast(msg: 'Stok berhasil ditambahkan');
        await getAllIPhones(); // Refresh list
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      final error = _apiService.handleError(e);
      state = state.copyWith(isLoading: false, error: error);
      Fluttertoast.showToast(msg: error);
      return false;
    }
  }

  // ========== ORDER MANAGEMENT ==========

  // Get all orders
  Future<void> getAllOrders({String? sort, String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final queryParams = <String, dynamic>{};
      if (sort != null) queryParams['sort'] = sort;
      if (status != null) queryParams['status'] = status;

      final response = await _apiService.get(
        ApiConfig.adminOrders,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
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

  // Update order status
  Future<bool> updateOrderStatus(int id, String status) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.put(
        ApiConfig.adminOrderStatus(id),
        data: {'status': status},
      );
      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        Fluttertoast.showToast(msg: 'Status order berhasil diperbarui');
        await getAllOrders(); // Refresh list
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      final error = _apiService.handleError(e);
      state = state.copyWith(isLoading: false, error: error);
      Fluttertoast.showToast(msg: error);
      return false;
    }
  }

  // ========== RENTAL MANAGEMENT ==========

  // Get all rentals
  Future<void> getAllRentals() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.get(ApiConfig.adminRentals);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        final rentals = data.map((e) => RentalModel.fromJson(e)).toList();
        state = state.copyWith(isLoading: false, rentals: rentals);
      }
    } catch (e) {
      final error = _apiService.handleError(e);
      state = state.copyWith(isLoading: false, error: error);
      Fluttertoast.showToast(msg: error);
    }
  }

  // Get overdue rentals
  Future<void> getOverdueRentals() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.get(ApiConfig.adminOverdueRentals);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        final rentals = data.map((e) => RentalModel.fromJson(e)).toList();
        state = state.copyWith(isLoading: false, overdueRentals: rentals);
      }
    } catch (e) {
      final error = _apiService.handleError(e);
      state = state.copyWith(isLoading: false, error: error);
      Fluttertoast.showToast(msg: error);
    }
  }

  // Return rental
  Future<bool> returnRental(int id, String returnDate) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.put(
        ApiConfig.adminReturnRental(id),
        data: {'return_date': returnDate},
      );
      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        Fluttertoast.showToast(msg: 'Rental berhasil dikembalikan');
        await getAllRentals(); // Refresh list
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      final error = _apiService.handleError(e);
      state = state.copyWith(isLoading: false, error: error);
      Fluttertoast.showToast(msg: error);
      return false;
    }
  }

  // ========== TESTIMONIAL MANAGEMENT ==========

  // Delete testimonial
  Future<bool> deleteTestimonial(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.delete(
        ApiConfig.adminDeleteTestimonial(id),
      );
      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        Fluttertoast.showToast(msg: 'Testimonial berhasil dihapus');
        return true;
      }
      state = state.copyWith(isLoading: false);
      return false;
    } catch (e) {
      final error = _apiService.handleError(e);
      state = state.copyWith(isLoading: false, error: error);
      Fluttertoast.showToast(msg: error);
      return false;
    }
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref.watch(apiServiceProvider));
});
