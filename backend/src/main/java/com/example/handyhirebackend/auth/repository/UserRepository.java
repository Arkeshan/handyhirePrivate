package com.example.handyhirebackend.auth.repository;

import com.example.handyhirebackend.auth.model.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    List<User> findByRolesContaining(String role);
    List<User> findByIsVerifiedFalse();
}
