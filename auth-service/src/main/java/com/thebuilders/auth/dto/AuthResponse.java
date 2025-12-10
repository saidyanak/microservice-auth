package com.thebuilders.auth.dto;

import com.thebuilders.common.enums.Role;
import io.swagger.v3.oas.annotations.media.Schema;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Authentication response")
public class AuthResponse {

    @Schema(description = "JWT Access Token", example = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...")
    private String accessToken;

    @Schema(description = "Refresh Token", example = "550e8400-e29b-41d4-a716-446655440000")
    private String refreshToken;

    @Schema(description = "Token type", example = "Bearer")
    private String tokenType;

    @Schema(description = "Token expiration time (milliseconds)", example = "900000")
    private long expiresIn;

    @Schema(description = "User information")
    private UserInfo user;

    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    @Schema(description = "User information")
    public static class UserInfo {
        @Schema(description = "User ID", example = "123e4567-e89b-12d3-a456-426614174000")
        private String id;

        @Schema(description = "Email", example = "john@example.com")
        private String email;

        @Schema(description = "First name", example = "John")
        private String firstName;

        @Schema(description = "Last name", example = "Doe")
        private String lastName;

        @Schema(description = "Role", example = "USER")
        private Role role;
    }
}
