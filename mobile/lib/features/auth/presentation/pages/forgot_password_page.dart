import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vehica_mobile/core/constants/app_colors.dart';
import 'package:vehica_mobile/core/utils/validators.dart';
import 'package:vehica_mobile/core/widgets/vehica_button.dart';
import 'package:vehica_mobile/core/widgets/vehica_text_field.dart';
import 'package:vehica_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vehica_mobile/features/auth/presentation/controllers/auth_state.dart';

// ==============================================================================
// VEHICA CAR RENTAL SYSTEM - CLEAN ARCHITECTURE MOBILE APP
// ==============================================================================
// SCREEN            : S14 - Forgot & Reset Password
// USE CASE          : UC-01b - Forgot password via OTP & Update new password
// BUSINESS RULES    : BR-02 (Password >= 8 characters), 6-digit OTP
// ------------------------------------------------------------------------------
// FLOW:
// 1. Step 1: Customer enters registered email -> Clicks "Send verification code".
// 2. AuthController.forgotPassword() sends request to backend POST /api/v1/auth/forgot-password.
// 3. System switches to Step 2: Enter OTP, New password (>= 8 chars) & Confirm password.
// 4. AuthController.resetPassword() sends POST /api/v1/auth/reset-password.
// 5. Success notification and navigates user back to Login screen (S01 Login).
// ==============================================================================
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  int _currentStep = 1; // 1: Enter email, 2: Enter OTP & new password

  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController(text: 'user@vehica.com');
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _serverOtpHint;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestOtp() async {
    if (!_step1FormKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final otp = await ref.read(authControllerProvider.notifier).forgotPassword(email);

    if (otp != null && mounted) {
      setState(() {
        _serverOtpHint = otp;
        _otpController.text = otp; // Automatically fill OTP for smooth experience in testing/demo
        _currentStep = 2;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mã OTP đã được gửi đến $email (Mã: $otp)'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleResetPassword() async {
    if (!_step2FormKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu xác nhận không khớp. Vui lòng kiểm tra lại.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).resetPassword(
          email: _emailController.text.trim(),
          otp: _otpController.text.trim(),
          newPassword: _newPasswordController.text,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt lại mật khẩu thành công! Hãy đăng nhập bằng mật khẩu mới.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () {
            if (_currentStep == 2) {
              setState(() => _currentStep = 1);
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          _currentStep == 1 ? 'Quên mật khẩu' : 'Đặt lại mật khẩu',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ── Header Icon & Step indicator ───────────────────────────────
              _HeaderSection(currentStep: _currentStep),
              const SizedBox(height: 28),

              // ── Form container ─────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: _currentStep == 1 ? _buildStep1Form(authState, theme) : _buildStep2Form(authState, theme),
              ),

              const SizedBox(height: 24),

              // ── Back to login shortcut ─────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Nhớ mật khẩu? ',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
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

  // ── Step 1: Enter Email ───────────────────────────────────────────────────────
  Widget _buildStep1Form(AuthState authState, ThemeData theme) {
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Khôi phục tài khoản',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Nhập địa chỉ email đăng ký của bạn. Hệ thống sẽ gửi mã OTP xác thực để tạo mật khẩu mới.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Error banner
          if (authState.status == AuthStatus.error && authState.errorMessage != null) ...[
            _ErrorBanner(message: authState.errorMessage!),
            const SizedBox(height: 16),
          ],

          VehicaTextField(
            label: 'Email tài khoản',
            hint: 'name@example.com',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            validator: VehicaValidators.validateEmail,
          ),
          const SizedBox(height: 24),

          VehicaButton(
            text: 'Gửi mã xác thực OTP',
            isLoading: authState.isLoading,
            icon: Icons.send_rounded,
            onPressed: _handleRequestOtp,
          ),
        ],
      ),
    );
  }

  // ── Step 2: Enter OTP & Set new password ─────────────────────────────────────
  Widget _buildStep2Form(AuthState authState, ThemeData theme) {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Nhập mã OTP & Mật khẩu mới',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Mã OTP đã được gửi đến ${_emailController.text.trim()}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Demo OTP Hint Chip
          if (_serverOtpHint != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Mã OTP của bạn: $_serverOtpHint (hoặc dùng 123456)',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // Error banner
          if (authState.status == AuthStatus.error && authState.errorMessage != null) ...[
            _ErrorBanner(message: authState.errorMessage!),
            const SizedBox(height: 16),
          ],

          VehicaTextField(
            label: 'Mã xác thực OTP (6 chữ số)',
            hint: 'Ví dụ: 123456',
            controller: _otpController,
            keyboardType: TextInputType.number,
            prefixIcon: Icons.security_rounded,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập mã OTP';
              }
              if (value.trim().length < 4) {
                return 'Mã OTP không hợp lệ';
              }
              return null;
            },
          ),
          const SizedBox(height: 14),

          VehicaTextField(
            label: 'Mật khẩu mới',
            hint: 'Tối thiểu 8 ký tự',
            controller: _newPasswordController,
            isPassword: true,
            prefixIcon: Icons.lock_reset_rounded,
            validator: VehicaValidators.validatePassword,
          ),
          const SizedBox(height: 14),

          VehicaTextField(
            label: 'Xác nhận mật khẩu mới',
            hint: 'Nhập lại mật khẩu mới',
            controller: _confirmPasswordController,
            isPassword: true,
            prefixIcon: Icons.lock_outline_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng xác nhận mật khẩu';
              }
              if (value != _newPasswordController.text) {
                return 'Mật khẩu xác nhận không khớp';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          VehicaButton(
            text: 'Đặt lại mật khẩu',
            isLoading: authState.isLoading,
            icon: Icons.check_circle_outline_rounded,
            onPressed: _handleResetPassword,
          ),
          const SizedBox(height: 14),

          // Resend OTP / Change email button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _currentStep = 1),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Đổi email', style: TextStyle(fontSize: 13)),
              ),
              TextButton.icon(
                onPressed: authState.isLoading ? null : _handleRequestOtp,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Gửi lại mã OTP', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Header Icon Section ────────────────────────────────────────────────────────
class _HeaderSection extends StatelessWidget {
  final int currentStep;
  const _HeaderSection({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: currentStep == 1
                  ? [AppColors.primary, const Color(0xFF14B8A6)]
                  : [const Color(0xFF10B981), AppColors.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            currentStep == 1 ? Icons.lock_reset_rounded : Icons.mark_email_read_rounded,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StepBadge(step: 1, title: 'Nhập email', isActive: currentStep == 1, isCompleted: currentStep > 1),
            Container(
              width: 32,
              height: 2,
              color: currentStep > 1 ? AppColors.primary : AppColors.borderLight,
              margin: const EdgeInsets.symmetric(horizontal: 8),
            ),
            _StepBadge(step: 2, title: 'Tạo mật khẩu', isActive: currentStep == 2, isCompleted: false),
          ],
        ),
      ],
    );
  }
}

class _StepBadge extends StatelessWidget {
  final int step;
  final String title;
  final bool isActive;
  final bool isCompleted;

  const _StepBadge({
    required this.step,
    required this.title,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final color = (isActive || isCompleted) ? AppColors.primary : AppColors.textSecondary;
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (isActive || isCompleted) ? AppColors.primary : Colors.transparent,
            border: Border.all(color: color, width: 1.5),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text(
                    '$step',
                    style: TextStyle(
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            color: (isActive || isCompleted) ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: (isActive || isCompleted) ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

// ── Error Banner ───────────────────────────────────────────────────────────────
class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
