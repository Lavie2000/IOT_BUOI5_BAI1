package com.iot.backend.controller;

import com.iot.backend.model.Device;
import com.iot.backend.service.DeviceService;
import com.iot.backend.service.MqttService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/devices")
@CrossOrigin(origins = "*")
public class DeviceController {
    
    private static final Logger logger = LoggerFactory.getLogger(DeviceController.class);
    
    @Autowired
    private DeviceService deviceService;
    
    @Autowired
    private MqttService mqttService;
    
    @GetMapping
    public ResponseEntity<List<Device>> getAllDevices() {
        logger.info("GET /api/devices - Fetching all devices");
        List<Device> devices = deviceService.getAllDevices();
        return ResponseEntity.ok(devices);
    }
    
    @GetMapping("/{deviceId}")
    public ResponseEntity<Device> getDevice(@PathVariable String deviceId) {
        logger.info("GET /api/devices/{} - Fetching device", deviceId);
        try {
            Device device = deviceService.getDevice(deviceId);
            return ResponseEntity.ok(device);
        } catch (RuntimeException e) {
            logger.error("Device not found: {}", deviceId);
            return ResponseEntity.notFound().build();
        }
    }
    
    @PostMapping("/register")
    public ResponseEntity<?> registerDevice(@RequestBody Device device) {
        logger.info("POST /api/devices/register - Registering device: {}", device.getDeviceId());
        try {
            Device savedDevice = deviceService.registerDevice(device);
            return ResponseEntity.status(HttpStatus.CREATED).body(savedDevice);
        } catch (RuntimeException e) {
            logger.error("Error registering device: {}", e.getMessage());
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }
    
    @PutMapping("/{deviceId}")
    public ResponseEntity<?> updateDevice(
            @PathVariable String deviceId,
            @RequestBody Device device) {
        logger.info("PUT /api/devices/{} - Updating device", deviceId);
        try {
            Device existingDevice = deviceService.getDevice(deviceId);
            
            // Update fields
            if (device.getDeviceName() != null) {
                existingDevice.setDeviceName(device.getDeviceName());
            }
            if (device.getLocation() != null) {
                existingDevice.setLocation(device.getLocation());
            }
            
            return ResponseEntity.ok(existingDevice);
        } catch (RuntimeException e) {
            logger.error("Error updating device: {}", e.getMessage());
            return ResponseEntity.notFound().build();
        }
    }
    
    @DeleteMapping("/{deviceId}")
    public ResponseEntity<Void> deleteDevice(@PathVariable String deviceId) {
        logger.info("DELETE /api/devices/{} - Deleting device", deviceId);
        // Implementation for delete if needed
        return ResponseEntity.ok().build();
    }
    
    @PostMapping("/{deviceId}/control")
    public ResponseEntity<?> controlDevice(
            @PathVariable String deviceId,
            @RequestBody Map<String, String> command) {
        
        logger.info("POST /api/devices/{}/control - Command: {}", deviceId, command);
        
        try {
            String action = command.get("command");
            String deviceType = command.get("deviceType");
            String source = command.getOrDefault("source", "api");
            
            if (action == null || deviceType == null) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Missing 'command' or 'deviceType' in request"));
            }
            
            // Publish MQTT command
            mqttService.publishCommand(deviceType, action);
            
            // Log command to database
            deviceService.logCommand(deviceId, action, deviceType, source);
            
            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "deviceId", deviceId,
                    "command", action,
                    "deviceType", deviceType,
                    "source", source
            ));
            
        } catch (Exception e) {
            logger.error("Error controlling device: {}", e.getMessage(), e);
            return ResponseEntity.internalServerError()
                    .body(Map.of("error", e.getMessage()));
        }
    }
}

