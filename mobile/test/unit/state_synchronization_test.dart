import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehica_mobile/app/providers.dart';
import 'package:vehica_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:vehica_mobile/features/bookings/domain/entities/booking_entity.dart';
import 'package:vehica_mobile/features/bookings/domain/repositories/booking_repository.dart';
import 'package:vehica_mobile/features/bookings/presentation/controllers/booking_controllers.dart';
import 'package:vehica_mobile/features/dashboard/domain/entities/dashboard_summary_entity.dart';
import 'package:vehica_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:vehica_mobile/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:vehica_mobile/features/vehicles/domain/repositories/vehicle_repository.dart';
import 'package:vehica_mobile/features/vehicles/presentation/controllers/vehicle_list_controller.dart';

// Mock Repositories for testing
class MockVehicleRepository implements VehicleRepository {
  int getVehiclesCallCount = 0;
  String? lastStatus;

  @override
  Future<List<VehicleEntity>> getVehicles({
    String? keyword,
    String? typeId,
    int? seatCapacity,
    double? minPrice,
    double? maxPrice,
    String? status,
    int page = 0,
    int size = 20,
  }) async {
    getVehiclesCallCount++;
    lastStatus = status;
    return [];
  }

  @override
  Future<VehicleEntity> getVehicleDetail(String vehicleId) async {
    throw UnimplementedError();
  }

