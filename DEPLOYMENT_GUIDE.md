# 🚀 DEPLOYMENT GUIDE - IoT Smart Home System

## 📋 PREREQUISITES

### 1. Software Requirements
- **Docker Desktop** (for PostgreSQL)
- **Java 17+** and **Maven** (for Spring Boot)
- **Flutter SDK** 3.0+
- **Python 3.8+** (for Web server)
- **MQTT Broker** running at `192.168.43.108:1883/8083`

### 2. Network Configuration
- Ensure all devices are on the same network
- MQTT Broker accessible at `192.168.43.108`
- Ports required:
  - `5432`: PostgreSQL
  - `8080`: Adminer (Database UI)
  - `8888`: Spring Boot API
  - `3000`: Web Dashboard
  - `1883`: MQTT TCP
  - `8083`: MQTT WebSocket

---

## 🔧 STEP 1: DATABASE SETUP (5 minutes)

### Start PostgreSQL with Docker

```bash
# Navigate to project root
cd demo_chuong4_3_1-main

# Start Docker containers
docker-compose up -d

# Verify containers are running
docker ps

# Expected output:
# - iot_postgres (port 5432)
# - iot_adminer (port 8080)
```

### Verify Database

1. **Access Adminer UI:**
   - URL: http://localhost:8080
   - System: **PostgreSQL**
   - Server: **postgres**
   - Username: **postgres**
   - Password: **postgres**
   - Database: **iot_smart_home**

2. **Check Tables:**
   - `devices` (should have 2 sample rows)
   - `command_history`

---

## 🍃 STEP 2: BACKEND API SETUP (2 minutes)

### Run Spring Boot Application

```bash
# Navigate to backend directory
cd iot_backend

# Build and run
mvn spring-boot:run

# Expected output:
# ========================================
#   IoT Smart Home Backend API Started  
#   Port: 8888                           
# ========================================
# ✅ MQTT Backend connected successfully
```

### Verify Backend

**Test REST API:**
```bash
# Get all devices
curl http://localhost:8888/api/devices

# Expected: JSON array with devices
```

**Check MQTT Connection:**
- Look for log: `✅ MQTT Backend connected successfully to tcp://192.168.43.108:1883`
- Subscribed topics:
  - `lab/room1/device/state`
  - `lab/room1/sys/online`

---

## 📱 STEP 3: FLUTTER APP SETUP (2 minutes)

### Install Dependencies

```bash
cd app_flutter

# Get packages
flutter pub get
```

### Run Flutter App

**Option A: Web (Recommended for testing)**
```bash
flutter run -d web-server --web-port 8081
```

**Option B: Android/iOS Device**
```bash
flutter run -d <device-id>
```

**Option C: Chrome Browser**
```bash
flutter run -d chrome
```

### Verify Flutter App

1. ✅ MQTT Connection Status: **Connected**
2. ✅ Device Status: **Online/Offline**
3. ✅ Temperature & Humidity displayed
4. ✅ Navigate to "Devices" screen (top-right icon)
5. ✅ See registered devices list

---

## 🌐 STEP 4: WEB DASHBOARD SETUP (1 minute)

### Start Web Server

```bash
cd web/src

# Start simple HTTP server
python -m http.server 3000
```

### Access Web Dashboard

- URL: **http://localhost:3000/index.html**
- Should see:
  - ✅ MQTT Broker: Connected
  - ✅ Device: Online
  - ✅ Temperature & Humidity values
  - ✅ Control buttons (ON/OFF/TOGGLE)
  - ✅ Registered devices list

---

## 🤖 STEP 5: ESP32 SETUP (Optional)

### Upload Firmware

```bash
cd firmware_esp32s3

# Using PlatformIO
pio run -t upload

# Or using Arduino IDE
# Open src/main.cpp and upload
```

### Configuration Check

Verify in `main.cpp`:
```cpp
WIFI_SSID = "3q1"
MQTT_HOST = "192.168.43.108"
DEVICE_ID = "esp32_demo_001"
```

---

## ✅ STEP 6: END-TO-END TESTING

### Test 1: Register New Device (Flutter App)

1. Open Flutter App
2. Click **Devices** icon (top-right)
3. Click **+ Add Device** button
4. Fill form:
   - Device ID: `esp32_demo_003`
   - Device Name: `Kitchen Light`
   - Device Type: `Light`
   - Location: `Kitchen`
5. Click **REGISTER DEVICE**
6. ✅ Success message appears
7. ✅ Device appears in list
8. ✅ Refresh Web Dashboard → new device visible

### Test 2: Control Device from Flutter

