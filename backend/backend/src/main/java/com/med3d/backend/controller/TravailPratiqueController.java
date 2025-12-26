package com.med3d.backend.controller;

import com.med3d.backend.model.TravailPratique;
import com.med3d.backend.service.TravailPratiqueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import com.med3d.backend.repository.UserRepository;
import com.med3d.backend.model.User;
import org.springframework.web.server.ResponseStatusException;

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

    @GetMapping("/{id}")
    public ResponseEntity<TravailPratique> getTravailPratiqueById(@PathVariable Long id) {
        return travailPratiqueService.getTravailPratiqueById(id)
                .map(ResponseEntity::ok)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "TP non trouvé"));
    }

    @GetMapping("/search")
    public List<TravailPratique> searchTravauxPratiques(@RequestParam("titre") String titre) {
        return travailPratiqueService.searchByTitre(titre);
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
        if (tp.getTitre() == null || tp.getTitre().isBlank()) {
            return ResponseEntity.badRequest().build();
        }
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        String email = auth.getName();
        boolean isAdmin = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
        if (!isAdmin) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        User user = userRepository.findByEmail(email).orElseGet(() -> {
            User fallback = new User();
            fallback.setEmail(email);
            // Map authorities to enum role
            boolean isProf = auth.getAuthorities().stream()
                    .anyMatch(a -> a.getAuthority().equals("ROLE_PROFESSEUR"));
            if (isAdmin) {
                fallback.setRole(com.med3d.backend.model.Role.Administrateur);
            } else if (isProf) {
                fallback.setRole(com.med3d.backend.model.Role.Professeur);
            } else {
                fallback.setRole(com.med3d.backend.model.Role.Etudiant);
            }
            return userRepository.save(fallback);
        });

        return ResponseEntity.ok(travailPratiqueService.createTravailPratique(tp, user.getId()));
    }

    @PutMapping("/{id}")
    public ResponseEntity<TravailPratique> updateTravailPratique(@PathVariable Long id,
            @RequestBody TravailPratique tpDetails) {
        if (!travailPratiqueService.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "TP non trouvé");
        }
        return ResponseEntity.ok(travailPratiqueService.updateTravailPratique(id, tpDetails));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTravailPratique(@PathVariable Long id) {
        if (!travailPratiqueService.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "TP non trouvé");
        }
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
