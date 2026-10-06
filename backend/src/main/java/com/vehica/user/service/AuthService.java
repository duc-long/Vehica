package com.vehica.user.service;

import com.vehica.common.enums.UserStatus;
import com.vehica.common.exception.BadRequestException;
import com.vehica.common.exception.ForbiddenException;
import com.vehica.security.JwtTokenProvider;
import com.vehica.security.UserPrincipal;
import com.vehica.user.dto.AuthResponse;
import com.vehica.user.dto.LoginRequest;
import com.vehica.user.entity.User;
import com.vehica.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final AuthenticationManager authenticationManager;
    private final JwtTokenProvider tokenProvider;
    private final UserService userService;

    public AuthResponse login(LoginRequest request) {
        Authentication authentication;
        try {
            authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getEmail().toLowerCase().trim(),
                            request.getPassword()
                    )
            );
        } catch (org.springframework.security.authentication.BadCredentialsException e) {
            throw new BadRequestException("Email hoặc mật khẩu không đúng.");
        } catch (org.springframework.security.authentication.DisabledException e) {
            throw new ForbiddenException("Tài khoản đã bị vô hiệu hóa.");
        } catch (org.springframework.security.authentication.LockedException e) {
            throw new ForbiddenException("Tài khoản đang bị khóa. Hãy liên hệ quản trị viên.");
        }

        UserPrincipal principal = (UserPrincipal) authentication.getPrincipal();

        if (principal.getStatus() == UserStatus.BLOCKED) {
            throw new ForbiddenException("Tài khoản đang bị khóa. Hãy liên hệ quản trị viên.");
        }

        SecurityContextHolder.getContext().setAuthentication(authentication);
        String jwt = tokenProvider.generateToken(authentication);

        User user = userRepository.findById(principal.getId())
                .orElseThrow(() -> new ForbiddenException("Tài khoản không tồn tại."));

        return AuthResponse.builder()
                .accessToken(jwt)
                .tokenType("Bearer")
                .user(userService.mapToDto(user))
                .build();
    }
}
