package com.med3d.backend.controller;

import com.med3d.backend.model.TravailPratique;
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
class TravailPratiqueControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private TravailPratiqueRepository travailPratiqueRepository;

    @Autowired
    private ObjectMapper objectMapper;

    @BeforeEach
    void setUp() {
        travailPratiqueRepository.deleteAll();
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testGetAllTravailPratiques_Success() throws Exception {
        TravailPratique tp1 = new TravailPratique();
        tp1.setTitre("TP 1");
        tp1.setDescription("Description TP 1");
        travailPratiqueRepository.save(tp1);

        TravailPratique tp2 = new TravailPratique();
        tp2.setTitre("TP 2");
        tp2.setDescription("Description TP 2");
        travailPratiqueRepository.save(tp2);

        mockMvc.perform(get("/api/tps")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].titre").exists())
                .andExpect(jsonPath("$[1].titre").exists());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testGetTravailPratiqueById_Success() throws Exception {
        TravailPratique tp = new TravailPratique();
        tp.setTitre("TP Test");
        tp.setDescription("Description Test");
        TravailPratique saved = travailPratiqueRepository.save(tp);

        mockMvc.perform(get("/api/tps/" + saved.getId())
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.titre").value("TP Test"));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testGetTravailPratiqueById_NotFound() throws Exception {
        mockMvc.perform(get("/api/tps/99999")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testCreateTravailPratique_Success() throws Exception {
        String tpJson = "{\"titre\": \"New TP\", \"description\": \"New Description\", \"duree\": 120}";

        mockMvc.perform(post("/api/tps")
                .contentType(MediaType.APPLICATION_JSON)
                .content(tpJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.titre").value("New TP"));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testCreateTravailPratique_MissingTitle() throws Exception {
        String tpJson = "{\"description\": \"No Title\", \"duree\": 120}";

        mockMvc.perform(post("/api/tps")
                .contentType(MediaType.APPLICATION_JSON)
                .content(tpJson))
                .andExpect(status().isBadRequest());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testUpdateTravailPratique_Success() throws Exception {
        TravailPratique tp = new TravailPratique();
        tp.setTitre("Original Title");
        tp.setDescription("Original Description");
        TravailPratique saved = travailPratiqueRepository.save(tp);

        String updateJson = "{\"titre\": \"Updated Title\", \"description\": \"Updated Description\", \"duree\": 180}";

        mockMvc.perform(put("/api/tps/" + saved.getId())
                .contentType(MediaType.APPLICATION_JSON)
                .content(updateJson))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.titre").value("Updated Title"));
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testUpdateTravailPratique_NotFound() throws Exception {
        String updateJson = "{\"titre\": \"Updated\", \"description\": \"Updated\"}";

        mockMvc.perform(put("/api/tps/99999")
                .contentType(MediaType.APPLICATION_JSON)
                .content(updateJson))
                .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testDeleteTravailPratique_Success() throws Exception {
        TravailPratique tp = new TravailPratique();
        tp.setTitre("Delete TP");
        tp.setDescription("To Delete");
        TravailPratique saved = travailPratiqueRepository.save(tp);

        mockMvc.perform(delete("/api/tps/" + saved.getId())
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testDeleteTravailPratique_NotFound() throws Exception {
        mockMvc.perform(delete("/api/tps/99999")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isNotFound());
    }

    @Test
    @WithMockUser(roles = "PROFESSEUR")
    void testCreateTravailPratique_AsStudent_Forbidden() throws Exception {
        String tpJson = "{\"titre\": \"Unauthorized TP\", \"description\": \"No permission\"}";

        mockMvc.perform(post("/api/tps")
                .contentType(MediaType.APPLICATION_JSON)
                .content(tpJson))
                .andExpect(status().isForbidden());
    }

    @Test
    @WithMockUser(roles = "ADMIN")
    void testSearchTravailPratique_ByTitle() throws Exception {
        TravailPratique tp = new TravailPratique();
        tp.setTitre("Anatomy 101");
        tp.setDescription("Learning anatomy");
        travailPratiqueRepository.save(tp);

        mockMvc.perform(get("/api/tps/search?titre=Anatomy")
                .contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].titre").value("Anatomy 101"));
    }
}
