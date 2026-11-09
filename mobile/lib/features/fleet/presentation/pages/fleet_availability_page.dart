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
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _statusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vehiclesState = ref.watch(adminVehiclesListProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        leading: const VehicaBackButton(),
        title: const Text('Lịch đội xe & Tính khả dụng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(adminVehiclesListProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(adminVehiclesListProvider);
          },
          child: Column(
            children: [
              // ── Date Range Filter Card ──────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
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

              // ── Search & Filter Box ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tên xe, hãng, biển số...',
                      hintStyle: const TextStyle(color: AppColors.textDisabled, fontSize: 13),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close_rounded, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),

              // ── Status Filter Chips Bar ─────────────────────────────────────
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFilterChip('Tất cả', null, isDark),
                    _buildFilterChip('Sẵn sàng', 'AVAILABLE', isDark),
                    _buildFilterChip('Đang thuê', 'RENTED', isDark),
                    _buildFilterChip('Bảo dưỡng', 'MAINTENANCE', isDark),
                    _buildFilterChip('Ngừng HĐ', 'INACTIVE', isDark),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // ── Fleet List ──────────────────────────────────────────────────
              Expanded(
                child: vehiclesState.when(
                  data: (vehicles) {
                    final filtered = vehicles.where((v) {
                      final matchSearch = _searchQuery.isEmpty ||
                          v.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          v.brand.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                          v.licensePlate.toLowerCase().contains(_searchQuery.toLowerCase());
                      final matchStatus = _statusFilter == null || v.status == _statusFilter;
                      return matchSearch && matchStatus;
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off_rounded,
                                size: 48,
                                color: isDark ? AppColors.textDisabledDark : AppColors.textDisabled,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Không tìm thấy xe nào trong đội xe',
                                style: TextStyle(
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final vehicle = filtered[index];
                        return FleetVehicleTile(
                          vehicle: vehicle,
                          startDate: _startDate,
                          endDate: _endDate,
                          isDark: isDark,
                        );
                      },
                    );
                  },
                  loading: () => ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: 4,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, __) => const VehicaSkeleton(height: 90),
                  ),
                  error: (err, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.error),
                          const SizedBox(height: 10),
                          Text('Lỗi tải danh sách đội xe: $err', textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => ref.invalidate(adminVehiclesListProvider),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String? status, bool isDark) {
    final isSelected = _statusFilter == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _statusFilter = status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
