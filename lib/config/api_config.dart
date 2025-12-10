class ApiConfig {
  static const String baseUrl = 'https://backend.nekoyama.my.id';

  // Auth endpoints
  static const String register = '/api/auth/register';
  static const String login = '/api/auth/login';
  static const String logout = '/api/auth/logout';
  static const String sendVerificationCode = '/api/auth/send-verification-code';
  static const String verifyCode = '/api/auth/verify-code';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resetPassword = '/api/auth/reset-password';

  // User endpoints
  static const String userProfile = '/api/user/profile';
  static const String uploadProfilePhoto = '/api/user/upload-profile-photo';

  // iPhone endpoints
  static const String iphone = '/api/iphone';
  static String iphoneById(int id) => '/api/iphone/$id';

  // Order endpoints
  static const String order = '/api/order';
  static const String userOrders = '/api/order/user';
  static String trackOrder(String code) => '/api/order/track/$code';

  // Rental endpoints
  static const String userRentals = '/api/rental/user';

  // Testimonial endpoints
  static const String testimonial = '/api/testimonial';

  // Admin endpoints
  static const String adminUsers = '/api/admin/user';
  static String adminUserById(int id) => '/api/admin/user/$id';
  static String adminUserSoftDelete(int id) =>
      '/api/admin/user/$id/soft-delete';

  static const String adminIphones = '/api/admin/iphone';
  static const String adminAllIphones = '/api/admin/iphone/all';
  static String adminIphoneById(int id) => '/api/admin/iphone/$id';
  static String adminIphoneStock(int id) => '/api/admin/iphone/$id/stock';

  static const String adminOrders = '/api/admin/order';
  static String adminOrderStatus(int id) => '/api/admin/order/$id/status';

  static const String adminRentals = '/api/admin/rental';
  static const String adminOverdueRentals = '/api/admin/rental/overdue';
  static String adminRentalById(int id) => '/api/admin/rental/$id';
  static String adminReturnRental(int id) => '/api/admin/rental/$id/return';

  static String adminDeleteTestimonial(int id) => '/api/admin/testimonial/$id';
}
