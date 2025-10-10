package com.iot.backend.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.eclipse.paho.client.mqttv3.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.PreDestroy;
import java.util.HashMap;
import java.util.Map;

@Service
public class MqttService {
    
    private static final Logger logger = LoggerFactory.getLogger(MqttService.class);
    
    @Value("${mqtt.broker-url}")
    private String brokerUrl;
    
    @Value("${mqtt.username}")
    private String username;
    
    @Value("${mqtt.password}")
    private String password;
    
    @Value("${mqtt.client-id}")
    private String clientId;
    
    @Value("${mqtt.topic.device-state}")
    private String topicDeviceState;
    
    @Value("${mqtt.topic.sys-online}")
    private String topicSysOnline;
    
    @Value("${mqtt.topic.device-cmd}")
    private String topicDeviceCmd;
    
    @Value("${mqtt.topic.sensor-state}")
    private String topicSensorState;
    
    @Autowired
    private DeviceService deviceService;
    
    @Autowired
    private SensorDataService sensorDataService;
    
    private MqttClient mqttClient;
    private final ObjectMapper objectMapper = new ObjectMapper();
    
    @PostConstruct
    public void connect() {
        try {
            mqttClient = new MqttClient(brokerUrl, clientId);
            
            MqttConnectOptions options = new MqttConnectOptions();
            options.setUserName(username);
            options.setPassword(password.toCharArray());
            options.setAutomaticReconnect(true);
            options.setCleanSession(false);
            options.setKeepAliveInterval(60);
            
            // Set callback before connecting
            mqttClient.setCallback(new MqttCallback() {
                @Override
                public void messageArrived(String topic, MqttMessage message) {
                    handleMessage(topic, new String(message.getPayload()));
                }
                
                @Override
                public void connectionLost(Throwable cause) {
                    logger.error("MQTT Connection lost: {}", cause.getMessage());
                }
                
                @Override
                public void deliveryComplete(IMqttDeliveryToken token) {
                    // Not used for subscriber
                }
            });
            
            mqttClient.connect(options);
            
            // Subscribe to topics
            mqttClient.subscribe(topicDeviceState, 1);
            mqttClient.subscribe(topicSysOnline, 1);
            mqttClient.subscribe(topicSensorState, 0); // QoS 0 for sensor data
            
            logger.info("✅ MQTT Backend connected successfully to {}", brokerUrl);
            logger.info("   Subscribed to: {}", topicDeviceState);
            logger.info("   Subscribed to: {}", topicSysOnline);
            logger.info("   Subscribed to: {}", topicSensorState);
            
        } catch (Exception e) {
            logger.error("Failed to connect to MQTT broker: {}", e.getMessage(), e);
        }
    }
    
    private void handleMessage(String topic, String payload) {
        try {
            logger.debug("MQTT message received on topic '{}': {}", topic, payload);
            
            @SuppressWarnings("unchecked")
            Map<String, Object> data = objectMapper.readValue(payload, Map.class);
            
            if (topic.equals(topicDeviceState)) {
                // Update device state in database
                deviceService.updateDeviceState(data);
            } else if (topic.equals(topicSensorState)) {
                // Save sensor data to database
                saveSensorData(data);
            } else if (topic.equals(topicSysOnline)) {
                // Update online status
                deviceService.updateOnlineStatus(data);
            }
        } catch (Exception e) {
            logger.error("Error handling MQTT message: {}", e.getMessage(), e);
        }
    }
    
    public void publishCommand(String deviceType, String action) {
        try {
            if (mqttClient == null || !mqttClient.isConnected()) {
                logger.warn("MQTT client not connected. Cannot publish command.");
                return;
            }
            
            Map<String, String> command = new HashMap<>();
            command.put(deviceType, action);
            
            String json = objectMapper.writeValueAsString(command);
            MqttMessage message = new MqttMessage(json.getBytes());
            message.setQos(1);
            message.setRetained(false);
            
            mqttClient.publish(topicDeviceCmd, message);
            logger.info("Command published: {} -> {}", deviceType, action);
            
        } catch (Exception e) {
            logger.error("Error publishing command: {}", e.getMessage(), e);
        }
    }
    
    private void saveSensorData(Map<String, Object> data) {
        try {
            // Extract sensor values from MQTT payload
            // Expected format: {"temp_c": 25.5, "hum_pct": 60.0, "ts": 123456}
            Number tempNum = (Number) data.get("temp_c");
            Number humNum = (Number) data.get("hum_pct");
            
            if (tempNum != null && humNum != null) {
                java.math.BigDecimal temperature = java.math.BigDecimal.valueOf(tempNum.doubleValue());
                java.math.BigDecimal humidity = java.math.BigDecimal.valueOf(humNum.doubleValue());
                
                // Assume device_id is esp32_demo_001 (can be extracted from topic if needed)
                String deviceId = "esp32_demo_001";
                
                sensorDataService.saveSensorData(deviceId, temperature, humidity, null);
                logger.debug("Saved sensor data: temp={}, hum={}", temperature, humidity);
            }
        } catch (Exception e) {
            logger.error("Error saving sensor data: {}", e.getMessage());
        }
    }
    
    @PreDestroy
    public void disconnect() {
        try {
            if (mqttClient != null && mqttClient.isConnected()) {
                mqttClient.disconnect();
                mqttClient.close();
                logger.info("MQTT client disconnected");
            }
        } catch (Exception e) {
            logger.error("Error disconnecting MQTT client: {}", e.getMessage(), e);
        }
    }
}

