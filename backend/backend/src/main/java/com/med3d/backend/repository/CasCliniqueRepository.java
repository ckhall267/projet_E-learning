package com.med3d.backend.repository;

import com.med3d.backend.model.CasClinique;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CasCliniqueRepository extends JpaRepository<CasClinique, Long> {
    List<CasClinique> findByTravailPratiqueId(Long tpId);

    List<CasClinique> findByTitreContainingIgnoreCase(String titre);
}
