import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/app/providers.dart';
import 'package:vehica_mobile/features/fleet/domain/entities/fleet_schedule_entity.dart';

/// Family provider fetching vehicle schedule for Admin fleet inspection (S08)
final vehicleScheduleFamilyProvider =
    FutureProvider.family<List<VehicleScheduleSlot>, VehicleScheduleQuery>((ref, query) async {
  final repo = ref.watch(vehicleRepositoryProvider);
  final rawList = await repo.getVehicleSchedule(query.vehicleId, query.startDate, query.endDate);
  return rawList.map((e) => VehicleScheduleSlot.fromJson(e)).toList();
});

