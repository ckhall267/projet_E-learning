package com.med3d.backend.repository;

import com.med3d.backend.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);

    Optional<User> findByQrToken(String qrToken);

    long countByRole(com.med3d.backend.model.Role role);

    java.util.List<User> findByRole(com.med3d.backend.model.Role role);
}
