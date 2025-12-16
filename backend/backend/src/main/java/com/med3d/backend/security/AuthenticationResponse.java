package com.med3d.backend.security;

import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class AuthenticationResponse {
    private final String jwt;
    private final String role;
    private final String nom;
    private final String prenom;
}
