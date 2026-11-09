import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vehica_mobile/app/router/app_router.dart';
import 'package:vehica_mobile/core/config/app_config.dart';
import 'package:vehica_mobile/core/services/booking_sync_service.dart';
import 'package:vehica_mobile/core/services/vehica_feedback.dart';
import 'package:vehica_mobile/core/theme/app_theme.dart';

class VehicaApp extends ConsumerWidget {
  const VehicaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Kích hoạt dịch vụ nền theo dõi thay đổi booking & đẩy thông báo in-app
    ref.watch(bookingSyncServiceProvider);

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: VehicaFeedback.messengerKey,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
