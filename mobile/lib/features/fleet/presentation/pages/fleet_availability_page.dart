import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_back_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_date_range_picker.dart';
import 'package:vehica_mobile/core/widgets/vehica_skeleton.dart';
import 'package:vehica_mobile/features/fleet/presentation/widgets/fleet_vehicle_tile.dart';
import 'package:vehica_mobile/features/vehicles/presentation/controllers/vehicle_list_controller.dart';

/// Fleet Availability & Schedule Screen (S08)
/// Architecture: Clean coordinator page for Fleet schedule and status inspection.
class FleetAvailabilityPage extends ConsumerStatefulWidget {
  const FleetAvailabilityPage({super.key});

  @override
  ConsumerState<FleetAvailabilityPage> createState() => _FleetAvailabilityPageState();
}

class _FleetAvailabilityPageState extends ConsumerState<FleetAvailabilityPage> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 3));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vehicleListState = ref.watch(vehicleListControllerProvider);
    final vehiclesState = vehicleListState.vehicles;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: const VehicaBackButton(),
        title: const Text('Lịch đội xe & Tính khả dụng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                ref.read(vehicleListControllerProvider.notifier).loadVehicles(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Date Range Filter Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: VehicaDateRangePicker(
                startDate: _startDate,
                endDate: _endDate,
                onDateRangeSelected: (start, end) {
                  setState(() {
                    _startDate = start;
                    _endDate = end;
                  });
                },
              ),
            ),

            // Fleet List
            Expanded(
              child: vehiclesState.when(
                data: (vehicles) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  physics: const BouncingScrollPhysics(),
                  itemCount: vehicles.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final vehicle = vehicles[index];
                    return FleetVehicleTile(
                      vehicle: vehicle,
                      isDark: isDark,
                    );
                  },
                ),
                loading: () => ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, __) => const VehicaSkeleton(height: 72),
                ),
                error: (err, _) => Center(child: Text('Lỗi: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