  @override
  Future<AvailabilityEntity> checkAvailability({
    required String vehicleId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<VehicleTypeEntity>> getVehicleTypes() async => [];

  @override
  Future<List<BrandEntity>> getBrands() async => [];

  @override
  Future<List<BrandEntity>> getPopularBrands() async => [];

  @override
  Future<VehicleEntity> updateVehicleStatus(String vehicleId, String status) async {
    return VehicleEntity(
      id: vehicleId,
      name: 'Test Car',
      brand: 'Test',
      model: 'T1',
      licensePlate: '51A-12345',
      year: 2024,
      pricePerDay: 500000,
      status: status,
      type: const VehicleTypeEntity(id: 't1', name: 'Sedan'),
      images: [],
    );
  }

  @override
  Future<VehicleEntity> createVehicle(Map<String, dynamic> data) async => throw UnimplementedError();

  @override
  Future<VehicleEntity> updateVehicle(String id, Map<String, dynamic> data) async => throw UnimplementedError();

  @override
  Future<void> deleteVehicle(String id) async {}

  @override
  Future<void> addVehicleImage(String vehicleId, String imageUrl, bool isPrimary) async {}

  @override
  Future<void> deleteVehicleImage(String vehicleId, String imageId) async {}

  @override
  Future<List<Map<String, dynamic>>> getVehicleSchedule(String vehicleId, DateTime startDate, DateTime endDate) async => [];
}

class MockBookingRepository implements BookingRepository {
  int cancelCallCount = 0;
  int updateStatusCallCount = 0;
  int getMyBookingsCallCount = 0;
  int getAdminBookingsCallCount = 0;

  @override
  Future<List<BookingSummaryEntity>> getMyBookings({int page = 0, int size = 10}) async {
    getMyBookingsCallCount++;
    return [];
  }

  @override
  Future<List<BookingSummaryEntity>> getAdminBookings({
    String? status,
    String? vehicleId,
    String? userId,
    int page = 0,
    int size = 10,
  }) async {
    getAdminBookingsCallCount++;
    return [];
  }

  @override
  Future<BookingDetailEntity> createBooking({
    required String vehicleId,
    required DateTime startDate,
    required DateTime endDate,
    String? note,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<BookingDetailEntity> getBookingDetail(String bookingId) async {
    return BookingDetailEntity(
      id: bookingId,
      bookingCode: 'BKG-$bookingId',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 2)),
      rentalDays: 2,
      pricePerDay: 500000,
      totalAmount: 1000000,
      status: 'CANCELLED',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      vehicle: const VehicleEntity(
        id: 'v1',
        name: 'Sedan A',
        brand: 'Test',
        model: 'A1',
        licensePlate: '51A-11111',
        year: 2024,
        pricePerDay: 500000,
        status: 'AVAILABLE',
        type: VehicleTypeEntity(id: 't1', name: 'Sedan'),
      ),
      customer: const UserEntity(id: 'u1', fullName: 'User A', email: 'user@test.com', phone: '0901234567', role: 'CUSTOMER', status: 'ACTIVE'),
    );
  }

  @override
  Future<List<BookingStatusHistoryEntity>> getBookingHistory(String bookingId) async => [];

  @override
  Future<BookingDetailEntity> cancelBooking(String bookingId, {String? reason}) async {
    cancelCallCount++;
    return getBookingDetail(bookingId);
  }

  @override
  Future<BookingDetailEntity> updateBookingStatusByAdmin({
    required String bookingId,
    required String status,
    String? reason,
  }) async {
    updateStatusCallCount++;
    return getBookingDetail(bookingId);
  }
}

class MockDashboardRepository implements DashboardRepository {
  int getSummaryCallCount = 0;

  @override
  Future<DashboardSummaryEntity> getDashboardSummary() async {
    getSummaryCallCount++;
    return const DashboardSummaryEntity(
      totalUsers: 20,
      activeUsers: 18,
      totalVehicles: 10,
      vehiclesByStatus: {'AVAILABLE': 8, 'RENTED': 2},
      totalBookings: 15,
      bookingsByStatus: {'CONFIRMED': 5, 'COMPLETED': 10},
      totalEstimatedRevenue: 50000000,
      topVehicles: [],
    );
  }

  @override
  Future<Map<String, dynamic>> getRevenue(DateTime? startDate, DateTime? endDate) async => {};
}

void main() {
  group('Riverpod Reactive State Invalidation & Synchronization Tests', () {
    late ProviderContainer container;
    late MockVehicleRepository mockVehicleRepo;
    late MockBookingRepository mockBookingRepo;
    late MockDashboardRepository mockDashboardRepo;

    setUp(() {
      mockVehicleRepo = MockVehicleRepository();
      mockBookingRepo = MockBookingRepository();
      mockDashboardRepo = MockDashboardRepository();

      container = ProviderContainer(
        overrides: [
          vehicleRepositoryProvider.overrideWithValue(mockVehicleRepo),
          bookingRepositoryProvider.overrideWithValue(mockBookingRepo),
          dashboardRepositoryProvider.overrideWithValue(mockDashboardRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    /// Tests reactive state reload on catalog filter and search changes (UC-04, BR-04).
    test('VehicleListController reloads reactively on filter changes', () async {
      // Initialize controller
      final controller = container.read(vehicleListControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      expect(mockVehicleRepo.getVehiclesCallCount, 1);

      // Search keyword triggers immediate reload
      controller.search('VinFast');
      await Future<void>.delayed(Duration.zero);
      expect(mockVehicleRepo.getVehiclesCallCount, 2);
      expect(container.read(vehicleListControllerProvider).filter.keyword, 'VinFast');

      // Category filter triggers immediate reload
      controller.setTypeFilter('type-sedan');
      await Future<void>.delayed(Duration.zero);
      expect(mockVehicleRepo.getVehiclesCallCount, 3);
      expect(container.read(vehicleListControllerProvider).filter.typeId, 'type-sedan');
    });

    test('AdminBookingsController auto-reloads on status filter change', () async {
      final controller = container.read(adminBookingsControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);

      expect(mockBookingRepo.getAdminBookingsCallCount, 1);

      controller.filterByStatus('CONFIRMED');
      await Future<void>.delayed(Duration.zero);
      expect(mockBookingRepo.getAdminBookingsCallCount, 2);
      expect(container.read(adminBookingsControllerProvider).statusFilter, 'CONFIRMED');
    });

    test('AdminVehicleController.updateStatus triggers automatic multi-provider invalidation', () async {
      final sub = container.listen(adminDashboardSummaryProvider, (_, __) {});
      final adminVehicleController = container.read(adminVehicleControllerProvider);
      
      // Read initial dashboard
      container.read(adminDashboardSummaryProvider);
      await Future<void>.delayed(Duration.zero);
      expect(mockDashboardRepo.getSummaryCallCount, 1);

      // Perform mutation
      final success = await adminVehicleController.updateStatus('v-101', 'MAINTENANCE');
      expect(success, isTrue);

      // Re-read dashboard - auto invalidated and fetched fresh
      container.read(adminDashboardSummaryProvider);
      await Future<void>.delayed(Duration.zero);
      expect(mockDashboardRepo.getSummaryCallCount, 2);
      sub.close();
    });

    test('Booking cancellation invalidates dependent list and dashboard providers', () async {
      final sub = container.listen(adminDashboardSummaryProvider, (_, __) {});
      final myBookings = container.read(myBookingsControllerProvider.notifier);
      await Future<void>.delayed(Duration.zero);
      expect(mockBookingRepo.getMyBookingsCallCount, 1);

      // Read dashboard
      container.read(adminDashboardSummaryProvider);
      await Future<void>.delayed(Duration.zero);
      expect(mockDashboardRepo.getSummaryCallCount, 1);

      // Cancel booking
      await myBookings.cancelBooking('b-99', reason: 'Customer cancellation');
      await Future<void>.delayed(Duration.zero);

      expect(mockBookingRepo.cancelCallCount, 1);
      // Automatically re-fetched my bookings
      expect(mockBookingRepo.getMyBookingsCallCount, 2);

      // Dashboard was invalidated
      container.read(adminDashboardSummaryProvider);
      await Future<void>.delayed(Duration.zero);
      expect(mockDashboardRepo.getSummaryCallCount, 2);
      sub.close();
    });
  });
}
