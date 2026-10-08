import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehica_mobile/features/dashboard/domain/entities/dashboard_summary_entity.dart';
import 'package:vehica_mobile/features/dashboard/presentation/widgets/admin_distribution_cards.dart';

void main() {
  group('AdminDistributionSection Widget Tests', () {
    const mockSummary = DashboardSummaryEntity(
      totalUsers: 8,
      activeUsers: 7,
      totalVehicles: 7,
      vehiclesByStatus: {
        'AVAILABLE': 6,
        'RENTED': 1,
        'MAINTENANCE': 0,
        'INACTIVE': 0,
      },
      totalBookings: 3,
      bookingsByStatus: {
        'PENDING': 0,
        'CONFIRMED': 0,
        'PICKED_UP': 1,
        'COMPLETED': 2,
        'CANCELLED': 0,
      },
      totalEstimatedRevenue: 15000000.0,
      topVehicles: [],
    );

    testWidgets('renders all fleet and booking statuses without overflowing on narrow screens', (tester) async {
      // Set narrow viewport (e.g. 360px wide like small phone)
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AdminDistributionSection(summary: mockSummary),
            ),
          ),
        ),
      );

      // Verify Fleet Statuses
      expect(find.text('Phân bổ trạng thái đội xe'), findsOneWidget);
      expect(find.text('Sẵn sàng'), findsOneWidget);
      expect(find.text('Đang cho thuê'), findsOneWidget);
      expect(find.text('Bảo dưỡng'), findsOneWidget);
      expect(find.text('Ngừng hoạt động'), findsOneWidget);

      // Verify Booking Statuses (No PEND.. or CONF.. abbreviations!)
      expect(find.text('Phân bổ trạng thái đơn thuê'), findsOneWidget);
      expect(find.text('Chờ duyệt'), findsOneWidget);
      expect(find.text('Đã xác nhận'), findsOneWidget);
      expect(find.text('Đang thuê'), findsOneWidget);
      expect(find.text('Hoàn thành'), findsOneWidget);
      expect(find.text('Đã hủy'), findsOneWidget);

      // Verify no RenderFlex overflow error was triggered
      expect(tester.takeException(), isNull);
    });
  });
}
