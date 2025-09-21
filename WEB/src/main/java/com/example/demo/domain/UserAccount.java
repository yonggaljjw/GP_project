package com.example.demo.domain;

import jakarta.persistence.*;
import lombok.*;

@Entity @Getter @Setter @NoArgsConstructor @AllArgsConstructor @Builder
@Table(name = "user_account", indexes = @Index(columnList = "username", unique = true))
public class UserAccount {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable=false, unique=true, length=50)
    private String username;

    @Column(nullable=false, length=60) // BCrypt 60자
    private String passwordHash;

    @Column(nullable=false, length=20) // "CONSUMER" or "STAFF"
    private String role;
}
