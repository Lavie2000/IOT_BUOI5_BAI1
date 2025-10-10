package com.iot.backend.controller;

import com.iot.backend.model.SensorData;
import com.iot.backend.service.SensorDataService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@Slf4j
@RestController
@RequestMapping("/api/sensor")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class SensorDataController {
    
    private final SensorDataService sensorDataService;
    
    /**
     * Get latest sensor data for a specific device
     * GET /api/sensor/device/{deviceId}?limit=50
     */
    @GetMapping("/device/{deviceId}")
    public ResponseEntity<List<SensorData>> getDeviceSensorData(
            @PathVariable String deviceId,
            @RequestParam(defaultValue = "50") int limit) {
        
        log.info("GET /api/sensor/device/{} - limit: {}", deviceId, limit);
        List<SensorData> data = sensorDataService.getLatestSensorData(deviceId, limit);
        return ResponseEntity.ok(data);
    }
    
    /**
     * Get sensor data within time range
     * GET /api/sensor/device/{deviceId}/range?start=2025-10-10T00:00:00&end=2025-10-10T23:59:59
     */
    @GetMapping("/device/{deviceId}/range")
    public ResponseEntity<List<SensorData>> getSensorDataInRange(
            @PathVariable String deviceId,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime start,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME) LocalDateTime end) {
        
        log.info("GET /api/sensor/device/{}/range - start: {}, end: {}", deviceId, start, end);
        List<SensorData> data = sensorDataService.getSensorDataInRange(deviceId, start, end);
        return ResponseEntity.ok(data);
    }
    
    /**
     * Get latest sensor data across all devices
     * GET /api/sensor/latest
     */
    @GetMapping("/latest")
    public ResponseEntity<List<SensorData>> getLatestAllDevices() {
        log.info("GET /api/sensor/latest");
        List<SensorData> data = sensorDataService.getLatestAllDevices();
        return ResponseEntity.ok(data);
    }
}

