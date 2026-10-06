import 'package:flutter/material.dart';
import 'package:vehica_mobile/core/widgets/vehica_empty_view.dart';
import 'package:vehica_mobile/core/widgets/vehica_error_view.dart';

class VehicaAsyncView<T> extends StatelessWidget {
  final bool isLoading;
  final String? errorMessage;
  final bool isEmpty;
  final String emptyMessage;
  final IconData? emptyIcon;
  final Widget? action;
  final VoidCallback? onRetry;
  final Widget Function(BuildContext context) dataBuilder;
  final Widget? loadingWidget;

  const VehicaAsyncView({
    super.key,
    required this.isLoading,
    this.errorMessage,
    required this.isEmpty,
    this.emptyMessage = 'Không tìm thấy dữ liệu',
    this.emptyIcon,
    this.action,
    this.onRetry,
    required this.dataBuilder,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return loadingWidget ??
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
    }

    if (errorMessage != null && errorMessage!.isNotEmpty) {
      return VehicaErrorView(
        message: errorMessage!,
        onRetry: onRetry,
      );
    }

    if (isEmpty) {
      return VehicaEmptyView(
        message: emptyMessage,
        icon: emptyIcon,
        action: action,
      );
    }

    return dataBuilder(context);
  }
}
