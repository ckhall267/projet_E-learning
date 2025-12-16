package com.med3d.backend.model;

import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TravailPratique {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String titre;
    @Column(columnDefinition = "TEXT")
    private String description;
    private String duration;
    @Column(columnDefinition = "TEXT")
    private String status;
    private String category;

    @ManyToOne
    private User professeur;

    @OneToMany(mappedBy = "travailPratique", cascade = CascadeType.ALL)
    private List<CasClinique> casCliniques;

    @ManyToMany
    @JoinTable(name = "tp_etudiants", joinColumns = @JoinColumn(name = "tp_id"), inverseJoinColumns = @JoinColumn(name = "etudiant_id"))
    private List<User> etudiantsAssignes;

    @OneToMany(mappedBy = "tp", cascade = CascadeType.ALL)
    private List<Note> notes;
}
