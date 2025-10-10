package com.iot.backend.model;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "sensor_data")
public class SensorData {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "device_id", nullable = false, length = 100)
    private String deviceId;
    
    @Column(precision = 5, scale = 2)
    private BigDecimal temperature;
    
    @Column(precision = 5, scale = 2)
    private BigDecimal humidity;
    
    @Column(name = "light_level")
    private Integer lightLevel;
    
    @Column(name = "recorded_at")
    private LocalDateTime recordedAt;
    
    @PrePersist
    protected void onCreate() {
        if (recordedAt == null) {
            recordedAt = LocalDateTime.now();
        }
    }
}

