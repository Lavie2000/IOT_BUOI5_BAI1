package com.iot.backend.service;

import com.iot.backend.model.Device;
import com.iot.backend.model.CommandHistory;
import com.iot.backend.repository.DeviceRepository;
import com.iot.backend.repository.CommandHistoryRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
public class DeviceService {
    
    private static final Logger logger = LoggerFactory.getLogger(DeviceService.class);
    
    @Autowired
    private DeviceRepository deviceRepository;
    
    @Autowired
    private CommandHistoryRepository historyRepository;
    
    public List<Device> getAllDevices() {
        return deviceRepository.findAll();
    }
    
    public Device getDevice(String deviceId) {
        return deviceRepository.findByDeviceId(deviceId)
                .orElseThrow(() -> new RuntimeException("Device not found: " + deviceId));
    }
    
    @Transactional
    public Device registerDevice(Device device) {
        if (deviceRepository.existsByDeviceId(device.getDeviceId())) {
            throw new RuntimeException("Device already exists: " + device.getDeviceId());
        }
        
        device.setRegisteredAt(LocalDateTime.now());
        device.setLastSeen(LocalDateTime.now());
        device.setStatus("offline");
        
        logger.info("Registering new device: {}", device.getDeviceId());
        return deviceRepository.save(device);
    }
    
    @Transactional
    public void logCommand(String deviceId, String command, String deviceType, String source) {
        CommandHistory history = new CommandHistory();
        history.setDeviceId(deviceId);
        history.setCommand(command);
        history.setDeviceType(deviceType);
        history.setSource(source);
        history.setSuccess(true);
        
        historyRepository.save(history);
        logger.info("Command logged: {} -> {} from {}", deviceId, command, source);
    }
    
    @Transactional
    public void updateDeviceState(Map<String, Object> mqttData) {
        // Extract device info from MQTT message
        // Assuming MQTT topic contains device_id or we use default esp32_demo_001
        String deviceId = "esp32_demo_001"; // Default for now
        
        deviceRepository.findByDeviceId(deviceId).ifPresent(device -> {
            if (mqttData.containsKey("light")) {
                device.setCurrentState(mqttData.get("light").toString());
            }
            if (mqttData.containsKey("rssi")) {
                device.setRssi(((Number) mqttData.get("rssi")).intValue());
            }
            if (mqttData.containsKey("fw")) {
                device.setFirmware(mqttData.get("fw").toString());
            }
            device.setStatus("online");
            device.setLastSeen(LocalDateTime.now());
            
            deviceRepository.save(device);
            logger.debug("Device state updated: {}", deviceId);
        });
    }
    
    @Transactional
    public void updateOnlineStatus(Map<String, Object> mqttData) {
        String deviceId = "esp32_demo_001";
        
        deviceRepository.findByDeviceId(deviceId).ifPresent(device -> {
            boolean online = (Boolean) mqttData.getOrDefault("online", false);
            device.setStatus(online ? "online" : "offline");
            device.setLastSeen(LocalDateTime.now());
            
            deviceRepository.save(device);
            logger.info("Device online status updated: {} -> {}", deviceId, device.getStatus());
        });
    }
    
    public List<CommandHistory> getHistory(String deviceId) {
        return historyRepository.findByDeviceIdOrderByExecutedAtDesc(deviceId);
    }
    
    public List<CommandHistory> getLatestHistory() {
        return historyRepository.findTop50ByOrderByExecutedAtDesc();
    }
}

