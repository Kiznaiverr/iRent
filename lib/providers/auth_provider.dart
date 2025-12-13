import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

// Auth state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }
}

// Auth provider
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final StorageService _storageService;

  AuthNotifier(this._apiService, this._storageService)
    : super(AuthState(isLoading: true)) {
    checkAuth();
  }

  // Check if user is authenticated
  Future<void> checkAuth() async {
    try {
      final isLoggedIn = await _storageService.isLoggedIn();

      if (isLoggedIn) {
        // Set authenticated first
        state = state.copyWith(isAuthenticated: true, isLoading: false);

        // Then load profile
        await getProfile();
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      await _storageService.clearAll();
      state = AuthState();
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String username,
    required String password,
    required String phone,
    required String nik,
    String? email,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.post(
        ApiConfig.register,
        data: {
          'name': name,
          'username': username,
          'password': password,
          'phone': phone,
          'nik': nik,
          if (email != null && email.isNotEmpty) 'email': email,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = response.data;
        // Consider registration successful if status is 200/201 (data is saved)
        state = state.copyWith(isLoading: false);
        Fluttertoast.showToast(
          msg: responseData?['message'] ?? 'Registrasi berhasil',
        );
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

  // Login
  Future<String?> login({
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final token = data['token'];
        final user = UserModel.fromJson(data['user']);

        await _storageService.saveToken(token);
        await _storageService.saveUserId(user.id);
        await _storageService.saveUserRole(user.role);
        await _storageService.saveUsername(user.username);

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );

        Fluttertoast.showToast(msg: 'Login berhasil');
        return null; // null means success
      }
      state = state.copyWith(isLoading: false);
      return 'Login gagal'; // Generic error message
    } catch (e) {
      final error = _apiService.handleError(e);
      state = state.copyWith(isLoading: false, error: error);
      // Don't show toast here, let the UI handle it
      return error;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _apiService.post(ApiConfig.logout);
    } catch (e) {
      // Ignore error
    } finally {
      await _storageService.clearAll();
      state = AuthState();
      Fluttertoast.showToast(msg: 'Logout berhasil');
    }
  }

  // Get profile
  Future<void> getProfile() async {
    try {
      final response = await _apiService.get(ApiConfig.userProfile);
      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data['data'] ?? response.data);
        state = state.copyWith(user: user);
      }
    } catch (e) {
      // Don't clear auth state on profile fetch failure
      // User stays logged in even if profile can't be fetched
    }
  }

  // Update profile
  Future<bool> updateProfile({
    String? name,
    String? username,
    String? email,
    String? phone,
    String? nik,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.put(
        ApiConfig.userUpdateProfile,
        data: {
          if (name != null) 'name': name,
          if (username != null) 'username': username,
          if (email != null) 'email': email,
          if (phone != null) 'phone': phone,
          if (nik != null) 'nik': nik,
        },
      );

      if (response.statusCode == 200) {
        await getProfile();
        state = state.copyWith(isLoading: false);
        Fluttertoast.showToast(msg: 'Profil berhasil diperbarui');
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

  // Upload profile photo
  Future<bool> uploadProfilePhoto(String filePath) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.uploadFile(
        ApiConfig.uploadProfilePhoto,
        filePath,
        'profile_photo',
      );

      if (response.statusCode == 200) {
        await getProfile();
        state = state.copyWith(isLoading: false);
        Fluttertoast.showToast(msg: 'Foto profil berhasil diperbarui');
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

  // Send verification code
  Future<bool> sendVerificationCode() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.post(ApiConfig.sendVerificationCode);
      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        Fluttertoast.showToast(
          msg: response.data['message'] ?? 'Kode verifikasi telah dikirim',
        );
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

  // Verify code
  Future<bool> verifyCode(String code) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.post(
        ApiConfig.verifyCode,
        data: {'code': code},
      );
      if (response.statusCode == 200) {
        await getProfile();
        state = state.copyWith(isLoading: false);
        Fluttertoast.showToast(msg: 'Verifikasi berhasil');
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

  // Forgot password
  Future<bool> forgotPassword(String username) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.post(
        ApiConfig.forgotPassword,
        data: {'username': username},
      );
      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        Fluttertoast.showToast(
          msg: response.data['message'] ?? 'Kode reset telah dikirim',
        );
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

  // Reset password
  Future<bool> resetPassword({
    required String username,
    required String code,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiService.post(
        ApiConfig.resetPassword,
        data: {'username': username, 'code': code, 'password': password},
      );
      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        Fluttertoast.showToast(msg: 'Password berhasil direset');
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

// Providers
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());
final storageServiceProvider = Provider<StorageService>(
  (ref) => StorageService(),
);

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(apiServiceProvider),
    ref.watch(storageServiceProvider),
  );
});
