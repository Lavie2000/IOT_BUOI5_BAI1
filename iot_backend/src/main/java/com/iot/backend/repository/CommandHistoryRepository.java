package com.iot.backend.repository;

import com.iot.backend.model.CommandHistory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CommandHistoryRepository extends JpaRepository<CommandHistory, Long> {
    
    List<CommandHistory> findByDeviceIdOrderByExecutedAtDesc(String deviceId);
    
    @Query("SELECT c FROM CommandHistory c ORDER BY c.executedAt DESC LIMIT 50")
    List<CommandHistory> findTop50ByOrderByExecutedAtDesc();
}

