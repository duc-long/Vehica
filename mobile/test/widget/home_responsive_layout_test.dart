import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vehica_mobile/features/home/presentation/widgets/home_fleet_cta_banner.dart';
import 'package:vehica_mobile/features/home/presentation/widgets/home_floating_nav_bar.dart';
import 'package:vehica_mobile/features/home/presentation/widgets/home_header_bar.dart';
import 'package:vehica_mobile/features/home/presentation/widgets/home_trust_badges_section.dart';

void main() {
  group('Home Ultra-Narrow Responsive Tests (width: 220px)', () {
    testWidgets('HomeFloatingNavBar renders at 220px width and permits floating SnackBar without crash',
        (tester) async {
      tester.view.physicalSize = const Size(220, 1040);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Center(
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Test Floating SnackBar'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text('Show SnackBar'),
                  ),
                );
              },
            ),
            bottomNavigationBar: const HomeFloatingNavBar(isDark: true),
          ),
        ),
      );

      expect(find.byType(HomeFloatingNavBar), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Trigger floating snackbar
      await tester.tap(find.text('Show SnackBar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Must not throw "Floating SnackBar presented off screen"
      expect(tester.takeException(), isNull);
      expect(find.text('Test Floating SnackBar'), findsOneWidget);
    });

    testWidgets('HomeFleetCtaBanner renders at 220px width with 0 overflow', (tester) async {
      tester.view.physicalSize = const Size(220, 1040);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HomeFleetCtaBanner(),
            ),
          ),
        ),
      );

      expect(find.byType(HomeFleetCtaBanner), findsOneWidget);
      expect(find.text('Khám phá hơn 50+ mẫu xe'), findsOneWidget);
      expect(find.text('Xem toàn bộ xe'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('HomeTrustBadgesSection stacks badges at 220px width with 0 overflow', (tester) async {
      tester.view.physicalSize = const Size(220, 1040);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: HomeTrustBadgesSection(isDark: true),
            ),
          ),
        ),
      );

      expect(find.byType(HomeTrustBadgesSection), findsOneWidget);
      expect(find.text('Cam kết chất lượng Vehica'), findsOneWidget);
      expect(find.text('Bảo hiểm 2 chiều'), findsOneWidget);
      expect(find.text('Xe đời mới 100%'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('HomeHeaderBar adapts gracefully at 220px width', (tester) async {
      tester.view.physicalSize = const Size(220, 1040);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HomeHeaderBar(
              user: null,
              isAdmin: false,
              isDark: true,
            ),
          ),
        ),
      );

      expect(find.byType(HomeHeaderBar), findsOneWidget);
      expect(find.text('Xin chào 👋'), findsOneWidget);
      expect(find.text('Khách hàng'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
