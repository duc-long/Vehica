import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehica_mobile/features/bookings/domain/entities/booking_entity.dart';
import 'package:vehica_mobile/features/bookings/presentation/widgets/admin_booking_card.dart';

void main() {
  group('AdminBookingCard Responsive Tests', () {
    final mockBooking = BookingSummaryEntity(
      id: 'b-1003',
      bookingCode: 'VHC-20261002-1003',
      status: 'PICKED_UP',
      startDate: DateTime(2026, 10, 15),
      endDate: DateTime(2026, 10, 17),
      rentalDays: 2,
      pricePerDay: 2800000.0,
      totalAmount: 5600000.0,
      vehicleName: 'Mercedes-Benz E300 AMG',
      vehicleBrand: 'Mercedes-Benz',
      vehicleModel: 'E300',
      customerName: 'Lê Thị Mai',
      createdAt: DateTime(2026, 10, 2),
    );

    testWidgets('renders in tablet/desktop 2-column grid cell without bottom overflow', (tester) async {
      // Simulate tablet width (720px) where each grid item is ~338px wide
      tester.view.physicalSize = const Size(720, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.75,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 1,
              itemBuilder: (context, index) => AdminBookingCard(
                booking: mockBooking,
                margin: EdgeInsets.zero,
                onTransition: () {},
              ),
            ),
          ),
        ),
      );

      // Verify content
      expect(find.text('VHC-20261002-1003'), findsOneWidget);
      expect(find.text('Lê Thị Mai'), findsOneWidget);
      expect(find.text('Cập nhật'), findsOneWidget);

      // Verify no RenderFlex bottom overflow occurred
      expect(tester.takeException(), isNull);
    });
  });
}
