package com.iot.backend.service;

import com.iot.backend.model.SensorData;
import com.iot.backend.repository.SensorDataRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class SensorDataService {
    
    private final SensorDataRepository sensorDataRepository;
    
    /**
     * Save sensor data from MQTT or API
     */
    @Transactional
    public SensorData saveSensorData(String deviceId, BigDecimal temperature, 
                                     BigDecimal humidity, Integer lightLevel) {
        SensorData data = new SensorData();
        data.setDeviceId(deviceId);
        data.setTemperature(temperature);
        data.setHumidity(humidity);
        data.setLightLevel(lightLevel);
        
        SensorData saved = sensorDataRepository.save(data);
        log.info("Saved sensor data for device: {}, temp: {}, hum: {}", 
                 deviceId, temperature, humidity);
        return saved;
    }
    
    /**
     * Get latest sensor readings for a device
     */
    public List<SensorData> getLatestSensorData(String deviceId, int limit) {
        if (limit <= 0) limit = 50;
        return sensorDataRepository.findTop50ByDeviceIdOrderByRecordedAtDesc(deviceId);
    }
    
    /**
     * Get all sensor data for a device
     */
    public List<SensorData> getAllSensorData(String deviceId) {
        return sensorDataRepository.findByDeviceIdOrderByRecordedAtDesc(deviceId);
    }
    
    /**
     * Get sensor data within time range
     */
    public List<SensorData> getSensorDataInRange(String deviceId, 
                                                  LocalDateTime start, 
                                                  LocalDateTime end) {
        return sensorDataRepository.findByDeviceIdAndRecordedAtBetweenOrderByRecordedAtDesc(
            deviceId, start, end
        );
    }
    
    /**
     * Get latest sensor data across all devices
     */
    public List<SensorData> getLatestAllDevices() {
        return sensorDataRepository.findTop100ByOrderByRecordedAtDesc();
    }
}

