package com.med3d.backend.repository;

import com.med3d.backend.model.TravailPratique;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TravailPratiqueRepository extends JpaRepository<TravailPratique, Long> {
    List<TravailPratique> findByProfesseurId(Long professeurId);

    List<TravailPratique> findByEtudiantsAssignesContaining(com.med3d.backend.model.User etudiant);
}
