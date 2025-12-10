import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../config/api_config.dart';
import '../models/iphone_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

// iPhone state
class IPhoneState {
  final bool isLoading;
  final List<IPhoneModel> iphones;
  final IPhoneModel? selectedIPhone;
  final String? error;

  IPhoneState({
    this.isLoading = false,
    this.iphones = const [],
    this.selectedIPhone,
    this.error,
  });

  IPhoneState copyWith({
    bool? isLoading,
    List<IPhoneModel>? iphones,
    IPhoneModel? selectedIPhone,
    String? error,
  }) {
    return IPhoneState(
      isLoading: isLoading ?? this.isLoading,
      iphones: iphones ?? this.iphones,
      selectedIPhone: selectedIPhone ?? this.selectedIPhone,
      error: error,
    );
  }
}

// iPhone provider
class IPhoneNotifier extends StateNotifier<IPhoneState> {
  final ApiService _apiService;

  IPhoneNotifier(this._apiService) : super(IPhoneState());

  // Get all active iPhones (for users)
  Future<void> getActiveIPhones() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.get(ApiConfig.iphone);
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

  // Get iPhone by ID
  Future<void> getIPhoneById(int id) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.get(ApiConfig.iphoneById(id));
      if (response.statusCode == 200) {
        final iphone = IPhoneModel.fromJson(
          response.data['data'] ?? response.data,
        );
        state = state.copyWith(isLoading: false, selectedIPhone: iphone);
      }
    } catch (e) {
      final error = _apiService.handleError(e);
      state = state.copyWith(isLoading: false, error: error);
      Fluttertoast.showToast(msg: error);
    }
  }

  // Clear selected iPhone
  void clearSelected() {
    state = state.copyWith(selectedIPhone: null);
  }
}

final iphoneProvider = StateNotifierProvider<IPhoneNotifier, IPhoneState>((
  ref,
) {
  return IPhoneNotifier(ref.watch(apiServiceProvider));
});
