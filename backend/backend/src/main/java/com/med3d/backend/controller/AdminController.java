package com.med3d.backend.controller;

import com.med3d.backend.model.Role;
import com.med3d.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    @Autowired
    private UserRepository userRepository;

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Long>> getStats() {
        long studentCount = userRepository.countByRole(Role.Etudiant);
        long professorCount = userRepository.countByRole(Role.Professeur);

        Map<String, Long> stats = new HashMap<>();
        stats.put("studentCount", studentCount);
        stats.put("professorCount", professorCount);

        return ResponseEntity.ok(stats);
    }
}
