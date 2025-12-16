package com.med3d.backend.service;

import com.med3d.backend.model.TravailPratique;
import com.med3d.backend.model.User;
import com.med3d.backend.repository.TravailPratiqueRepository;
import com.med3d.backend.repository.TravailPratiqueRepository;
import com.med3d.backend.repository.UserRepository;
import com.med3d.backend.repository.NoteRepository;
import com.med3d.backend.model.Note;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class TravailPratiqueService {

    @Autowired
    private TravailPratiqueRepository travailPratiqueRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private NoteRepository noteRepository;

    public List<TravailPratique> getAllTravauxPratiques() {
        return travailPratiqueRepository.findAll();
    }

    public List<TravailPratique> getTravauxPratiquesByProfesseur(Long professeurId) {
        return travailPratiqueRepository.findByProfesseurId(professeurId);
    }

    public List<TravailPratique> getTravauxPratiquesByStudent(Long studentId) {
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Étudiant non trouvé"));
        return travailPratiqueRepository.findByEtudiantsAssignesContaining(student);
    }

    public TravailPratique createTravailPratique(TravailPratique tp, Long professeurId) {
        User professeur = userRepository.findById(professeurId)
                .orElseThrow(() -> new RuntimeException("Professeur non trouvé"));
        tp.setProfesseur(professeur);
        return travailPratiqueRepository.save(tp);
    }

    public TravailPratique updateTravailPratique(Long id, TravailPratique tpDetails) {
        TravailPratique tp = travailPratiqueRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("TP non trouvé"));

        tp.setTitre(tpDetails.getTitre());
        tp.setDescription(tpDetails.getDescription());
        tp.setDuration(tpDetails.getDuration());
        tp.setStatus(tpDetails.getStatus());
        tp.setCategory(tpDetails.getCategory());

        return travailPratiqueRepository.save(tp);
    }

    public void deleteTravailPratique(Long id) {
        travailPratiqueRepository.deleteById(id);
    }

    public Optional<TravailPratique> getTravailPratiqueById(Long id) {
        return travailPratiqueRepository.findById(id);
    }

    public void addStudentToTP(Long tpId, Long studentId) {
        TravailPratique tp = travailPratiqueRepository.findById(tpId)
                .orElseThrow(() -> new RuntimeException("TP non trouvé"));
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Étudiant non trouvé"));

        if (!tp.getEtudiantsAssignes().contains(student)) {
            tp.getEtudiantsAssignes().add(student);
            travailPratiqueRepository.save(tp);
        }
    }

    public void gradeStudent(Long tpId, Long studentId, Double grade) {
        TravailPratique tp = travailPratiqueRepository.findById(tpId)
                .orElseThrow(() -> new RuntimeException("TP non trouvé"));
        User student = userRepository.findById(studentId)
                .orElseThrow(() -> new RuntimeException("Étudiant non trouvé"));

        Note note = noteRepository.findByEtudiantAndTp(student, tp)
                .orElse(new Note());

        if (note.getId() == null) {
            note.setEtudiant(student);
            note.setTp(tp);
        }
        note.setValeur(grade);
        noteRepository.save(note);
    }
}
