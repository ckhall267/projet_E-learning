package com.med3d.backend.controller;

import com.med3d.backend.dto.CasCliniqueDTO;
import com.med3d.backend.service.CasCliniqueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.List;

@RestController
@RequestMapping("/api/cases")
@CrossOrigin("*")
public class CasCliniqueController {

    @Autowired
    private CasCliniqueService casCliniqueService;

    @GetMapping
    public ResponseEntity<List<CasCliniqueDTO>> getAllCases() {
        return ResponseEntity.ok(casCliniqueService.getAllCases());
    }

    @GetMapping("/{id}")
    public ResponseEntity<CasCliniqueDTO> getCaseById(@PathVariable Long id) {
        return ResponseEntity.ok(casCliniqueService.getCaseById(id));
    }

    @PostMapping
    public ResponseEntity<CasCliniqueDTO> createCase(@RequestBody CasCliniqueDTO dto) {
        if (dto.getTitre() == null || dto.getTitre().isBlank()) {
            return ResponseEntity.badRequest().build();
        }
        return ResponseEntity.ok(casCliniqueService.createCase(dto));
    }

    @PutMapping("/{id}")
    public ResponseEntity<CasCliniqueDTO> updateCase(@PathVariable Long id, @RequestBody CasCliniqueDTO dto) {
        return ResponseEntity.ok(casCliniqueService.updateCase(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteCase(@PathVariable Long id) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        boolean isAdmin = auth.getAuthorities().stream()
                .anyMatch(a -> a.getAuthority().equals("ROLE_ADMIN"));
        if (!isAdmin) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }

        casCliniqueService.deleteCase(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/tp/{tpId}")
    public ResponseEntity<List<CasCliniqueDTO>> getCasesByTp(@PathVariable Long tpId) {
        return ResponseEntity.ok(casCliniqueService.getCasesByTravailPratique(tpId));
    }

    @GetMapping("/search")
    public ResponseEntity<List<CasCliniqueDTO>> searchCases(@RequestParam("titre") String titre) {
        List<CasCliniqueDTO> results = casCliniqueService.searchByTitre(titre);
        if (results.isEmpty()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).build();
        }
        return ResponseEntity.ok(results);
    }
}
