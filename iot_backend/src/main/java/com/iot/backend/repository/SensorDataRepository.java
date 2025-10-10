package com.iot.backend.repository;

import com.iot.backend.model.SensorData;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface SensorDataRepository extends JpaRepository<SensorData, Long> {
    
    // Get latest sensor data for a device
    List<SensorData> findTop50ByDeviceIdOrderByRecordedAtDesc(String deviceId);
    
    // Get all sensor data for a device
    List<SensorData> findByDeviceIdOrderByRecordedAtDesc(String deviceId);
    
    // Get sensor data within time range
    List<SensorData> findByDeviceIdAndRecordedAtBetweenOrderByRecordedAtDesc(
        String deviceId, 
        LocalDateTime start, 
        LocalDateTime end
    );
    
    // Get latest 100 records across all devices
    List<SensorData> findTop100ByOrderByRecordedAtDesc();
}

