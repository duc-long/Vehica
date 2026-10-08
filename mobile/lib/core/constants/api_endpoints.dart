class ApiEndpoints {
  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Profile
  static const String profile = '/me';

  // Vehicles
  static const String vehicles = '/vehicles';
  static const String brands = '/vehicles/brands';
  static const String popularBrands = '/vehicles/brands/popular';
  static String vehicleDetail(String id) => '/vehicles/$id';
  static String vehicleAvailability(String id) => '/vehicles/$id/availability';
  static String vehicleImages(String id) => '/vehicles/$id/images';
  static const String vehicleTypes = '/vehicles/types';

  // Bookings
  static const String bookings = '/bookings';
  static const String myBookings = '/bookings/me';
  static String bookingDetail(String id) => '/bookings/$id';
  static String bookingHistory(String id) => '/bookings/$id/history';
  static String cancelBooking(String id) => '/bookings/$id/cancel';

  // Admin Users
  static const String adminUsers = '/admin/users';
  static String adminUserDetail(String id) => '/admin/users/$id';
  static String adminUserStatus(String id) => '/admin/users/$id/status';
  static String adminDeleteUser(String id) => '/admin/users/$id';

  // Admin Vehicles & Brands
  static const String adminVehicles = '/admin/vehicles';
  static String adminVehicleDetail(String id) => '/admin/vehicles/$id';
  static String adminVehicleStatus(String id) => '/admin/vehicles/$id/status';
  static String adminVehicleSchedule(String id) => '/admin/vehicles/$id/schedule';
  static String adminVehicleImages(String id) => '/admin/vehicles/$id/images';
  static String adminDeleteVehicleImage(String vehicleId, String imageId) => '/admin/vehicles/$vehicleId/images/$imageId';
  static const String adminBrands = '/admin/vehicles/brands';
  static String adminBrandDetail(String id) => '/admin/vehicles/brands/$id';

  // Admin Bookings
  static const String adminBookings = '/admin/bookings';
  static String adminBookingStatus(String id) => '/admin/bookings/$id/status';

  // Admin Statistics
  static const String adminDashboardSummary = '/admin/statistics/summary';
  static const String adminRevenue = '/admin/statistics/revenue';
  static const String adminPopularVehicles = '/admin/statistics/popular-vehicles';

  // Storage & Uploads (Supabase Storage)
  static const String uploadImage = '/storage/upload';
  static const String uploadMultipleImages = '/storage/upload-multiple';
  static String uploadVehicleImage(String vehicleId) => '/admin/vehicles/$vehicleId/images/upload';
  static const String uploadAvatar = '/me/avatar/upload';
  static const String deleteFile = '/storage/delete';
}
