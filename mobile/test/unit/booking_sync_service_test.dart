import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehica_mobile/app/providers.dart';
import 'package:vehica_mobile/core/services/booking_sync_service.dart';
import 'package:vehica_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:vehica_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:vehica_mobile/features/bookings/domain/entities/booking_entity.dart';
import 'package:vehica_mobile/features/bookings/domain/repositories/booking_repository.dart';

class MockBookingRepository implements BookingRepository {
  List<BookingSummaryEntity> adminBookingsToReturn = [];
  List<BookingSummaryEntity> myBookingsToReturn = [];

  @override
  Future<List<BookingSummaryEntity>> getAdminBookings({
    String? status,
    String? vehicleId,
    String? userId,
    int page = 0,
    int size = 10,
  }) async {
    return adminBookingsToReturn;
  }

  @override
  Future<List<BookingSummaryEntity>> getMyBookings({int page = 0, int size = 10}) async {
    return myBookingsToReturn;
  }

  @override
  Future<BookingDetailEntity> cancelBooking(String bookingId, {String? reason}) {
    throw UnimplementedError();
  }

  @override
  Future<BookingDetailEntity> createBooking({
    required String vehicleId,
    required DateTime startDate,
    required DateTime endDate,
    String? note,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<BookingDetailEntity> getBookingDetail(String bookingId) {
    throw UnimplementedError();
  }

  @override
  Future<List<BookingStatusHistoryEntity>> getBookingHistory(String bookingId) {
    throw UnimplementedError();
  }

  @override
  Future<BookingDetailEntity> updateBookingStatusByAdmin({
    required String bookingId,
    required String status,
    String? reason,
  }) {
    throw UnimplementedError();
  }
}

class MockAuthRepository implements AuthRepository {
  final UserEntity? currentUser;
  MockAuthRepository({this.currentUser});

  @override
  Future<UserEntity?> getCurrentUser() async => currentUser;

  @override
  Future<UserEntity> login({required String email, required String password}) async =>
      currentUser!;

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async =>
      currentUser!;

  @override
  Future<UserEntity> updateProfile({
    required String fullName,
    required String phone,
    String? avatarUrl,
  }) async =>
      currentUser!;

  @override
  Future<void> logout() async {}

  @override
  Future<Map<String, dynamic>> forgotPassword(String email) async => {};

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {}
}

void main() {
  group('BookingSyncService Unit Tests', () {
    late MockBookingRepository mockBookingRepo;
    late MockAuthRepository mockAuthRepo;
    late ProviderContainer container;

    setUp(() {
      mockBookingRepo = MockBookingRepository();
      mockAuthRepo = MockAuthRepository(
        currentUser: const UserEntity(
          id: 'usr-admin-1',
          email: 'admin@vehica.com',
          fullName: 'Admin User',
          phone: '0901234567',
          role: 'ADMIN',
          status: 'ACTIVE',
        ),
      );
      container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(mockBookingRepo),
          authRepositoryProvider.overrideWithValue(mockAuthRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('BookingSyncService initializes and does not crash on empty bookings', () async {
      final syncService = container.read(bookingSyncServiceProvider);
      expect(syncService, isNotNull);
      await Future.delayed(const Duration(milliseconds: 50));
      syncService.dispose();
    });
  });
}
