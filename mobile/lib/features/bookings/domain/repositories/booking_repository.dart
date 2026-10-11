import 'package:vehica_mobile/features/bookings/domain/entities/booking_entity.dart';

abstract class BookingRepository {
  Future<BookingDetailEntity> createBooking({
    required String vehicleId,
    required DateTime startDate,
    required DateTime endDate,
    String? note,
  });

  Future<List<BookingSummaryEntity>> getMyBookings({int page = 0, int size = 10});

  Future<BookingDetailEntity> getBookingDetail(String bookingId);

  Future<List<BookingStatusHistoryEntity>> getBookingHistory(String bookingId);

  Future<BookingDetailEntity> cancelBooking(String bookingId, {String? reason});

  // Admin APIs
  Future<List<BookingSummaryEntity>> getAdminBookings({
    String? status,
    String? vehicleId,
    String? userId,
    int page = 0,
    int size = 10,
  });

  Future<BookingDetailEntity> updateBookingStatusByAdmin({
    required String bookingId,
    required String status,
    String? reason,
  });
}
