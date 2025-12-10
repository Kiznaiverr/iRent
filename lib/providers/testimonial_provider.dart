import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../config/api_config.dart';
import '../models/testimonial_model.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

// Testimonial state
class TestimonialState {
  final bool isLoading;
  final List<TestimonialModel> testimonials;
  final String? error;

  TestimonialState({
    this.isLoading = false,
    this.testimonials = const [],
    this.error,
  });

  TestimonialState copyWith({
    bool? isLoading,
    List<TestimonialModel>? testimonials,
    String? error,
  }) {
    return TestimonialState(
      isLoading: isLoading ?? this.isLoading,
      testimonials: testimonials ?? this.testimonials,
      error: error,
    );
  }
}

// Testimonial provider
class TestimonialNotifier extends StateNotifier<TestimonialState> {
  final ApiService _apiService;

  TestimonialNotifier(this._apiService) : super(TestimonialState());

  // Get all testimonials
  Future<void> getTestimonials() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.get(ApiConfig.testimonial);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        final testimonials = data
            .map((e) => TestimonialModel.fromJson(e))
            .toList();
        state = state.copyWith(isLoading: false, testimonials: testimonials);
      }
    } catch (e) {
      final error = _apiService.handleError(e);
      state = state.copyWith(isLoading: false, error: error);
      Fluttertoast.showToast(msg: error);
    }
  }

  // Create testimonial
  Future<bool> createTestimonial({
    required int rating,
    required String message,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.post(
        ApiConfig.testimonial,
        data: {'rating': rating, 'message': message},
      );

      if (response.statusCode == 201) {
        state = state.copyWith(isLoading: false);
        Fluttertoast.showToast(
          msg: response.data['message'] ?? 'Testimonial berhasil ditambahkan',
        );
        await getTestimonials(); // Refresh list
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

final testimonialProvider =
    StateNotifierProvider<TestimonialNotifier, TestimonialState>((ref) {
      return TestimonialNotifier(ref.watch(apiServiceProvider));
    });
