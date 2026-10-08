// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// LAYER             : Presentation Layer (StateNotifier Family Provider)
// USE CASES         : UC-05 - Vehicle Details & Availability Check
// BUSINESS RULES    : BR-04, BR-07, BR-08 (30m slot), BR-09 (1h buffer), BR-10 (Overlap check)
// ------------------------------------------------------------------------------
// DATA FLOW:
// UI (VehicleDetailPage S04)
//   --> VehicleDetailController (StateNotifier)
//   --> VehicleRepository
//   --> VehicleRemoteDataSource
//   --> Spring Boot REST API (/api/vehicles/:id & /api/vehicles/:id/availability)
// ==============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/app/providers.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:vehica_mobile/features/vehicles/domain/repositories/vehicle_repository.dart';

/// Vehicle details state and availability check results
class VehicleDetailState {
  final VehicleEntity vehicle;
  final AvailabilityEntity? availability;
  final bool isCheckingAvailability;
  final String? availabilityError;

  const VehicleDetailState({
    required this.vehicle,
    this.availability,
    this.isCheckingAvailability = false,
    this.availabilityError,
  });

  VehicleDetailState copyWith({
    VehicleEntity? vehicle,
    AvailabilityEntity? availability,
    bool? isCheckingAvailability,
    String? availabilityError,
  }) {
    return VehicleDetailState(
      vehicle: vehicle ?? this.vehicle,
      availability: availability ?? this.availability,
      isCheckingAvailability: isCheckingAvailability ?? this.isCheckingAvailability,
      availabilityError: availabilityError,
    );
  }
}

/// Controller managing vehicle details view and availability check (S04)
class VehicleDetailController extends StateNotifier<AsyncValue<VehicleDetailState>> {
  final VehicleRepository repository;
  final String vehicleId;

  VehicleDetailController({
    required this.repository,
    required this.vehicleId,
  }) : super(const AsyncValue.loading()) {
    loadDetail();
  }

  /// Load vehicle details (UC-05)
  /// Flow: GET /api/vehicles/:id -> Update State
  Future<void> loadDetail() async {
    state = const AsyncValue.loading();
    try {
      final vehicle = await repository.getVehicleDetail(vehicleId);
      if (!mounted) return;
      state = AsyncValue.data(VehicleDetailState(vehicle: vehicle));
    } catch (e, st) {
      if (!mounted) return;
      state = AsyncValue.error(e.toString().replaceAll('Exception: ', '').replaceAll('ServerException: ', ''), st);
    }
  }

  /// Check vehicle availability by pickup-dropoff date range (UC-05, BR-08, BR-09, BR-10)
  /// Flow: GET /api/vehicles/:id/availability?startDate=...&endDate=... -> Returns AvailabilityEntity (isAvailable, reason)
  Future<void> checkAvailability(DateTime startDate, DateTime endDate) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncValue.data(current.copyWith(isCheckingAvailability: true, availabilityError: null));

    try {
      final availability = await repository.checkAvailability(
        vehicleId: vehicleId,
        startDate: startDate,
        endDate: endDate,
      );
      if (!mounted) return;
      state = AsyncValue.data(current.copyWith(
        availability: availability,
        isCheckingAvailability: false,
      ));
    } catch (e) {
      if (!mounted) return;
      state = AsyncValue.data(current.copyWith(
        isCheckingAvailability: false,
        availabilityError: e.toString().replaceAll('Exception: ', '').replaceAll('ServerException: ', ''),
      ));
    }
  }
}

final vehicleDetailControllerProvider = StateNotifierProvider.family<
    VehicleDetailController, AsyncValue<VehicleDetailState>, String>((ref, vehicleId) {
  final repo = ref.watch(vehicleRepositoryProvider);
  return VehicleDetailController(repository: repo, vehicleId: vehicleId);
});
