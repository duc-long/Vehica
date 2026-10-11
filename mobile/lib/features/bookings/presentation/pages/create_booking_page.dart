// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// SCREEN       : S05 - Create Booking Screen (Multi-Step Flow)
// STYLE        : Dark Slate Luxury, Emerald Teal Accent
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vehica_mobile/app/providers.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/widgets/vehica_back_button.dart';
import 'package:vehica_mobile/features/bookings/presentation/controllers/booking_controllers.dart';
import 'package:vehica_mobile/features/bookings/presentation/widgets/booking_date_step.dart';
import 'package:vehica_mobile/features/bookings/presentation/widgets/booking_review_step.dart';
import 'package:vehica_mobile/features/bookings/presentation/widgets/booking_step_progress_bar.dart';
import 'package:vehica_mobile/features/bookings/presentation/widgets/booking_success_step.dart';
import 'package:vehica_mobile/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:vehica_mobile/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:vehica_mobile/features/vehicles/presentation/controllers/vehicle_detail_controller.dart';
import 'package:vehica_mobile/features/vehicles/presentation/controllers/vehicle_list_controller.dart';

class CreateBookingPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> extraData;

  const CreateBookingPage({super.key, required this.extraData});

  @override
  ConsumerState<CreateBookingPage> createState() => _CreateBookingPageState();
}

class _CreateBookingPageState extends ConsumerState<CreateBookingPage> {
  final _noteController = TextEditingController();
  late final TextEditingController _startDateController;
  late final TextEditingController _endDateController;
  bool _isSubmitting = false;

  late VehicleEntity _vehicle;
  late DateTime _startDate;
  late DateTime _endDate;

  int _currentStep = 0; // 0: Dates, 1: Review, 2: Success
  String? _createdBookingId;
  String? _createdBookingCode;

