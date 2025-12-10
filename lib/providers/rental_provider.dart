import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../config/api_config.dart';
import '../models/rental_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

// Rental state
class RentalState {
  final bool isLoading;
  final List<RentalModel> rentals;
  final String? error;

  RentalState({this.isLoading = false, this.rentals = const [], this.error});

  RentalState copyWith({
    bool? isLoading,
    List<RentalModel>? rentals,
    String? error,
  }) {
    return RentalState(
      isLoading: isLoading ?? this.isLoading,
      rentals: rentals ?? this.rentals,
      error: error,
    );
  }
}

// Rental provider
class RentalNotifier extends StateNotifier<RentalState> {
  final ApiService _apiService;

  RentalNotifier(this._apiService) : super(RentalState());

  // Get user rentals
  Future<void> getUserRentals() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.get(ApiConfig.userRentals);
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
}

final rentalProvider = StateNotifierProvider<RentalNotifier, RentalState>((
  ref,
) {
  return RentalNotifier(ref.watch(apiServiceProvider));
});
