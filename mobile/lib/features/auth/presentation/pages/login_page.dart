import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/services/vehica_feedback.dart';
import 'package:vehica_mobile/core/utils/validators.dart';
import 'package:vehica_mobile/core/widgets/vehica_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_text_field.dart';
import 'package:vehica_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vehica_mobile/features/auth/presentation/controllers/auth_state.dart';

// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// SCREEN                  : S01 - Login Screen
// USE CASES HANDLED       : UC-01 - User Authentication & JWT Session Initialization
// BUSINESS RULES / BR     : BR-02 (Password length validation), BR-03 (Account status check)
// ------------------------------------------------------------------------------
// ARCHITECTURAL FLOW:
// 1. User inputs email and password credentials.
// 2. Client-side form validation checks format and constraints (VehicaValidators).
// 3. Invokes AuthController.login() -> POST /api/v1/auth/login.
// 4. Stores JWT in SecureStorage -> Role-based navigation (Admin -> /admin/dashboard, User -> /home).
// ==============================================================================
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'user@vehica.com');
  final _passwordController = TextEditingController(text: 'user123456');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      final authState = ref.read(authControllerProvider);
      VehicaFeedback.showSuccess('Đăng nhập thành công! Chào mừng bạn quay trở lại.');
      if (authState.isAdmin) {
        context.go('/admin/dashboard');
      } else {
        context.go('/home');
      }
    } else {
      final authState = ref.read(authControllerProvider);
      VehicaFeedback.showError(
        authState.errorMessage ?? 'Đăng nhập không thành công. Vui lòng kiểm tra lại tài khoản.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                children: [
                  SizedBox(height: (size.height * 0.04).clamp(16.0, 40.0)),

                  // ── Brand mark ──────────────────────────────────────────────
                  _BrandMark(),
                  const SizedBox(height: 32),

                  // ── Login card ──────────────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Đăng nhập',
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tiếp tục trải nghiệm dịch vụ thuê xe',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),

                          // Error banner
                          if (authState.status == AuthStatus.error &&
                              authState.errorMessage != null) ...[
                            _ErrorBanner(message: authState.errorMessage!),
                            const SizedBox(height: 16),
                          ],

                          VehicaTextField(
                            label: 'Email',
                            hint: 'name@example.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icons.email_outlined,
                            validator: VehicaValidators.validateEmail,
                          ),
                          const SizedBox(height: 14),

                          VehicaTextField(
                            label: 'Mật khẩu',
                            hint: 'Tối thiểu 8 ký tự',
                            controller: _passwordController,
                            isPassword: true,
                            textInputAction: TextInputAction.done,
                            prefixIcon: Icons.lock_outline_rounded,
                            validator: VehicaValidators.validatePassword,
                            onFieldSubmitted: (_) => _handleLogin(),
                          ),
                          const SizedBox(height: 8),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                final email = _emailController.text.trim();
                                final route = email.isNotEmpty
                                    ? '/forgot-password?email=${Uri.encodeComponent(email)}'
                                    : '/forgot-password';
                                context.push(route);
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                minimumSize: const Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Quên mật khẩu?',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          VehicaButton(
                            text: 'Đăng nhập',
                            isLoading: authState.isLoading,
                            onPressed: _handleLogin,
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // ── Quick fill (dev helper) ─────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _QuickFill(
                      label: 'Admin',
                      onTap: () {
                        _emailController.text = 'admin@vehica.com';
                        _passwordController.text = 'admin123456';
                      },
                    ),
                    Container(width: 1, height: 14, color: AppColors.borderLight,
                        margin: const EdgeInsets.symmetric(horizontal: 10)),
                    _QuickFill(
                      label: 'Khách',
                      onTap: () {
                        _emailController.text = 'user@vehica.com';
                        _passwordController.text = 'user123456';
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Register link ───────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Chưa có tài khoản? ',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14)),
                    GestureDetector(
                      onTap: () => context.push('/register'),
                      child: Text(
                        'Đăng ký ngay',
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
      ),
    ),
  );
  }
}

// ── Shared sub-widgets ─────────────────────────────────────────────────────────

class _BrandMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.directions_car_rounded, color: Colors.white, size: 34),
        ),
        const SizedBox(height: 14),
        const Text(
          'VEHICA',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: 3.0,
          ),
        ),
        const SizedBox(height: 3),
        const Text(
          'Luxury Mobility & Car Rental',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
      ],
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
        borderRadius: BorderRadius.circular(12),
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

class _QuickFill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _QuickFill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
