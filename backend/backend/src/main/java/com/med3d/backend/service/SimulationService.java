package com.med3d.backend.service;

import com.med3d.backend.dto.TentativeSimulationDTO;
import com.med3d.backend.model.TentativeSimulation;
import com.med3d.backend.model.User;
import com.med3d.backend.model.CasClinique;
import com.med3d.backend.repository.TentativeSimulationRepository;
import com.med3d.backend.repository.UserRepository;
import com.med3d.backend.repository.CasCliniqueRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
public class SimulationService {

    @Autowired
    private TentativeSimulationRepository simulationRepository;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private CasCliniqueRepository casCliniqueRepository;

    public TentativeSimulationDTO enregistrerTentative(TentativeSimulationDTO dto) {
        User etudiant = userRepository.findById(dto.getEtudiantId())
                .orElseThrow(() -> new RuntimeException("Étudiant non trouvé"));

        CasClinique cas = casCliniqueRepository.findById(dto.getCasCliniqueId())
                .orElseThrow(() -> new RuntimeException("Cas clinique non trouvé"));

        TentativeSimulation tentative = new TentativeSimulation();
        tentative.setEtudiant(etudiant);
        tentative.setCasClinique(cas);
        tentative.setScore(dto.getScore());
        tentative.setDiagnostic(dto.getDiagnostic());
        tentative.setDateCompletion(LocalDateTime.now());

        TentativeSimulation saved = simulationRepository.save(tentative);

        dto.setId(saved.getId());
        dto.setDateCompletion(saved.getDateCompletion());
        dto.setSuccess(saved.getScore() >= 10.0); // Simple logic for success

        return dto;
    }
}
