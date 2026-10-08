import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehica_mobile/core/widgets/vehica_button.dart';

void main() {
  group('VehicaButton Widget Tests', () {
    testWidgets('renders button text and triggers onPressed when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicaButton(
              text: 'Đăng nhập',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Đăng nhập'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.text('Đăng nhập'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('shows CircularProgressIndicator when isLoading is true and ignores tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VehicaButton(
              text: 'Đang tải',
              isLoading: true,
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Đang tải'), findsNothing);

      await tester.tap(find.byType(CircularProgressIndicator));
      await tester.pump();

      expect(tapped, isFalse);
    });
  });
}
