package com.vehica.user.service;

import com.vehica.common.enums.UserStatus;
import com.vehica.common.exception.ResourceNotFoundException;
import com.vehica.common.response.PageResponse;
import com.vehica.user.dto.UserDto;
import com.vehica.user.entity.User;
import com.vehica.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public UserDto getProfile(UUID userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy thông tin người dùng."));
        return mapToDto(user);
    }

    @Transactional(readOnly = true)
    public PageResponse<UserDto> searchUsers(String keyword, UserStatus status, Pageable pageable) {
        Page<User> page = userRepository.searchUsers(keyword, status, pageable);
        return PageResponse.from(page.map(this::mapToDto));
    }

    public UserDto mapToDto(User user) {
        return UserDto.builder()
                .id(user.getId())
                .email(user.getEmail())
                .fullName(user.getFullName())
                .phone(user.getPhone())
                .avatarUrl(user.getAvatarUrl())
                .role(user.getRole())
                .status(user.getStatus())
                .createdAt(user.getCreatedAt())
                .updatedAt(user.getUpdatedAt())
                .build();
    }
}
