package com.med3d.backend.repository;

import com.med3d.backend.model.Note;
import com.med3d.backend.model.TravailPratique;
import com.med3d.backend.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface NoteRepository extends JpaRepository<Note, Long> {
    Optional<Note> findByEtudiantAndTp(User etudiant, TravailPratique tp);
}
