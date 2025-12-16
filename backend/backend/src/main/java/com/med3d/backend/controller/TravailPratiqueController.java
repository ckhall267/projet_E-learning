package com.med3d.backend.controller;

import com.med3d.backend.model.TravailPratique;
import com.med3d.backend.service.TravailPratiqueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import com.med3d.backend.repository.UserRepository;
import com.med3d.backend.model.User;

import java.util.List;

@RestController
@RequestMapping("/api/tps")
@CrossOrigin("*")
public class TravailPratiqueController {

    @Autowired
    private TravailPratiqueService travailPratiqueService;

    @Autowired
    private UserRepository userRepository;

    @GetMapping
    public List<TravailPratique> getAllTravauxPratiques() {
        // Optionnel: filtrer par utilisateur connecté
        return travailPratiqueService.getAllTravauxPratiques();
    }

    @GetMapping("/my")
    public List<TravailPratique> getMyTravauxPratiques() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = auth.getName();
        User user = userRepository.findByEmail(email).orElseThrow();

        if (user.getRole() == com.med3d.backend.model.Role.Etudiant) {
            return travailPratiqueService.getTravauxPratiquesByStudent(user.getId());
        } else {
            return travailPratiqueService.getTravauxPratiquesByProfesseur(user.getId());
        }
    }

    @PostMapping
    public ResponseEntity<TravailPratique> createTravailPratique(@RequestBody TravailPratique tp) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = auth.getName();
        User user = userRepository.findByEmail(email).orElseThrow();

        return ResponseEntity.ok(travailPratiqueService.createTravailPratique(tp, user.getId()));
    }

    @PutMapping("/{id}")
    public ResponseEntity<TravailPratique> updateTravailPratique(@PathVariable Long id,
            @RequestBody TravailPratique tpDetails) {
        return ResponseEntity.ok(travailPratiqueService.updateTravailPratique(id, tpDetails));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTravailPratique(@PathVariable Long id) {
        travailPratiqueService.deleteTravailPratique(id);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{tpId}/students/{studentId}")
    public ResponseEntity<?> addStudentToTP(@PathVariable Long tpId, @PathVariable Long studentId) {
        travailPratiqueService.addStudentToTP(tpId, studentId);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{tpId}/students/{studentId}/grade")
    public ResponseEntity<?> gradeStudent(@PathVariable Long tpId, @PathVariable Long studentId,
            @RequestBody Double grade) {
        travailPratiqueService.gradeStudent(tpId, studentId, grade);
        return ResponseEntity.ok().build();
    }
}
