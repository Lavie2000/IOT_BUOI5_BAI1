package com.iot.backend.controller;

import com.iot.backend.model.CommandHistory;
import com.iot.backend.service.DeviceService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/history")
@CrossOrigin(origins = "*")
public class CommandHistoryController {
    
    private static final Logger logger = LoggerFactory.getLogger(CommandHistoryController.class);
    
    @Autowired
    private DeviceService deviceService;
    
    @GetMapping
    public ResponseEntity<List<CommandHistory>> getAllHistory() {
        logger.info("GET /api/history - Fetching all command history");
        List<CommandHistory> history = deviceService.getLatestHistory();
        return ResponseEntity.ok(history);
    }
    
    @GetMapping("/device/{deviceId}")
    public ResponseEntity<List<CommandHistory>> getDeviceHistory(@PathVariable String deviceId) {
        logger.info("GET /api/history/device/{} - Fetching device history", deviceId);
        List<CommandHistory> history = deviceService.getHistory(deviceId);
        return ResponseEntity.ok(history);
    }
    
    @GetMapping("/latest/{limit}")
    public ResponseEntity<List<CommandHistory>> getLatestHistory(@PathVariable int limit) {
        logger.info("GET /api/history/latest/{} - Fetching latest history", limit);
        // For now, return top 50 (can be enhanced to support custom limit)
        List<CommandHistory> history = deviceService.getLatestHistory();
        return ResponseEntity.ok(history);
    }
}

