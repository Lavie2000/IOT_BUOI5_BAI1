# IoT Smart Home Backend API

## Quick Start

### 1. Start Database (Docker)
```bash
# From project root
docker-compose up -d
```

### 2. Run Backend
```bash
cd iot_backend
mvn spring-boot:run
```

### 3. Test API
```bash
# Get all devices
curl http://localhost:8888/api/devices

# Register new device
curl -X POST http://localhost:8888/api/devices/register \
  -H "Content-Type: application/json" \
  -d '{
    "deviceId": "esp32_demo_003",
    "deviceName": "Kitchen Light",
    "deviceType": "light",
    "location": "kitchen"
  }'

# Control device
curl -X POST http://localhost:8888/api/devices/esp32_demo_001/control \
  -H "Content-Type: application/json" \
  -d '{
    "command": "toggle",
    "deviceType": "light",
    "source": "curl_test"
  }'

# Get command history
curl http://localhost:8888/api/history
```

## API Endpoints

### Device Management
- `GET /api/devices` - List all devices
- `GET /api/devices/{deviceId}` - Get device details
- `POST /api/devices/register` - Register new device
- `POST /api/devices/{deviceId}/control` - Control device

### Command History
- `GET /api/history` - All command history (last 50)
- `GET /api/history/device/{deviceId}` - Device-specific history

## Configuration

Edit `src/main/resources/application.yml`:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/iot_smart_home
    username: postgres
    password: postgres

mqtt:
  broker-url: tcp://192.168.43.108:1883
  username: admin
  password: public
```

## Database Access

- **Adminer UI:** http://localhost:8080
- **Server:** postgres
- **Database:** iot_smart_home
- **User/Pass:** postgres/postgres

## Features

✅ REST API for device management
✅ MQTT subscriber (auto-updates DB from device state)
✅ Command history logging
✅ CORS enabled for Web & Flutter
✅ PostgreSQL persistence