  @override
  void initState() {
    super.initState();
    _vehicle = widget.extraData['vehicle'] as VehicleEntity;
    _startDate = widget.extraData['startDate'] as DateTime? ??
        DateTime.now().add(const Duration(days: 1));
    _endDate = widget.extraData['endDate'] as DateTime? ??
        DateTime.now().add(const Duration(days: 4));
    _startDateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(_startDate),
    );
    _endDateController = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(_endDate),
    );
  }

  @override
  void dispose() {
    _noteController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  int get _rentalDays {
    final diff = _endDate.difference(_startDate).inDays;
    return diff > 0 ? diff : 1;
  }

  double get _vehicleCost => _vehicle.pricePerDay * _rentalDays;

  double get _totalAmount => _vehicleCost;

  DateTime? _tryParseDate(String input) {
    final clean = input.trim();
    final parts = clean.split(RegExp(r'[/.-]'));
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      var year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        if (year < 100) year += 2000;
        if (month >= 1 && month <= 12 && day >= 1 && day <= 31 && year >= 2024 && year <= 2035) {
          try {
            return DateTime(year, month, day);
          } catch (_) {}
        }
      }
    }
    return null;
  }

  void _onStartDateChanged(String val) {
    final parsed = _tryParseDate(val);
    if (parsed != null) {
      setState(() {
        _startDate = parsed;
        if (!_endDate.isAfter(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 1));
          _endDateController.text = DateFormat('dd/MM/yyyy').format(_endDate);
        }
      });
    }
  }

  void _onEndDateChanged(String val) {
    final parsed = _tryParseDate(val);
    if (parsed != null) {
      setState(() {
        _endDate = parsed;
      });
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate.isBefore(now) ? now : _startDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
      confirmText: 'Chọn',
      cancelText: 'Hủy',
      helpText: 'CHỌN NGÀY BẮT ĐẦU',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
                onPrimary: Colors.white,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        _startDateController.text = DateFormat('dd/MM/yyyy').format(picked);
        if (!_endDate.isAfter(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 1));
          _endDateController.text = DateFormat('dd/MM/yyyy').format(_endDate);
        }
      });
    }
  }

  Future<void> _pickEndDate() async {
    final minDate = _startDate.add(const Duration(days: 1));
    final initial = _endDate.isAfter(_startDate) ? _endDate : minDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: minDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      confirmText: 'Chọn',
      cancelText: 'Hủy',
      helpText: 'CHỌN NGÀY KẾT THÚC',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
                onPrimary: Colors.white,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
        _endDateController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);

    try {
      final bookingRepo = ref.read(bookingRepositoryProvider);
      final note = _noteController.text.trim().isNotEmpty
          ? _noteController.text.trim()
          : null;

      final booking = await bookingRepo.createBooking(
        vehicleId: _vehicle.id,
        startDate: _startDate,
        endDate: _endDate,
        note: note,
      );

      ref.invalidate(myBookingsControllerProvider);
      ref.invalidate(adminBookingsControllerProvider);
      ref.invalidate(adminDashboardSummaryProvider);
      ref.invalidate(vehicleListControllerProvider);
      ref.invalidate(vehicleDetailControllerProvider(_vehicle.id));

      if (mounted) {
        setState(() {
          _createdBookingId = booking.id;
          _createdBookingCode = booking.bookingCode;
          _currentStep = 2;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tạo đơn đặt xe: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentStep == 1) {
          setState(() => _currentStep = 0);
        } else if (!didPop && _currentStep == 2) {
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          title: Text(
            _currentStep == 0
                ? 'Chọn ngày thuê'
                : (_currentStep == 1 ? 'Xem lại & Xác nhận' : 'Đặt xe thành công'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          leading: _currentStep == 1
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => setState(() => _currentStep = 0),
                )
              : (_currentStep == 2
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => context.go('/home'),
                    )
                  : const VehicaBackButton()),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // ── Step Progress Indicator ──────────────────────────────────
              BookingStepProgressBar(
                currentStep: _currentStep,
                isDark: isDark,
              ),

              // ── Body Step Content ─────────────────────────────────────────
              Expanded(
                child: _currentStep == 0
                    ? BookingDateStep(
                        vehicle: _vehicle,
                        startDateController: _startDateController,
                        endDateController: _endDateController,
                        rentalDays: _rentalDays,
                        onStartDateChanged: _onStartDateChanged,
                        onEndDateChanged: _onEndDateChanged,
                        onPickStartDate: _pickStartDate,
                        onPickEndDate: _pickEndDate,
                        isDark: isDark,
                      )
                    : (_currentStep == 1
                        ? BookingReviewStep(
                            vehicle: _vehicle,
                            startDate: _startDate,
                            endDate: _endDate,
                            rentalDays: _rentalDays,
                            vehicleCost: _vehicleCost,
                            totalAmount: _totalAmount,
                            noteController: _noteController,
                            isDark: isDark,
                          )
                        : BookingSuccessStep(
                            createdBookingId: _createdBookingId,
                            createdBookingCode: _createdBookingCode,
                            vehicle: _vehicle,
                            startDate: _startDate,
                            endDate: _endDate,
                            rentalDays: _rentalDays,
                            totalAmount: _totalAmount,
                            isDark: isDark,
                          )),
              ),

              // ── Bottom Navigation / CTA Bar ───────────────────────────────
              if (_currentStep == 0)
                BookingStep1BottomBar(
                  rentalDays: _rentalDays,
                  totalAmount: _totalAmount,
                  isDark: isDark,
                  onNext: () {
                    if (!_endDate.isAfter(_startDate)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ngày kết thúc phải sau ngày bắt đầu ít nhất 1 ngày'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                      return;
                    }
                    setState(() => _currentStep = 1);
                  },
                ),
              if (_currentStep == 1)
                BookingStep2BottomBar(
                  isSubmitting: _isSubmitting,
                  isDark: isDark,
                  onBack: () => setState(() => _currentStep = 0),
                  onSubmit: _isSubmitting ? () {} : _handleSubmit,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
