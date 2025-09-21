package com.example.demo.service;

import com.example.demo.domain.UserAccount;
import com.example.demo.domain.UserAccountRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

@Service @RequiredArgsConstructor
public class AuthService {
    private final UserAccountRepository repo;
    private final BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();

    public UserAccount authenticate(String username, String rawPassword) {
        return repo.findByUsername(username)
                .filter(u -> encoder.matches(rawPassword, u.getPasswordHash()))
                .orElse(null);
    }
}
