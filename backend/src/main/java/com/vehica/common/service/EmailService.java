package com.vehica.common.service;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import java.io.UnsupportedEncodingException;

/**
 * ==============================================================================
 * VEHICA CAR RENTAL SYSTEM - EMAIL SERVICE
 * ==============================================================================
 * Dispatches transactional notifications, system alerts, and security OTP codes
 * via Google SMTP JavaMailSender with luxury-branded HTML templates.
 * ==============================================================================
 */
@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String fromEmail;

    /**
     * Sends a 6-digit OTP code to the target email address for password reset (UC-14, BR-23).
     *
     * @param toEmail       recipient email
     * @param otpCode       6-digit numerical OTP code
     * @param expiryMinutes OTP validity window in minutes
     */
    public void sendPasswordResetOtp(String toEmail, String otpCode, int expiryMinutes) {
        try {
            MimeMessage mimeMessage = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, true, "UTF-8");

            helper.setFrom(fromEmail, "Vehica Car Rental");
            helper.setTo(toEmail.trim());
            helper.setSubject("[Vehica] Mã xác thực OTP đặt lại mật khẩu: " + otpCode);

            String htmlBody = buildOtpEmailHtml(otpCode, expiryMinutes);
            String plainText = buildOtpEmailPlainText(otpCode, expiryMinutes);

            helper.setText(plainText, htmlBody);

            log.info("Dispatching password reset OTP email to [{}]...", toEmail);
            mailSender.send(mimeMessage);
            log.info("Password reset OTP successfully sent to [{}]", toEmail);
        } catch (MessagingException | UnsupportedEncodingException e) {
            log.error("Failed to compose or send OTP email to [{}]: {}", toEmail, e.getMessage(), e);
            throw new RuntimeException("Không thể gửi email OTP đến " + toEmail + ". Vui lòng kiểm tra lại địa chỉ email hoặc thử lại sau.", e);
        } catch (Exception e) {
            log.error("Unexpected error sending OTP email to [{}]: {}", toEmail, e.getMessage(), e);
            throw new RuntimeException("Lỗi hệ thống khi gửi email OTP. Vui lòng thử lại sau.", e);
        }
    }

    private String buildOtpEmailHtml(String otpCode, int expiryMinutes) {
        String spacedOtp = otpCode.replaceAll(".(?!$)", "$0 ");
        return """
                <!DOCTYPE html>
                <html lang="vi">
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                    <title>Mã xác thực OTP - Vehica</title>
                </head>
                <body style="margin: 0; padding: 0; background-color: #f3f4f6; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; color: #1f2937;">
                    <table role="presentation" width="100%%" cellspacing="0" cellpadding="0" style="background-color: #f3f4f6; padding: 40px 16px;">
                        <tr>
                            <td align="center">
                                <table role="presentation" width="100%%" style="max-width: 540px; background-color: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 10px 25px rgba(0,0,0,0.06); border: 1px solid #e5e7eb;" cellspacing="0" cellpadding="0">
                                    <!-- Header -->
                                    <tr>
                                        <td style="background-color: #0f172a; padding: 32px 24px; text-align: center;">
                                            <h1 style="margin: 0; color: #ffffff; font-size: 24px; font-weight: 800; letter-spacing: 2px;">VEHICA</h1>
                                            <p style="margin: 6px 0 0 0; color: #94a3b8; font-size: 13px; font-weight: 500; text-transform: uppercase; letter-spacing: 1px;">Dịch vụ cho thuê xe cao cấp</p>
                                        </td>
                                    </tr>

                                    <!-- Main Content -->
                                    <tr>
                                        <td style="padding: 36px 32px;">
                                            <h2 style="margin: 0 0 12px 0; color: #0f172a; font-size: 20px; font-weight: 700;">Yêu cầu đặt lại mật khẩu</h2>
                                            <p style="margin: 0 0 20px 0; font-size: 14.5px; line-height: 1.6; color: #4b5563;">
                                                Chúng tôi nhận được yêu cầu khôi phục mật khẩu cho tài khoản Vehica của bạn. Vui lòng sử dụng mã xác thực OTP bên dưới để hoàn tất quá trình đổi mật khẩu:
                                            </p>

                                            <!-- OTP Code Box -->
                                            <div style="background: linear-gradient(135deg, #f8fafc 0%%, #e2e8f0 100%%); border: 2px dashed #0284c7; border-radius: 12px; padding: 24px; text-align: center; margin: 24px 0;">
                                                <span style="display: block; font-size: 12px; font-weight: 700; color: #0284c7; text-transform: uppercase; letter-spacing: 1.5px; margin-bottom: 8px;">Mã xác thực một lần (OTP)</span>
                                                <span style="display: block; font-size: 36px; font-weight: 800; color: #0f172a; letter-spacing: 8px; font-family: 'Courier New', Courier, monospace;">%s</span>
                                                <span style="display: block; font-size: 12px; color: #64748b; margin-top: 8px;">Hiệu lực trong vòng <strong>%d phút</strong></span>
                                            </div>

                                            <!-- Security Notice -->
                                            <div style="background-color: #fffbeb; border-left: 4px solid #f59e0b; padding: 12px 16px; border-radius: 6px; margin-top: 24px;">
                                                <p style="margin: 0; font-size: 13px; line-height: 1.5; color: #92400e;">
                                                    <strong>Lưu ý bảo mật:</strong> Tuyệt đối không chia sẻ mã này cho bất kỳ ai, bao gồm cả nhân viên hỗ trợ của Vehica. Nếu bạn không gửi yêu cầu này, hãy đổi mật khẩu hoặc bỏ qua email này.
                                                </p>
                                            </div>
                                        </td>
                                    </tr>

                                    <!-- Footer -->
                                    <tr>
                                        <td style="background-color: #f8fafc; padding: 20px 32px; text-align: center; border-top: 1px solid #e5e7eb;">
                                            <p style="margin: 0; font-size: 12px; color: #94a3b8; line-height: 1.5;">
                                                Email này được gửi tự động từ hệ thống Vehica Platform.<br>
                                                &copy; 2026 Vehica Car Rental Platform. All rights reserved.
                                            </p>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </body>
                </html>
                """.formatted(spacedOtp, expiryMinutes);
    }

    private String buildOtpEmailPlainText(String otpCode, int expiryMinutes) {
        return """
                [VEHICA CAR RENTAL] - YÊU CẦU ĐẶT LẠI MẬT KHẨU
                
                Chào bạn,
                
                Chúng tôi nhận được yêu cầu khôi phục mật khẩu cho tài khoản Vehica của bạn.
                Mã xác thực OTP của bạn là: %s
                
                Mã xác thực này có hiệu lực trong vòng %d phút.
                
                Lưu ý: Tuyệt đối không chia sẻ mã này cho bất kỳ ai. Nếu bạn không gửi yêu cầu này, vui lòng bỏ qua email.
                
                Trân trọng,
                Đội ngũ Vehica Car Rental
                """.formatted(otpCode, expiryMinutes);
    }
}
