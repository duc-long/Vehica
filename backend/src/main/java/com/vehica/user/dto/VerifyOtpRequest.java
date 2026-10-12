package com.vehica.user.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Yêu cầu kiểm tra xác thực mã OTP")
public class VerifyOtpRequest {

    @NotBlank(message = "Email không được để trống")
    @Email(message = "Email không đúng định dạng")
    @Schema(description = "Địa chỉ email đã đăng ký", example = "customer@vehica.com")
    private String email;

    @NotBlank(message = "Mã xác thực OTP không được để trống")
    @Schema(description = "Mã xác thực OTP 6 ký tự", example = "123456")
    private String otp;
}
