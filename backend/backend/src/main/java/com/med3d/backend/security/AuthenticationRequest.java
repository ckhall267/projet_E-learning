package com.med3d.backend.security;

import lombok.Data;

@Data
public class AuthenticationRequest {
    private String email;
    private String password;
}