1. In Flutter main screen
2. Toggle **Smart Light** switch
3. ✅ ESP32 LED changes state
4. ✅ Web Dashboard updates instantly
5. Check database:
   - Open Adminer
   - Query: `SELECT * FROM command_history ORDER BY executed_at DESC LIMIT 5`
   - ✅ New record with `source = 'flutter_app'`

### Test 3: Control Device from Web

1. Open Web Dashboard
2. Click **TOGGLE** button for Light
3. ✅ ESP32 LED changes state
4. ✅ Flutter App updates instantly
5. Check database:
   - ✅ New record with `source = 'web_dashboard'`

### Test 4: MQTT Auto-Update Database

1. ESP32 publishes device state (every 15s)
2. Backend receives MQTT message
3. Check logs: `Device state updated: esp32_demo_001`
4. Query database:
   ```sql
   SELECT * FROM devices WHERE device_id = 'esp32_demo_001';
   ```
5. ✅ `current_state`, `rssi`, `firmware` updated
6. ✅ `last_seen` timestamp recent

---

## 🎯 VERIFICATION CHECKLIST

### Database Layer
- [ ] PostgreSQL running on port 5432
- [ ] Tables created with sample data
- [ ] Adminer accessible at localhost:8080

### Backend API
- [ ] Spring Boot running on port 8888
- [ ] GET /api/devices returns device list
- [ ] MQTT client connected to broker
- [ ] Logs show MQTT subscriptions active

### Flutter App
- [ ] MQTT WebSocket connected
- [ ] Temperature/Humidity displayed
- [ ] Device list screen loads
- [ ] Register device form works
- [ ] Control toggles send MQTT + API call

### Web Dashboard
- [ ] Page loads at localhost:3000
- [ ] MQTT WebSocket connected
- [ ] Sensor data updates real-time
- [ ] Control buttons work
- [ ] Device list displays
- [ ] Commands logged to database

### Integration
- [ ] Flutter control → MQTT → ESP32 → DB log
- [ ] Web control → MQTT → ESP32 → DB log
- [ ] ESP32 state → MQTT → Backend → DB update
- [ ] Register device → visible in both Web & Flutter

---

## 🐛 TROUBLESHOOTING

### Issue: Backend can't connect to PostgreSQL

**Solution:**
```bash
# Check Docker container
docker ps | grep postgres

# Restart container
docker-compose restart postgres

# Check logs
docker logs iot_postgres
```

### Issue: MQTT connection failed

**Check:**
1. MQTT Broker running at `192.168.43.108`
2. Ports 1883 and 8083 open
3. Username/password: `admin/public`

### Issue: CORS error in Web Dashboard

**Solution:** Backend has CORS enabled. Check:
```java
// CorsConfig.java allows all origins
.allowedOrigins("*")
```

### Issue: Flutter can't reach API

**Check:**
1. Backend running on `http://192.168.43.108:8888`
2. Update `ApiService` if IP changed
3. Check firewall settings

---

## 📊 MONITORING & LOGS

### Backend Logs
```bash
cd iot_backend
mvn spring-boot:run

# Look for:
# ✅ MQTT Backend connected successfully
# 📋 Loaded devices from database
# 📤 Command sent: light → toggle
```

### Database Queries
```sql
-- View all devices
SELECT * FROM devices;

-- View recent commands
SELECT * FROM command_history 
ORDER BY executed_at DESC 
LIMIT 10;

-- View commands by source
SELECT source, COUNT(*) 
FROM command_history 
GROUP BY source;
```

### MQTT Topics Monitor
```bash
# Subscribe to all topics (using mosquitto_sub)
mosquitto_sub -h 192.168.43.108 -t 'lab/room1/#' -v
```

---

## 🎓 DEMO SCRIPT

**For Presentation (5 minutes):**

1. **Show Architecture** (30s)
   - Explain: ESP32 → MQTT → Backend → Database
   - Web + Flutter both monitor & control

2. **Demo Web Dashboard** (1 min)
   - Show real-time temperature/humidity
   - Click TOGGLE → LED changes
   - Show device list

3. **Demo Flutter App** (1 min)
   - Show same data synchronized
   - Toggle from app → Web updates instantly

4. **Register New Device** (1.5 min)
   - Click Devices → Add Device
   - Fill form → Register
   - Show in both Web & App

5. **Show Database** (1 min)
   - Open Adminer
   - Show `devices` table
   - Show `command_history` with sources

6. **Q&A** (30s)

---

## 📝 NOTES

- **Sample Device IDs:** `esp32_demo_001`, `esp32_demo_002`
- **Default Locations:** room1, room2, kitchen, bedroom
- **Command History:** Logs every control action with source
- **Auto-refresh:** Device list updates every 10s (Web), on-demand (Flutter)

---

**🎉 Setup Complete! Your IoT Smart Home System is ready for demo!**

