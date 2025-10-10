package com.iot.backend.model;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "devices")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Device {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "device_id", unique = true, nullable = false, length = 100)
    private String deviceId;
    
    @Column(name = "device_name", nullable = false, length = 200)
    private String deviceName;
    
    @Column(name = "device_type", nullable = false, length = 50)
    private String deviceType;
    
    @Column(length = 100)
    private String location;
    
    @Column(length = 50)
    private String status = "offline";
    
    @Column(name = "current_state", length = 50)
    private String currentState;
    
    @Column(length = 100)
    private String firmware;
    
    private Integer rssi;
    
    @Column(name = "registered_at")
    private LocalDateTime registeredAt;
    
    @Column(name = "last_seen")
    private LocalDateTime lastSeen;
    
    @PrePersist
    protected void onCreate() {
        if (registeredAt == null) {
            registeredAt = LocalDateTime.now();
        }
        if (lastSeen == null) {
            lastSeen = LocalDateTime.now();
        }
        if (status == null) {
            status = "offline";
        }
    }
    
    @PreUpdate
    protected void onUpdate() {
        lastSeen = LocalDateTime.now();
    }
}

