package com.med3d.backend.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TentativeSimulation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Étudiant qui a effectué la simulation
    @ManyToOne
    private User etudiant;

    // Cas clinique sur lequel porte la simulation
    @ManyToOne
    private CasClinique casClinique;

    // TP auquel appartient cette simulation
    @ManyToOne
    private TravailPratique travailPratique;

    // Score obtenu (sur 20)
    private Double score;

    // Diagnostic donné par l'étudiant
    private String diagnostic;

    // Date/heure de fin de simulation
    private LocalDateTime dateCompletion;
}
