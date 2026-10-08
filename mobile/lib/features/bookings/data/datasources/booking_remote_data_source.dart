import 'package:vehica_mobile/core/constants/api_endpoints.dart';
import 'package:vehica_mobile/core/network/api_client.dart';
import 'package:vehica_mobile/core/utils/formatters.dart';
import 'package:vehica_mobile/features/bookings/data/models/booking_model.dart';

// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// LAYER             : Data Layer (Remote Data Source)
// USE CASES         : UC-06 (Create Booking), UC-07 (My Bookings & Timeline), UC-10 (Admin Bookings)
// ==============================================================================

class BookingRemoteDataSource {
  final ApiClient apiClient;

  BookingRemoteDataSource({required this.apiClient});

  Future<BookingDetailModel> createBooking({
    required String vehicleId,
    required DateTime startDate,
    required DateTime endDate,
    String? note,
  }) async {
    final response = await apiClient.post(
      ApiEndpoints.bookings,
      data: {
        'vehicleId': vehicleId,
        'startDate': VehicaFormatters.formatApiDate(startDate),
        'endDate': VehicaFormatters.formatApiDate(endDate),
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
    return BookingDetailModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<List<BookingSummaryModel>> getMyBookings({int page = 0, int size = 10}) async {
    final response = await apiClient.get(
      ApiEndpoints.myBookings,
      queryParameters: {'page': page, 'size': size},
    );
    final data = response['data'] as Map<String, dynamic>;
    final list = data['content'] as List;
    return list.map((item) => BookingSummaryModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<BookingDetailModel> getBookingDetail(String bookingId) async {
    final response = await apiClient.get(ApiEndpoints.bookingDetail(bookingId));
    return BookingDetailModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<List<BookingStatusHistoryModel>> getBookingHistory(String bookingId) async {
    final response = await apiClient.get(ApiEndpoints.bookingHistory(bookingId));
    final list = response['data'] as List;
    return list.map((item) => BookingStatusHistoryModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<BookingDetailModel> cancelBooking(String bookingId, {String? reason}) async {
    final response = await apiClient.patch(
      ApiEndpoints.cancelBooking(bookingId),
      data: {if (reason != null) 'reason': reason},
    );
    return BookingDetailModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  // Admin APIs
  Future<List<BookingSummaryModel>> getAdminBookings({
    String? status,
    String? vehicleId,
    String? userId,
    int page = 0,
    int size = 10,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'size': size,
      if (status != null && status.isNotEmpty) 'status': status,
      if (vehicleId != null && vehicleId.isNotEmpty) 'vehicleId': vehicleId,
      if (userId != null && userId.isNotEmpty) 'userId': userId,
    };
    final response = await apiClient.get(ApiEndpoints.adminBookings, queryParameters: query);
    final data = response['data'] as Map<String, dynamic>;
    final list = data['content'] as List;
    return list.map((item) => BookingSummaryModel.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<BookingDetailModel> updateBookingStatusByAdmin({
    required String bookingId,
    required String status,
    String? reason,
  }) async {
    final response = await apiClient.patch(
      ApiEndpoints.adminBookingStatus(bookingId),
      data: {
        'status': status,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );
    return BookingDetailModel.fromJson(response['data'] as Map<String, dynamic>);
  }
}
