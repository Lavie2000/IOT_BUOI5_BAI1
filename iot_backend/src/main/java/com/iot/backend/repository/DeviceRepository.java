package com.iot.backend.repository;

import com.iot.backend.model.Device;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface DeviceRepository extends JpaRepository<Device, Long> {
    
    Optional<Device> findByDeviceId(String deviceId);
    
    boolean existsByDeviceId(String deviceId);
}

