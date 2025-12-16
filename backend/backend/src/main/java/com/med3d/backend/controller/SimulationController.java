package com.med3d.backend.controller;

import com.med3d.backend.dto.TentativeSimulationDTO;
import com.med3d.backend.service.SimulationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/simulation")
@CrossOrigin("*")
public class SimulationController {

    @Autowired
    private SimulationService simulationService;

    @PostMapping("/attempt")
    public ResponseEntity<TentativeSimulationDTO> submitAttempt(@RequestBody TentativeSimulationDTO attempt) {
        return ResponseEntity.ok(simulationService.enregistrerTentative(attempt));
    }
}
