package com.med3d.backend.repository;

import com.med3d.backend.model.TentativeSimulation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TentativeSimulationRepository extends JpaRepository<TentativeSimulation, Long> {
    List<TentativeSimulation> findByEtudiantId(Long etudiantId);
    List<TentativeSimulation> findByTravailPratiqueId(Long tpId);
}
