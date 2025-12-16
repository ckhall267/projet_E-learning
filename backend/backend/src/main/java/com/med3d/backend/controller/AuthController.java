package com.med3d.backend.controller;

import com.med3d.backend.security.AuthenticationRequest;
import com.med3d.backend.security.AuthenticationResponse;
import com.med3d.backend.security.CustomUserDetailsService;
import com.med3d.backend.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private CustomUserDetailsService userDetailsService;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private com.med3d.backend.repository.UserRepository userRepository;

    @Autowired
    private org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;

    @PostMapping("/login")
    public ResponseEntity<?> createAuthenticationToken(@RequestBody AuthenticationRequest authenticationRequest)
            throws Exception {
        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(authenticationRequest.getEmail(),
                            authenticationRequest.getPassword()));
        } catch (BadCredentialsException e) {
            throw new Exception("Incorrect username or password", e);
        }

        final UserDetails userDetails = userDetailsService
                .loadUserByUsername(authenticationRequest.getEmail());

        final String jwt = jwtUtil.generateToken(userDetails);

        // Fetch full user to get role
        com.med3d.backend.model.User user = userRepository.findByEmail(authenticationRequest.getEmail()).orElseThrow();

        return ResponseEntity
                .ok(new AuthenticationResponse(jwt, user.getRole().name(), user.getNom(), user.getPrenom()));
    }

    @PostMapping("/register")
    public ResponseEntity<?> registerUser(@RequestBody com.med3d.backend.security.RegisterRequest registerRequest) {
        if (userRepository.findByEmail(registerRequest.getEmail()).isPresent()) {
            return ResponseEntity.badRequest().body("Error: Email is already in use!");
        }

        com.med3d.backend.model.User user = new com.med3d.backend.model.User();
        user.setNom(registerRequest.getNom());
        user.setPrenom(registerRequest.getPrenom());
        user.setEmail(registerRequest.getEmail());
        user.setMotDePasse(passwordEncoder.encode(registerRequest.getMotDePasse()));
        user.setRole(registerRequest.getRole());
        user.setQrToken(java.util.UUID.randomUUID().toString());

        userRepository.save(user);

        return ResponseEntity.ok("User registered successfully!");
    }

    @PostMapping("/qr-login")
    public ResponseEntity<?> loginWithQr(@RequestBody com.med3d.backend.security.QrLoginRequest qrLoginRequest) {
        com.med3d.backend.model.User user = userRepository.findByQrToken(qrLoginRequest.getQrToken())
                .orElseThrow(() -> new RuntimeException("Invalid QR Token"));

        final UserDetails userDetails = userDetailsService.loadUserByUsername(user.getEmail());
        final String jwt = jwtUtil.generateToken(userDetails);

        return ResponseEntity
                .ok(new AuthenticationResponse(jwt, user.getRole().name(), user.getNom(), user.getPrenom()));
    }

    @org.springframework.web.bind.annotation.GetMapping("/me")
    public ResponseEntity<?> getCurrentUser() {
        org.springframework.security.core.Authentication auth = org.springframework.security.core.context.SecurityContextHolder
                .getContext().getAuthentication();
        String email = auth.getName();
        com.med3d.backend.model.User user = userRepository.findByEmail(email).orElseThrow();

        java.util.Map<String, Object> response = new java.util.HashMap<>();
        response.put("nom", user.getNom());
        response.put("prenom", user.getPrenom());
        response.put("email", user.getEmail());
        response.put("role", user.getRole());
        response.put("qrToken", user.getQrToken());

        return ResponseEntity.ok(response);
    }
}
