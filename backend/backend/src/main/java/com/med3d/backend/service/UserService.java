package com.med3d.backend.service;

import com.med3d.backend.dto.LoginRequest;
import com.med3d.backend.dto.RegisterRequest;
import com.med3d.backend.dto.UserDTO;
import com.med3d.backend.model.User;
import com.med3d.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.Optional;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    public UserDTO registerUser(RegisterRequest request) {
        if (userRepository.findByEmail(request.getEmail()).isPresent()) {
            throw new RuntimeException("Email déjà utilisé");
        }

        User user = new User();
        user.setNom(request.getNom());
        user.setPrenom(request.getPrenom());
        user.setEmail(request.getEmail());
        user.setMotDePasse(request.getMotDePasse()); // NOTE: Devrait être hashé en prod (BCrypt)
        user.setRole(request.getRole());

        User savedUser = userRepository.save(user);
        return mapToDTO(savedUser);
    }

    public UserDTO login(LoginRequest request) {
        Optional<User> userOpt = userRepository.findByEmail(request.getEmail());
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            if (user.getMotDePasse().equals(request.getMotDePasse())) {
                return mapToDTO(user);
            }
        }
        throw new RuntimeException("Identifiants invalides");
    }

    private UserDTO mapToDTO(User user) {
        UserDTO dto = new UserDTO();
        dto.setId(user.getId());
        dto.setNom(user.getNom());
        dto.setPrenom(user.getPrenom());
        dto.setEmail(user.getEmail());
        dto.setRole(user.getRole());
        return dto;
    }
}
