import 'package:vehica_mobile/features/bookings/data/datasources/booking_remote_data_source.dart';
import 'package:vehica_mobile/features/bookings/domain/entities/booking_entity.dart';
import 'package:vehica_mobile/features/bookings/domain/repositories/booking_repository.dart';

// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// LAYER             : Data Layer (Repository Implementation)
// USE CASES         : UC-06 (Create Booking), UC-07 (My Bookings & Timeline), UC-10 (Admin Bookings)
// ==============================================================================

class BookingRepositoryImpl implements BookingRepository {
  final BookingRemoteDataSource remoteDataSource;

  BookingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<BookingDetailEntity> createBooking({
    required String vehicleId,
    required DateTime startDate,
    required DateTime endDate,
    String? note,
  }) async {
    return await remoteDataSource.createBooking(
      vehicleId: vehicleId,
      startDate: startDate,
      endDate: endDate,
      note: note,
    );
  }

  @override
  Future<List<BookingSummaryEntity>> getMyBookings({int page = 0, int size = 10}) async {
    return await remoteDataSource.getMyBookings(page: page, size: size);
  }

  @override
  Future<BookingDetailEntity> getBookingDetail(String bookingId) async {
    return await remoteDataSource.getBookingDetail(bookingId);
  }

  @override
  Future<List<BookingStatusHistoryEntity>> getBookingHistory(String bookingId) async {
    return await remoteDataSource.getBookingHistory(bookingId);
  }

  @override
  Future<BookingDetailEntity> cancelBooking(String bookingId, {String? reason}) async {
    return await remoteDataSource.cancelBooking(bookingId, reason: reason);
  }

  @override
  Future<List<BookingSummaryEntity>> getAdminBookings({
    String? status,
    String? vehicleId,
    String? userId,
    int page = 0,
    int size = 10,
  }) async {
    return await remoteDataSource.getAdminBookings(
      status: status,
      vehicleId: vehicleId,
      userId: userId,
      page: page,
      size: size,
    );
  }

  @override
  Future<BookingDetailEntity> updateBookingStatusByAdmin({
    required String bookingId,
    required String status,
    String? reason,
  }) async {
    return await remoteDataSource.updateBookingStatusByAdmin(
      bookingId: bookingId,
      status: status,
      reason: reason,
    );
  }
}
