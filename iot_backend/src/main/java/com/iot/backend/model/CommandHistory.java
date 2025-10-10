package com.iot.backend.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "command_history")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class CommandHistory {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "device_id", nullable = false, length = 100)
    private String deviceId;
    
    @Column(nullable = false, length = 50)
    private String command;
    
    @Column(name = "device_type", length = 50)
    private String deviceType;
    
    @Column(name = "previous_state", length = 50)
    private String previousState;
    
    @Column(name = "new_state", length = 50)
    private String newState;
    
    @Column(length = 100)
    private String source;
    
    @Column(name = "executed_at")
    private LocalDateTime executedAt;
    
    private Boolean success = true;
    
    @PrePersist
    protected void onCreate() {
        if (executedAt == null) {
            executedAt = LocalDateTime.now();
        }
        if (success == null) {
            success = true;
        }
    }
}

