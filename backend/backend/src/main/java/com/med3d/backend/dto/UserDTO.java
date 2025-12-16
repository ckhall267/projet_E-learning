package com.med3d.backend.dto;

import com.med3d.backend.model.Role;
import lombok.Data;

@Data
public class UserDTO {
    private Long id;
    private String nom;
    private String prenom;
    private String email;
    private Role role;
}
