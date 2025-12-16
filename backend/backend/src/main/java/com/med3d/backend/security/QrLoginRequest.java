package com.med3d.backend.security;

import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class QrLoginRequest {
    private String qrToken;
}
