package com.med3d.backend.controller;

import com.med3d.backend.model.CasClinique;
import com.med3d.backend.model.TravailPratique;
import com.med3d.backend.repository.CasCliniqueRepository;
import com.med3d.backend.repository.TravailPratiqueRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.test.web.servlet.MockMvc;
import com.fasterxml.jackson.databind.ObjectMapper;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class CasCliniqueControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private CasCliniqueRepository casCliniqueRepository;

    @Autowired
    private TravailPratiqueRepository travailPratiqueRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() {
        casCliniqueRepository.deleteAll();
        travailPratiqueRepository.deleteAll();
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testGetAllCasCliniques_Success() throws Exception {
        TravailPratique tp = new TravailPratique();
        tp.setTitre("Cardiology TP");
        TravailPratique savedTp = travailPratiqueRepository.save(tp);

        CasClinique cas1 = new CasClinique();
        cas1.setTitre("Heart Case 1");
        cas1.setDescription("Patient with chest pain");
        cas1.setTravailPratique(savedTp);
        casCliniqueRepository.save(cas1);

        CasClinique cas2 = new CasClinique();
        cas2.setTitre("Heart Case 2");
        cas2.setDescription("Patient with arrhythmia");
        cas2.setTravailPratique(savedTp);
        casCliniqueRepository.save(cas2);

        mockMvc.perform(get("/api/cases")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].titre").exists())
                .andExpect(jsonPath("$[1].titre").exists());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testGetCasCliniqueById_Success() throws Exception {
        TravailPratique tp = new TravailPratique();
        tp.setTitre("Surgery TP");
        TravailPratique savedTp = travailPratiqueRepository.save(tp);

        CasClinique cas = new CasClinique();
        cas.setTitre("Surgery Case");
        cas.setDescription("Complex surgical case");
        cas.setTravailPratique(savedTp);
        CasClinique saved = casCliniqueRepository.save(cas);

        mockMvc.perform(get("/api/cases/" + saved.getId())
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.titre").value("Surgery Case"));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testGetCasCliniqueById_NotFound() throws Exception {
        mockMvc.perform(get("/api/cases/99999")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser(roles = "ADMIN")   
    void testCreateCasClinique_Success() throws Exception {
        TravailPratique tp = new TravailPratique();
        tp.setTitre("Neurology TP");
        TravailPratique savedTp = travailPratiqueRepository.save(tp);

        String casJson = "{\"titre\": \"New Case\", \"description\": \"New clinical case\", \"travailPratiqueId\": " + savedTp.getId() + "}";

        mockMvc.perform(post("/api/cases")
                .contentType(MediaType.APPLICATION_JSON)
                .content(casJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.titre").value("New Case"));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testCreateCasClinique_MissingTitle() throws Exception {
        String casJson = "{\"description\": \"Missing title\"}";

        mockMvc.perform(post("/api/cases")
                .contentType(MediaType.APPLICATION_JSON)
                .content(casJson))
                .andExpect(status().isBadRequest());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testUpdateCasClinique_Success() throws Exception {
        TravailPratique tp = new TravailPratique();
        tp.setTitre("Pediatrics TP");
        TravailPratique savedTp = travailPratiqueRepository.save(tp);

        CasClinique cas = new CasClinique();
        cas.setTitre("Original Case");
        cas.setDescription("Original description");
        cas.setTravailPratique(savedTp);
        CasClinique saved = casCliniqueRepository.save(cas);

        String updateJson = "{\"titre\": \"Updated Case\", \"description\": \"Updated description\"}";

        mockMvc.perform(put("/api/cases/" + saved.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .content(updateJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.titre").value("Updated Case"));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testUpdateCasClinique_NotFound() throws Exception {
        String updateJson = "{\"titre\": \"Updated\", \"description\": \"Updated\"}";

        mockMvc.perform(put("/api/cases/99999")
                .contentType(MediaType.APPLICATION_JSON)
                .content(updateJson))
                .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testDeleteCasClinique_Success() throws Exception {
        TravailPratique tp = new TravailPratique();
        tp.setTitre("Oncology TP");
        TravailPratique savedTp = travailPratiqueRepository.save(tp);

        CasClinique cas = new CasClinique();
        cas.setTitre("Delete Case");
        cas.setDescription("To delete");
        cas.setTravailPratique(savedTp);
        CasClinique saved = casCliniqueRepository.save(cas);

        mockMvc.perform(delete("/api/cases/" + saved.getId())
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testDeleteCasClinique_NotFound() throws Exception {
        mockMvc.perform(delete("/api/cases/99999")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser(roles = "STUDENT")
    void testDeleteCasClinique_AsStudent_Forbidden() throws Exception {
        TravailPratique tp = new TravailPratique();
        tp.setTitre("Test TP");
        TravailPratique savedTp = travailPratiqueRepository.save(tp);

        CasClinique cas = new CasClinique();
        cas.setTitre("Forbidden Delete");
        cas.setDescription("No permission");
        cas.setTravailPratique(savedTp);
        CasClinique saved = casCliniqueRepository.save(cas);

        mockMvc.perform(delete("/api/cases/" + saved.getId())
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isForbidden());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testGetCasesByTravailPratique_Success() throws Exception {
        TravailPratique tp = new TravailPratique();
        tp.setTitre("Ophthalmology TP");
        TravailPratique savedTp = travailPratiqueRepository.save(tp);

        CasClinique cas = new CasClinique();
        cas.setTitre("Eye Case");
        cas.setDescription("Vision problem");
        cas.setTravailPratique(savedTp);
        casCliniqueRepository.save(cas);

        mockMvc.perform(get("/api/cases/tp/" + savedTp.getId())
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].titre").value("Eye Case"));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testSearchCasClinique_ByTitle() throws Exception {
        TravailPratique tp = new TravailPratique();
        tp.setTitre("Dermatology TP");
        TravailPratique savedTp = travailPratiqueRepository.save(tp);

        CasClinique cas = new CasClinique();
        cas.setTitre("Skin Lesion Case");
        cas.setDescription("Suspicious lesion");
        cas.setTravailPratique(savedTp);
        casCliniqueRepository.save(cas);

        mockMvc.perform(get("/api/cases/search?titre=Skin")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].titre").value("Skin Lesion Case"));
    }
}
