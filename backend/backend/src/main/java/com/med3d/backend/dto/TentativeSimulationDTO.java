package com.med3d.backend.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class TentativeSimulationDTO {
    private Long id;
    private Long etudiantId;
    private Long casCliniqueId;
    private Double score;
    private String diagnostic;
    private LocalDateTime dateCompletion;
    private boolean isSuccess; // calculated field based on score or logic
}
