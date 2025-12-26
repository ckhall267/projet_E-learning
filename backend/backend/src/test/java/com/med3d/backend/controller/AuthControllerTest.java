package com.med3d.backend.controller;

import com.med3d.backend.model.Role;
import com.med3d.backend.model.User;
import com.med3d.backend.repository.UserRepository;
import com.med3d.backend.security.RegisterRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;
import com.fasterxml.jackson.databind.ObjectMapper;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class AuthControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() {
        userRepository.deleteAll();
    }

    @Test
    void testRegister_Success() throws Exception {
        RegisterRequest registerRequest = new RegisterRequest();
        registerRequest.setNom("Test");
        registerRequest.setPrenom("User");
        registerRequest.setEmail("test@example.com");
        registerRequest.setMotDePasse("password123");
        registerRequest.setRole(Role.Etudiant);

        mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(registerRequest)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").value("User registered successfully!"));
    }

    @Test
    void testRegister_DuplicateEmail() throws Exception {
        User existingUser = new User();
        existingUser.setNom("Existing");
        existingUser.setPrenom("User");
        existingUser.setEmail("duplicate@example.com");
        existingUser.setMotDePasse(passwordEncoder.encode("password123"));
        existingUser.setRole(Role.Etudiant);
        userRepository.save(existingUser);

        RegisterRequest registerRequest = new RegisterRequest();
        registerRequest.setNom("Test");
        registerRequest.setPrenom("User");
        registerRequest.setEmail("duplicate@example.com");
        registerRequest.setMotDePasse("password123");
        registerRequest.setRole(Role.Etudiant);

        mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(registerRequest)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void testRegister_MissingEmail() throws Exception {
        RegisterRequest registerRequest = new RegisterRequest();
        registerRequest.setNom("Test");
        registerRequest.setPrenom("User");
        registerRequest.setEmail("");
        registerRequest.setMotDePasse("password123");
        registerRequest.setRole(Role.Etudiant);

        mockMvc.perform(post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(registerRequest)))
                .andExpect(status().isBadRequest());
    }

    @Test
    void testLogin_Success() throws Exception {
        User user = new User();
        user.setNom("Test");
        user.setPrenom("User");
        user.setEmail("login@example.com");
        user.setMotDePasse(passwordEncoder.encode("password123"));
        user.setRole(Role.Etudiant);
        userRepository.save(user);

        String loginRequest = "{\"email\": \"login@example.com\", \"password\": \"password123\"}";

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(loginRequest))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.jwt").exists())
                .andExpect(jsonPath("$.email").value("login@example.com"));
    }

    @Test
    void testLogin_InvalidEmail() throws Exception {
        String loginRequest = "{\"email\": \"nonexistent@example.com\", \"password\": \"password123\"}";

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(loginRequest))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void testLogin_WrongPassword() throws Exception {
        User user = new User();
        user.setNom("Test");
        user.setPrenom("User");
        user.setEmail("wrongpass@example.com");
        user.setMotDePasse(passwordEncoder.encode("correctPassword"));
        user.setRole(Role.Etudiant);
        userRepository.save(user);

        String loginRequest = "{\"email\": \"wrongpass@example.com\", \"password\": \"wrongPassword\"}";

        mockMvc.perform(post("/api/auth/login")
                .contentType(MediaType.APPLICATION_JSON)
                .content(loginRequest))
                .andExpect(status().isUnauthorized());
    }
}
