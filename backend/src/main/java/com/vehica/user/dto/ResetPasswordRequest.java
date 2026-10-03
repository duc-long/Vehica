package com.vehica.user.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Yêu cầu đặt lại mật khẩu với mã OTP xác thực")
public class ResetPasswordRequest {

    @NotBlank(message = "Email không được để trống")
    @Email(message = "Email không đúng định dạng")
    @Schema(description = "Địa chỉ email đã đăng ký", example = "customer@vehica.com")
    private String email;

    @NotBlank(message = "Mã xác thực OTP không được để trống")
    @Schema(description = "Mã xác thực OTP 6 ký tự", example = "123456")
    private String otp;

    @NotBlank(message = "Mật khẩu mới không được để trống")
    @Size(min = 8, message = "Mật khẩu mới phải có ít nhất 8 ký tự")
    @Schema(description = "Mật khẩu mới (tối thiểu 8 ký tự)", example = "NewPass@2026")
    private String newPassword;
}
