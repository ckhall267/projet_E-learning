package com.med3d.backend.controller;

import com.med3d.backend.dto.CasCliniqueDTO;
import com.med3d.backend.service.CasCliniqueService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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
        return ResponseEntity.ok(casCliniqueService.createCase(dto));
    }

    @PutMapping("/{id}")
    public ResponseEntity<CasCliniqueDTO> updateCase(@PathVariable Long id, @RequestBody CasCliniqueDTO dto) {
        return ResponseEntity.ok(casCliniqueService.updateCase(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteCase(@PathVariable Long id) {
        casCliniqueService.deleteCase(id);
        return ResponseEntity.ok().build();
    }
}
