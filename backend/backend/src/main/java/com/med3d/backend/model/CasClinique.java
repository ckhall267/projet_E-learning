package com.med3d.backend.model;

import jakarta.persistence.*;
import lombok.*;
import com.fasterxml.jackson.annotation.JsonIgnore;

import java.util.List;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CasClinique {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String titre;
    private String description;

    // Niveau de difficulté : FACILE / MOYEN / DIFFICILE
    private String difficulte;

    // Diagnostic attendu
    private String diagnosticAttendu;

    // IDs des symptômes (simples entiers)
    @ElementCollection
    private List<Integer> symptomesIds;

    // Lien vers le TP auquel appartient ce cas clinique
    // Lien vers le TP auquel appartient ce cas clinique
    @ManyToOne
    @JsonIgnore
    @ToString.Exclude
    private TravailPratique travailPratique;
}
