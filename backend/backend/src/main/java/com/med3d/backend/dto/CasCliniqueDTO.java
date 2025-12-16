package com.med3d.backend.dto;

import lombok.Data;
import java.util.List;

@Data
public class CasCliniqueDTO {
    private Long id;
    private String titre;
    private String description;
    private String difficulte;
    private String diagnosticAttendu;
    private List<Integer> symptomesIds;
    private Long travailPratiqueId;
}
