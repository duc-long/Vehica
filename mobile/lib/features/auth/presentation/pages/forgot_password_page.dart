import 'dart:async';
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
// SCREEN            : S14 - Forgot & Reset Password
// USE CASE          : UC-01b - Forgot password via OTP & Update new password
// BUSINESS RULES    : BR-02 (Password >= 8 characters), 6-digit OTP, 60s cooldown
// ==============================================================================
class ForgotPasswordPage extends ConsumerStatefulWidget {
  final String? initialEmail;

  const ForgotPasswordPage({super.key, this.initialEmail});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  // 1: Enter email & request OTP, 2: Check & verify OTP, 3: Set new password
  int _currentStep = 1;
  int _cooldownSeconds = 0;
  Timer? _countdownTimer;

  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();
  final _step3FormKey = GlobalKey<FormState>();

  late final TextEditingController _emailController;
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _serverOtpHint;

  @override
  void initState() {
    super.initState();
    final prefilledEmail = widget.initialEmail ??
        ref.read(authControllerProvider).user?.email ??
        '';
    _emailController = TextEditingController(text: prefilledEmail);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startCountdown([int seconds = 60]) {
    _countdownTimer?.cancel();
    setState(() => _cooldownSeconds = seconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
      } else {
        setState(() => _cooldownSeconds--);
      }
    });
  }

  // ── Step 1 Action: Request OTP ─────────────────────────────────────────────
  Future<void> _handleRequestOtp() async {
    if (!_step1FormKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final otp = await ref.read(authControllerProvider.notifier).forgotPassword(email);
    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    if (otp != null) {
      setState(() {
        _serverOtpHint = otp;
        _currentStep = 2;
      });
      _startCountdown(60);

      VehicaFeedback.showSuccess(
        'Mã OTP 6 chữ số đã được gửi qua email đến $email',
        title: 'Gửi mã thành công',
      );
    } else {
      final errorMsg = authState.errorMessage ??
          'Không thể gửi mã xác thực. Vui lòng kiểm tra lại địa chỉ email.';
      VehicaFeedback.showError(errorMsg, title: 'Lỗi gửi mã OTP');
    }
  }

  // ── Step 2 Action: Check & Verify OTP ──────────────────────────────────────
  Future<void> _handleVerifyOtp() async {
    if (!_step2FormKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();

    final success = await ref.read(authControllerProvider.notifier).verifyOtp(
          email: email,
          otp: otp,
        );
    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    if (success) {
      setState(() {
        _currentStep = 3;
      });
      VehicaFeedback.showSuccess(
        'Mã OTP hợp lệ! Hãy thiết lập mật khẩu mới.',
        title: 'Xác thực thành công',
      );
    } else {
      final errorMsg = authState.errorMessage ??
          'Mã xác thực OTP không chính xác hoặc đã hết hiệu lực. Vui lòng thử lại.';
      VehicaFeedback.showError(errorMsg, title: 'Lỗi xác thực OTP');
    }
  }

  // ── Step 3 Action: Reset & Set New Password ─────────────────────────────────
  Future<void> _handleResetPassword() async {
    if (!_step3FormKey.currentState!.validate()) return;

    if (_newPasswordController.text != _confirmPasswordController.text) {
      VehicaFeedback.showError('Mật khẩu xác nhận không khớp. Vui lòng kiểm tra lại.');
      return;
    }

    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    final newPassword = _newPasswordController.text;

    final success = await ref.read(authControllerProvider.notifier).resetPassword(
          email: email,
          otp: otp,
          newPassword: newPassword,
        );
    if (!mounted) return;

    final authState = ref.read(authControllerProvider);
    if (success) {
      final wasLoggedIn = authState.isAuthenticated;
      VehicaFeedback.showSuccess(
        wasLoggedIn
            ? 'Đổi mật khẩu mới thành công!'
            : 'Đặt lại mật khẩu thành công! Hãy đăng nhập bằng mật khẩu mới.',
        title: 'Thành công',
      );
      if (wasLoggedIn) {
        context.pop();
      } else {
        context.go('/login');
      }
    } else {
      final errorMsg = authState.errorMessage ??
          'Đặt lại mật khẩu thất bại. Mã OTP không đúng hoặc đã hết hiệu lực.';
      VehicaFeedback.showError(errorMsg, title: 'Lỗi đặt lại mật khẩu');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final isLoggedIn = authState.isAuthenticated;

    String appBarTitle;
    if (isLoggedIn) {
      if (_currentStep == 1) {
        appBarTitle = 'Đổi mật khẩu';
      } else if (_currentStep == 2) {
        appBarTitle = 'Xác thực OTP';
      } else {
        appBarTitle = 'Mật khẩu mới';
      }
    } else {
      if (_currentStep == 1) {
        appBarTitle = 'Quên mật khẩu';
      } else if (_currentStep == 2) {
        appBarTitle = 'Xác thực OTP';
      } else {
        appBarTitle = 'Đặt lại mật khẩu';
      }
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppColors.textPrimary,
            size: 20,
          ),
          onPressed: () {
            if (_currentStep == 3) {
              setState(() => _currentStep = 2);
            } else if (_currentStep == 2) {
              setState(() => _currentStep = 1);
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          appBarTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // Header Icon & Step indicator (3 steps)
                  _HeaderSection(currentStep: _currentStep),
                  const SizedBox(height: 28),

                  // Form container
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: _buildCurrentStepForm(authState, theme, isDark, isLoggedIn),
                  ),

                  const SizedBox(height: 24),

                  // Back to login shortcut (only if not logged in)
                  if (!isLoggedIn)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Nhớ mật khẩu? ',
                          style: TextStyle(
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/login'),
                          child: const Text(
                            'Đăng nhập ngay',
                            style: TextStyle(
                              color: AppColors.primaryLight,
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

  Widget _buildCurrentStepForm(AuthState authState, ThemeData theme, bool isDark, bool isLoggedIn) {
    switch (_currentStep) {
      case 1:
        return _buildStep1Form(authState, theme, isDark, isLoggedIn);
      case 2:
        return _buildStep2Form(authState, theme, isDark, isLoggedIn);
      case 3:
      default:
        return _buildStep3Form(authState, theme, isDark, isLoggedIn);
    }
  }

  // ── Step 1: Enter Email ───────────────────────────────────────────────────────
  Widget _buildStep1Form(AuthState authState, ThemeData theme, bool isDark, bool isLoggedIn) {
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isLoggedIn ? 'Bảo mật & Đổi mật khẩu' : 'Khôi phục tài khoản',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isLoggedIn
                ? 'Nhấn nút bên dưới để hệ thống gửi mã xác thực OTP (hiệu lực 5 phút) đến email tài khoản của bạn.'
                : 'Nhập địa chỉ email đăng ký của bạn. Hệ thống sẽ gửi mã xác thực OTP (hiệu lực 5 phút) qua email để đổi mật khẩu.',
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),

          // Error banner
          if (authState.status == AuthStatus.error && authState.errorMessage != null) ...[
            _ErrorBanner(message: authState.errorMessage!),
            const SizedBox(height: 16),
          ],

          VehicaTextField(
            label: 'Email tài khoản *',
            hint: 'name@example.com',
            controller: _emailController,
            readOnly: isLoggedIn,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.email_outlined,
            validator: VehicaValidators.validateEmail,
            onFieldSubmitted: (_) => _handleRequestOtp(),
          ),
          if (isLoggedIn) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 14,
                  color: isDark ? Colors.white54 : AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Email của tài khoản đang đăng nhập',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),

          VehicaButton(
            text: 'Gửi mã xác thực OTP qua Email',
            isLoading: authState.isLoading,
            icon: Icons.send_rounded,
            onPressed: _handleRequestOtp,
          ),
        ],
      ),
    );
  }

  // ── Step 2: Check & Verify OTP Code ──────────────────────────────────────────
  Widget _buildStep2Form(AuthState authState, ThemeData theme, bool isDark, bool isLoggedIn) {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Nhập mã xác thực OTP',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Mã OTP 6 số đã được gửi qua email đến:\n${_emailController.text.trim()}',
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),

          // Email Delivery Instructions Notice Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.mark_email_read_rounded,
                  color: AppColors.primaryLight,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vui lòng mở hòm thư email của bạn (kiểm tra cả mục Hộp thư đến và Thư rác/Spam) để lấy mã OTP 6 chữ số.',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.textPrimary,
                      fontSize: 12.5,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Live OTP Hint Banner (if available in dev/testing response)
          if (_serverOtpHint != null && _serverOtpHint != 'sent') ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.code_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Mã OTP (môi trường dev): $_serverOtpHint',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Error banner
          if (authState.status == AuthStatus.error && authState.errorMessage != null) ...[
            _ErrorBanner(message: authState.errorMessage!),
            const SizedBox(height: 16),
          ],

          VehicaTextField(
            label: 'Mã xác thực OTP (6 chữ số) *',
            hint: 'Nhập mã 6 chữ số',
            controller: _otpController,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.security_rounded,
            onFieldSubmitted: (_) => _handleVerifyOtp(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập mã OTP';
              }
              if (value.trim().length < 4) {
                return 'Mã OTP không hợp lệ (tối thiểu 4-6 ký tự)';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          VehicaButton(
            text: 'Xác thực mã OTP',
            isLoading: authState.isLoading,
            icon: Icons.verified_user_rounded,
            onPressed: _handleVerifyOtp,
          ),
          const SizedBox(height: 14),

          // Resend OTP / Change email button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  if (isLoggedIn) {
                    context.pop();
                  } else {
                    setState(() => _currentStep = 1);
                  }
                },
                icon: Icon(
                  isLoggedIn ? Icons.close_rounded : Icons.edit_outlined,
                  size: 16,
                ),
                label: Text(
                  isLoggedIn ? 'Hủy bỏ' : 'Đổi email',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              TextButton.icon(
                onPressed: (_cooldownSeconds > 0 || authState.isLoading)
                    ? null
                    : _handleRequestOtp,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(
                  _cooldownSeconds > 0
                      ? 'Gửi lại sau (${_cooldownSeconds}s)'
                      : 'Gửi lại mã OTP',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _cooldownSeconds > 0
                        ? (isDark ? Colors.white38 : AppColors.textDisabled)
                        : AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step 3: Set New Password ────────────────────────────────────────────────
  Widget _buildStep3Form(AuthState authState, ThemeData theme, bool isDark, bool isLoggedIn) {
    return Form(
      key: _step3FormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isLoggedIn ? 'Thiết lập mật khẩu mới' : 'Đặt lại mật khẩu',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Nhập mật khẩu mới an toàn cho tài khoản ${_emailController.text.trim()}',
            style: TextStyle(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),

          // Error banner
          if (authState.status == AuthStatus.error && authState.errorMessage != null) ...[
            _ErrorBanner(message: authState.errorMessage!),
            const SizedBox(height: 16),
          ],

          VehicaTextField(
            label: 'Mật khẩu mới *',
            hint: 'Tối thiểu 8 ký tự',
            controller: _newPasswordController,
            isPassword: true,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.lock_reset_rounded,
            validator: VehicaValidators.validatePassword,
          ),
          const SizedBox(height: 14),

          VehicaTextField(
            label: 'Xác nhận mật khẩu mới *',
            hint: 'Nhập lại mật khẩu mới',
            controller: _confirmPasswordController,
            isPassword: true,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.lock_outline_rounded,
            onFieldSubmitted: (_) => _handleResetPassword(),
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
            text: isLoggedIn ? 'Cập nhật mật khẩu mới' : 'Đặt lại mật khẩu',
            isLoading: authState.isLoading,
            icon: Icons.check_circle_outline_rounded,
            onPressed: _handleResetPassword,
          ),
          const SizedBox(height: 14),

          Center(
            child: TextButton.icon(
              onPressed: () => setState(() => _currentStep = 2),
              icon: const Icon(Icons.arrow_back_rounded, size: 16),
              label: const Text('Quay lại bước nhập OTP', style: TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final int currentStep;

  const _HeaderSection({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    if (currentStep == 1) {
      icon = Icons.lock_reset_rounded;
    } else if (currentStep == 2) {
      icon = Icons.pin_outlined;
    } else {
      icon = Icons.shield_outlined;
    }

    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25), width: 1.5),
          ),
          child: Icon(
            icon,
            size: 38,
            color: AppColors.primaryLight,
          ),
        ),
        const SizedBox(height: 16),

        // Step indicator pills (3 steps)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StepPill(step: 1, label: 'Email', isActive: currentStep >= 1, isCurrent: currentStep == 1),
            Container(
              width: 20,
              height: 2,
              color: currentStep >= 2 ? AppColors.primary : AppColors.borderLight,
              margin: const EdgeInsets.symmetric(horizontal: 4),
            ),
            _StepPill(step: 2, label: 'Mã OTP', isActive: currentStep >= 2, isCurrent: currentStep == 2),
            Container(
              width: 20,
              height: 2,
              color: currentStep >= 3 ? AppColors.primary : AppColors.borderLight,
              margin: const EdgeInsets.symmetric(horizontal: 4),
            ),
            _StepPill(step: 3, label: 'Mật khẩu', isActive: currentStep >= 3, isCurrent: currentStep == 3),
          ],
        ),
      ],
    );
  }
}

class _StepPill extends StatelessWidget {
  final int step;
  final String label;
  final bool isActive;
  final bool isCurrent;

  const _StepPill({
    required this.step,
    required this.label,
    required this.isActive,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 11,
          backgroundColor: isActive ? AppColors.primary : AppColors.surfaceVariantLight,
          child: Text(
            '$step',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.primaryLight : AppColors.textSecondary,
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
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
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
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
