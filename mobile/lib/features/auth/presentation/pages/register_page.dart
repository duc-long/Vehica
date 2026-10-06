// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// SCREEN                  : S11 - Customer Registration Screen
// USE CASES HANDLED       : UC-02 - Customer Account Registration
// BUSINESS RULES / BR     : BR-01 (Email & Phone format validation), BR-02 (Password >= 8 chars)
// ------------------------------------------------------------------------------
// ARCHITECTURAL FLOW:
// 1. User inputs full name, email, phone number, password, and confirmation.
// 2. Client-side validation verifies input against Regex rules (BR-01, BR-02).
// 3. Submits to AuthController.register() -> POST /api/v1/auth/register.
// 4. On HTTP 201 Created, transitions user back to Login (S01).
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/utils/validators.dart';
import 'package:vehica_mobile/core/widgets/vehica_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_text_field.dart';
import 'package:vehica_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vehica_mobile/features/auth/presentation/controllers/auth_state.dart';

/// Customer registration screen (S11, UC-02).
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Process account registration (UC-02, BR-01, BR-02)
  /// Flow: Validate form -> Check password match -> AuthController.register() -> SnackBar -> Pop
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu xác nhận không khớp'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
          phone: _phoneController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
          backgroundColor: AppColors.primary,
        ),
      );
      context.pop();
    } else {
      final errorMsg = ref.read(authControllerProvider).errorMessage ??
          'Đăng ký thất bại. Vui lòng thử lại.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Tạo tài khoản'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── Header info ───────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryMuted,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tạo tài khoản Vehica',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: AppColors.primaryDark,
                              )),
                          Text('Điền thông tin để bắt đầu thuê xe',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.primaryDark.withValues(alpha: 0.7),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Form card ─────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                ),
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (authState.status == AuthStatus.error && authState.errorMessage != null) ...[
                        _ErrorBanner(message: authState.errorMessage!),
                        const SizedBox(height: 16),
                      ],

                      VehicaTextField(
                        label: 'Họ và tên',
                        hint: 'Nguyễn Văn A',
                        controller: _fullNameController,
                        prefixIcon: Icons.person_outline_rounded,
                        validator: VehicaValidators.validateFullName,
                      ),
                      const SizedBox(height: 14),

                      VehicaTextField(
                        label: 'Email',
                        hint: 'name@example.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: VehicaValidators.validateEmail,
                      ),
                      const SizedBox(height: 14),

                      VehicaTextField(
                        label: 'Số điện thoại',
                        hint: '0901 234 567',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                        validator: VehicaValidators.validatePhone,
                      ),
                      const SizedBox(height: 14),

                      VehicaTextField(
                        label: 'Mật khẩu',
                        hint: 'Tối thiểu 8 ký tự',
                        controller: _passwordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        validator: VehicaValidators.validatePassword,
                      ),
                      const SizedBox(height: 14),

                      VehicaTextField(
                        label: 'Xác nhận mật khẩu',
                        hint: 'Nhập lại mật khẩu',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outline_rounded,
                        validator: (val) {
                          if (val != _passwordController.text) {
                            return 'Mật khẩu không khớp';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      VehicaButton(
                        text: 'Tạo tài khoản',
                        isLoading: authState.isLoading,
                        onPressed: _handleRegister,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Đã có tài khoản? ',
                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text(
                      'Đăng nhập',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: const TextStyle(color: AppColors.error, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
