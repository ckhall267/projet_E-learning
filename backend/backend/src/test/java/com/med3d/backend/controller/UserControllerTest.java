package com.med3d.backend.controller;

import com.med3d.backend.model.Role;
import com.med3d.backend.model.User;
import com.med3d.backend.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;
import com.fasterxml.jackson.databind.ObjectMapper;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class UserControllerTest {

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
    @WithMockUser(roles = "ADMIN")
    void testGetAllUsers_Success() throws Exception {
        User user1 = new User();
        user1.setNom("User1");
        user1.setPrenom("Test");
        user1.setEmail("user1@example.com");
        user1.setMotDePasse(passwordEncoder.encode("password"));
        user1.setRole(Role.Etudiant);
        userRepository.save(user1);

        User user2 = new User();
        user2.setNom("User2");
        user2.setPrenom("Test");
        user2.setEmail("user2@example.com");
        user2.setMotDePasse(passwordEncoder.encode("password"));
        user2.setRole(Role.Professeur);
        userRepository.save(user2);

        mockMvc.perform(get("/api/users")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].email").exists())
                .andExpect(jsonPath("$[1].email").exists());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testGetUserById_Success() throws Exception {
        User user = new User();
        user.setNom("Test");
        user.setPrenom("User");
        user.setEmail("byid@example.com");
        user.setMotDePasse(passwordEncoder.encode("password"));
        user.setRole(Role.Etudiant);
        User savedUser = userRepository.save(user);

        mockMvc.perform(get("/api/users/" + savedUser.getId())
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value("byid@example.com"));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testGetUserById_NotFound() throws Exception {
        mockMvc.perform(get("/api/users/99999")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testCreateUser_Success() throws Exception {
        String userJson = "{\"nom\": \"New\", \"prenom\": \"User\", \"email\": \"newuser@example.com\", \"motDePasse\": \"password123\", \"role\": \"Etudiant\"}";

        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(userJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.email").value("newuser@example.com"));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testCreateUser_DuplicateEmail() throws Exception {
        User existingUser = new User();
        existingUser.setNom("Existing");
        existingUser.setPrenom("User");
        existingUser.setEmail("duplicate@example.com");
        existingUser.setMotDePasse(passwordEncoder.encode("password"));
        existingUser.setRole(Role.Etudiant);
        userRepository.save(existingUser);

        String userJson = "{\"nom\": \"New\", \"prenom\": \"User\", \"email\": \"duplicate@example.com\", \"motDePasse\": \"password123\", \"role\": \"Etudiant\"}";

        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(userJson))
                .andExpect(status().isBadRequest());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testUpdateUser_Success() throws Exception {
        User user = new User();
        user.setNom("Original");
        user.setPrenom("Name");
        user.setEmail("update@example.com");
        user.setMotDePasse(passwordEncoder.encode("password"));
        user.setRole(Role.Etudiant);
        User savedUser = userRepository.save(user);

        String updateJson = "{\"nom\": \"Updated\", \"prenom\": \"Name\", \"email\": \"updated@example.com\", \"role\": \"Professeur\"}";

        mockMvc.perform(put("/api/users/" + savedUser.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .content(updateJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.nom").value("Updated"))
                .andExpect(jsonPath("$.role").value("Professeur"));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testUpdateUser_NotFound() throws Exception {
        String updateJson = "{\"nom\": \"Updated\", \"prenom\": \"Name\", \"email\": \"updated@example.com\", \"role\": \"Professeur\"}";

        mockMvc.perform(put("/api/users/99999")
                .contentType(MediaType.APPLICATION_JSON)
                .content(updateJson))
                .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testDeleteUser_Success() throws Exception {
        User user = new User();
        user.setNom("Delete");
        user.setPrenom("User");
        user.setEmail("delete@example.com");
        user.setMotDePasse(passwordEncoder.encode("password"));
        user.setRole(Role.Etudiant);
        User savedUser = userRepository.save(user);

        mockMvc.perform(delete("/api/users/" + savedUser.getId())
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testDeleteUser_NotFound() throws Exception {
        mockMvc.perform(delete("/api/users/99999")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testGetUsersByRole_Success() throws Exception {
        User student = new User();
        student.setNom("Student");
        student.setPrenom("User");
        student.setEmail("student@example.com");
        student.setMotDePasse(passwordEncoder.encode("password"));
        student.setRole(Role.Etudiant);
        userRepository.save(student);

        mockMvc.perform(get("/api/users/role/Etudiant")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].role").value("Etudiant"));
    }
}
