-- IoT Smart Home Database Schema
-- Auto-run when PostgreSQL container starts

-- ==========================================
-- Table: devices
-- ==========================================
CREATE TABLE IF NOT EXISTS devices (
    id BIGSERIAL PRIMARY KEY,
    device_id VARCHAR(100) UNIQUE NOT NULL,
    device_name VARCHAR(200) NOT NULL,
    device_type VARCHAR(50) NOT NULL,
    location VARCHAR(100),
    status VARCHAR(50) DEFAULT 'offline',
    current_state VARCHAR(50),
    firmware VARCHAR(100),
    rssi INTEGER,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_seen TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==========================================
-- Table: command_history
-- ==========================================
CREATE TABLE IF NOT EXISTS command_history (
    id BIGSERIAL PRIMARY KEY,
    device_id VARCHAR(100) NOT NULL,
    command VARCHAR(50) NOT NULL,
    device_type VARCHAR(50),
    previous_state VARCHAR(50),
    new_state VARCHAR(50),
    source VARCHAR(100),
    executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    success BOOLEAN DEFAULT TRUE
);

-- ==========================================
-- Indexes for performance
-- ==========================================
CREATE INDEX IF NOT EXISTS idx_device_id ON devices(device_id);
CREATE INDEX IF NOT EXISTS idx_device_status ON devices(status);
CREATE INDEX IF NOT EXISTS idx_device_type ON devices(device_type);
CREATE INDEX IF NOT EXISTS idx_command_device ON command_history(device_id);
CREATE INDEX IF NOT EXISTS idx_command_time ON command_history(executed_at DESC);
CREATE INDEX IF NOT EXISTS idx_command_source ON command_history(source);

-- ==========================================
-- Insert sample data
-- ==========================================
INSERT INTO devices (device_id, device_name, device_type, location, status, current_state, firmware, rssi)
VALUES 
    ('esp32_demo_001', 'Living Room Light', 'light', 'room1', 'online', 'off', 'demo1-1.0.0', -45),
    ('esp32_demo_002', 'Bedroom Fan', 'fan', 'room2', 'offline', 'off', 'demo1-1.0.0', -52)
ON CONFLICT (device_id) DO NOTHING;

-- ==========================================
-- Insert sample command history
-- ==========================================
INSERT INTO command_history (device_id, command, device_type, previous_state, new_state, source, success)
VALUES 
    ('esp32_demo_001', 'on', 'light', 'off', 'on', 'flutter_app', true),
    ('esp32_demo_001', 'off', 'light', 'on', 'off', 'web_dashboard', true)
ON CONFLICT DO NOTHING;

