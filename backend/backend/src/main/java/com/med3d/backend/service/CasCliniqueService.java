package com.med3d.backend.service;

import com.med3d.backend.dto.CasCliniqueDTO;
import com.med3d.backend.model.CasClinique;
import com.med3d.backend.repository.CasCliniqueRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.http.HttpStatus;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class CasCliniqueService {

    @Autowired
    private CasCliniqueRepository casCliniqueRepository;

    public List<CasCliniqueDTO> getAllCases() {
        return casCliniqueRepository.findAll().stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public CasCliniqueDTO getCaseById(Long id) {
        CasClinique cas = casCliniqueRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Cas clinique non trouvé"));
        return mapToDTO(cas);
    }

    public CasCliniqueDTO createCase(CasCliniqueDTO dto) {
        CasClinique cas = mapToEntity(dto);
        CasClinique saved = casCliniqueRepository.save(cas);
        return mapToDTO(saved);
    }

    public CasCliniqueDTO updateCase(Long id, CasCliniqueDTO dto) {
        CasClinique cas = casCliniqueRepository.findById(id)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Cas clinique non trouvé"));

        cas.setTitre(dto.getTitre());
        cas.setDescription(dto.getDescription());
        cas.setDifficulte(dto.getDifficulte());
        cas.setDiagnosticAttendu(dto.getDiagnosticAttendu());
        cas.setSymptomesIds(dto.getSymptomesIds());

        if (dto.getTravailPratiqueId() != null) {
            com.med3d.backend.model.TravailPratique tp = new com.med3d.backend.model.TravailPratique();
            tp.setId(dto.getTravailPratiqueId());
            cas.setTravailPratique(tp);
        }

        CasClinique updated = casCliniqueRepository.save(cas);
        return mapToDTO(updated);
    }

    public void deleteCase(Long id) {
        if (!casCliniqueRepository.existsById(id)) {
            throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Cas clinique non trouvé");
        }
        casCliniqueRepository.deleteById(id);
    }

    public List<CasCliniqueDTO> getCasesByTravailPratique(Long tpId) {
        return casCliniqueRepository.findByTravailPratiqueId(tpId).stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public List<CasCliniqueDTO> searchByTitre(String titre) {
        return casCliniqueRepository.findByTitreContainingIgnoreCase(titre).stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    private CasCliniqueDTO mapToDTO(CasClinique cas) {
        CasCliniqueDTO dto = new CasCliniqueDTO();
        dto.setId(cas.getId());
        dto.setTitre(cas.getTitre());
        dto.setDescription(cas.getDescription());
        dto.setDifficulte(cas.getDifficulte());
        dto.setDiagnosticAttendu(cas.getDiagnosticAttendu());
        dto.setSymptomesIds(cas.getSymptomesIds());
        if (cas.getTravailPratique() != null) {
            dto.setTravailPratiqueId(cas.getTravailPratique().getId());
        }
        return dto;
    }

    private CasClinique mapToEntity(CasCliniqueDTO dto) {
        CasClinique cas = new CasClinique();
        // L'ID est généré automatiquement lors de la création
        cas.setTitre(dto.getTitre());
        cas.setDescription(dto.getDescription());
        cas.setDifficulte(dto.getDifficulte());
        cas.setDiagnosticAttendu(dto.getDiagnosticAttendu());
        cas.setSymptomesIds(dto.getSymptomesIds());

        if (dto.getTravailPratiqueId() != null) {
            com.med3d.backend.model.TravailPratique tp = new com.med3d.backend.model.TravailPratique();
            tp.setId(dto.getTravailPratiqueId());
            cas.setTravailPratique(tp);
        }

        return cas;
    }
}
