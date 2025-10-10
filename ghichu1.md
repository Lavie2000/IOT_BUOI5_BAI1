# 📝 TÓM TẮT DỰ ÁN IoT SMART HOME SYSTEM

## 🎯 **TỔNG QUAN DỰ ÁN**

### **Tên dự án:** IoT Smart Home Controller Demo
### **Mục đích:** Hệ thống điều khiển và giám sát thiết bị IoT thời gian thực
### **Nền tảng:** Web Dashboard + Flutter Mobile App + ESP32-S3 Device
### **Giao thức:** MQTT (Message Queuing Telemetry Transport)

---

## 🏗️ **KIẾN TRÚC HỆ THỐNG**

### **3 Thành phần chính:**

```
┌─────────────────────────────────────────────────────────────┐
│                    MQTT BROKER                              │
│              (192.168.43.108:1883/8083)                     │
│           WebSocket Port: 8083 | TCP Port: 1883             │
└─────────────────────────────────────────────────────────────┘
                           ▲
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ Web Dashboard│    │Flutter App  │    │  ESP32-S3   │
│   Monitor    │    │  Controller │    │   Device    │
│ (HTML/JS)    │    │  (Dart)     │    │   (C++)     │
└─────────────┘    └─────────────┘    └─────────────┘
```

### **Luồng dữ liệu:**
1. **ESP32-S3** → publish sensor data → MQTT Broker
2. **MQTT Broker** → broadcast → Web Dashboard & Flutter App
3. **Flutter App** → publish command → MQTT Broker
4. **MQTT Broker** → route command → ESP32-S3
5. **ESP32-S3** → execute command → publish new state

---

## 📱 **1. FLUTTER MOBILE APP (main.dart)**

### **Thông tin cấu hình:**
```dart
// MQTT Configuration
- Broker: 192.168.43.108
- Port WebSocket: 8083
- Path: /mqtt
- Topic Namespace: lab/room1
- Username: admin
- Password: public
```

### **Các topic MQTT:**
- `lab/room1/device/state` - Nhận trạng thái thiết bị (QoS 1)
- `lab/room1/sensor/state` - Nhận dữ liệu cảm biến (QoS 0)
- `lab/room1/sys/online` - Trạng thái online (QoS 1)
- `lab/room1/device/cmd` - Gửi lệnh điều khiển (QoS 1)

### **Tính năng:**
✅ **Kết nối MQTT qua WebSocket**
- Auto-reconnect với keepalive 60 giây
- Timeout 10 giây
- Logging để debug

✅ **Hiển thị trạng thái:**
- MQTT Broker: Connected/Disconnected
- ESP32 Device: Online/Offline
- WiFi Signal (RSSI)
- Firmware version
- Last update time

✅ **Hiển thị dữ liệu cảm biến:**
- Temperature (°C) - từ DHT11
- Humidity (%) - từ DHT11
- Animation khi cập nhật giá trị

✅ **Điều khiển thiết bị:**
- Smart Light: Toggle ON/OFF với NeoPixel LED
- Smart Fan: Toggle ON/OFF (Software only)
- Visual feedback với gradient và animation

✅ **UI/UX:**
- Material Design 3
- Gradient background (Blue → Purple)
- Card-based layout với elevation shadows
- Status indicators với animation pulse
- Responsive design

### **Class chính:**

#### **MqttController (ChangeNotifier)**
```dart
// State management
- _isConnected: bool
- _deviceOnline: bool
- _lightState: String ('on'/'off')
- _fanState: String ('on'/'off')
- _temperature: double
- _humidity: double
- _rssi: String
- _firmware: String
- _lastUpdate: String

// Methods
+ connect() → Future<void>
+ sendCommand(device, action) → void
+ toggleLight() → void
+ toggleFan() → void
```

#### **Message Format:**

**Device State (received):**
```json
{
  "light": "on",
  "fan": "off",
  "rssi": -45,
  "fw": "demo1-1.0.0"
}
```

**Sensor State (received):**
```json
{
  "ts": 123456,
  "temp_c": 31.4,
  "hum_pct": 66
}
```

**Command (sent):**
```json
{
  "light": "toggle"
}
```
hoặc
```json
{
  "fan": "toggle"
}
```

---

## 🤖 **2. ESP32-S3 FIRMWARE (main.cpp)**

### **Thông tin cấu hình:**
```cpp
// WiFi
SSID: "3q1"
Password: "12101210"

// MQTT
Host: 192.168.43.108
Port: 1883 (TCP)
Username: admin
Password: public

// Device Info
Device ID: esp32_demo_001
Firmware: demo1-1.0.0
Topic Namespace: lab/room1
```

### **GPIO Pin Configuration:**
```cpp
DHT11 Sensor:     GPIO 4
Light Relay:      GPIO 5
Fan Relay:        GPIO 6  (không dùng)
Status LED:       GPIO 2
NeoPixel LED:     GPIO 48
```

### **Timing Configuration:**
```cpp
Sensor Publish:    3000ms (3 giây)
Heartbeat:         15000ms (15 giây)
WiFi Reconnect:    5000ms
MQTT Reconnect:    5000ms
```

### **MQTT Topics:**
```cpp
topicSensorState = "lab/room1/sensor/state"
topicDeviceState = "lab/room1/device/state"
topicDeviceCmd   = "lab/room1/device/cmd"
topicSysOnline   = "lab/room1/sys/online"
```

### **Tính năng:**

✅ **WiFi Management:**
- Auto-connect on startup
- Auto-reconnect khi mất kết nối
- Display IP address và RSSI

✅ **MQTT Communication:**
- Last Will Testament (LWT) cho online status
- Subscribe to command topic
- Publish sensor data (retained = false)
- Publish device state (retained = true)
- Publish online status (retained = true)

✅ **Sensor Integration:**
- DHT11: Temperature & Humidity
- Đọc mỗi 3 giây
- Làm tròn 1 chữ số thập phân

✅ **Device Control:**
- Light control:
  - Relay GPIO 5: HIGH/LOW
  - NeoPixel GPIO 48: GREEN (on) / OFF (off)
- Fan control: Software only (không có relay thật)
- Commands: "on", "off", "toggle"

✅ **Status LED Indication:**
- WiFi + MQTT OK: Sáng liên tục
- WiFi OK, MQTT mất: Nhấp nháy nhanh (250ms)
- WiFi mất: Nhấp nháy chậm (1000ms)

### **Message Formats:**

**Publish Sensor Data:**
```json
{
  "ts": 123456,
  "temp_c": 31.4,
  "hum_pct": 66
}
```

**Publish Device State:**
```json
{
  "ts": 123456,
  "light": "on",
  "fan": "off",
  "rssi": -45,
  "fw": "demo1-1.0.0"
}
```

**Publish Online Status:**
```json
{
  "online": true
}
```

**Receive Command:**
```json
{
  "light": "toggle"
}
```

### **Xử lý lệnh:**
```cpp
handleDeviceCommand():
  - Parse JSON command
  - Check "light" key → update lightState
  - Control GPIO 5 (relay)
  - Control GPIO 48 (NeoPixel: GREEN/OFF)
  - Check "fan" key → update fanState (software only)
  - Publish device state immediately
```

---

## 🌐 **3. WEB DASHBOARD (index.html)**

### **Thông tin cấu hình:**
```javascript
// MQTT Configuration
MQTT_HOST_WS: 'ws://192.168.43.108:8083/mqtt'
MQTT_USERNAME: 'admin'
MQTT_PASSWORD: 'public'
TOPIC_NS: 'lab/room1'
RECONNECT_PERIOD: 5000ms
```

### **MQTT Topics:**
```javascript
sensor: "lab/room1/sensor/state"
device: "lab/room1/device/state"
online: "lab/room1/sys/online"
```

### **Tính năng:**

✅ **Real-time Monitoring:**
- MQTT WebSocket connection
- Auto-reconnect khi mất kết nối
- Subscription to 3 topics

✅ **Display Components:**

**1. Status Bar:**
- Broker Status: Connected/Disconnected (với animation pulse)
- Device Status: Online/Offline

**2. Sensor Data Card:**
- Temperature (°C) - animated update
- Humidity (%) - animated update
- Light sensor REMOVED (chỉ dùng DHT11)

**3. Device Control Card:**
- Light status: ON/OFF badge
- Fan status: ON/OFF (Software Only)
- WiFi Signal (RSSI)

**4. System Info Card:**
- Firmware version
- Device online status
- Last update timestamp

✅ **UI Design:**
- Gradient background: Purple (#667eea → #764ba2)
- Card-based layout với hover effects
- Color-coded status indicators
- Responsive design (mobile-friendly)
- Animation: pulse, value update, hover transforms

### **Message Handlers:**

**handleSensorData():**
```javascript
Parse JSON → Update temperature & humidity
Add animation class → Auto-remove after 500ms
Update last update time
```

**handleDeviceState():**
```javascript
Parse JSON → Update light/fan status
Update RSSI, firmware
Change badge colors (ON=green, OFF=gray)
```

**handleOnlineStatus():**
```javascript
Parse JSON → Update device online indicator
Change status bar color
```

### **Connection Logic:**
```javascript
connectMQTT():
  - Generate random client ID
  - Connect with credentials
  - Subscribe to 3 topics (QoS 0, 1, 1)
  - Setup event handlers:
    * on('connect') → update UI
    * on('message') → route to handlers
    * on('error') → schedule reconnect
    * on('close') → schedule reconnect
```

---

## 🔄 **MQTT MESSAGE FLOW**

### **Sensor Data Flow:**
```
ESP32 (3s interval)
  → Publish to "lab/room1/sensor/state"
  → MQTT Broker
  → Broadcast to subscribers
  → Web Dashboard receives
  → Update UI with animation
```

### **Device Control Flow:**
```
Flutter App
  → User toggle switch
  → Publish to "lab/room1/device/cmd"
    {"light": "toggle"}
  → MQTT Broker
  → ESP32 receives
  → Execute command
  → Update GPIO & NeoPixel
  → Publish new state to "lab/room1/device/state"
  → Flutter & Web receive state
  → Update UI simultaneously
```

### **Online Status Flow:**
```
ESP32 connects
  → Publish {"online": true} RETAINED
  → MQTT Broker stores
  → New clients subscribe
  → Receive last retained message
  → Display online status

ESP32 disconnects (LWT)
  → Broker publishes {"online": false}
  → Clients receive
  → Display offline status
```

---

## 📊 **DATA STRUCTURES**

### **Device State:**
| Field | Type | Source | Update Frequency |
|-------|------|--------|------------------|
| light | string | ESP32 | On change + 15s heartbeat |
| fan | string | ESP32 | On change + 15s heartbeat |
| rssi | int | ESP32 | Every 15s |
| fw | string | ESP32 | On connect |
| temp_c | float | DHT11 | Every 3s |
| hum_pct | float | DHT11 | Every 3s |
| online | bool | ESP32 | On connect/disconnect |

---

## 🛠️ **TECHNOLOGY STACK**

### **Flutter App:**
- **Language:** Dart
- **Framework:** Flutter 3.35.4
- **MQTT Client:** mqtt_client (mqtt_server_client)
- **State Management:** Provider (ChangeNotifier)
- **UI:** Material Design 3

### **ESP32 Firmware:**
- **Language:** C++ (Arduino)
- **Platform:** ESP32-S3
- **Libraries:**
  - WiFi.h
  - PubSubClient.h (MQTT)
  - ArduinoJson.h
  - DHT.h (DHT11 sensor)
  - Adafruit_NeoPixel.h

### **Web Dashboard:**
- **Language:** HTML/CSS/JavaScript
- **MQTT Client:** mqtt.js (4.3.7)
- **Styling:** Custom CSS với Gradients
- **Font:** Google Fonts (Inter)

---

## 🔌 **HARDWARE SETUP**

### **Kết nối vật lý:**

```
ESP32-S3 Pinout:
├── DHT11 Sensor
│   ├── VCC → 3.3V
│   ├── GND → GND
│   └── Data → GPIO 4
│
├── Light Relay
│   ├── VCC → 5V
│   ├── GND → GND
│   ├── IN → GPIO 5
│   └── COM/NO → Light circuit
│
├── NeoPixel LED
│   ├── VCC → 5V
│   ├── GND → GND
│   └── Data → GPIO 48
│
└── Status LED
    ├── LED+ → GPIO 2
    └── LED- → GND (220Ω resistor)
```

### **Chức năng GPIO:**
- **GPIO 4:** DHT11 Data (Input)
- **GPIO 5:** Light Relay Control (Output)
- **GPIO 2:** Status LED (Output)
- **GPIO 48:** NeoPixel LED Control (Output)
- **GPIO 6:** Fan Relay (Không sử dụng)

---

## 🚀 **CÁCH CHẠY DỰ ÁN**

### **Môi trường hiện tại:**
- **WiFi Network:** 3q1 (IP: 192.168.43.108)
- **MQTT Broker:** EMQX tại 192.168.43.108
- **WebSocket Port:** 8083
- **TCP Port:** 1883

### **Bước 1: Upload Firmware ESP32**
```cpp
// Cấu hình trong main.cpp
const char* WIFI_SSID = "3q1";
const char* MQTT_HOST = "192.168.43.108";
```
→ Upload qua Arduino IDE/PlatformIO

### **Bước 2: Chạy Flutter App**
```bash
cd app_flutter
flutter run -d web-server --web-port 8080
# hoặc
flutter run -d android
```

### **Bước 3: Chạy Web Dashboard**
```bash
cd web/src
python -m http.server 3000
# Truy cập: http://localhost:3000/index.html
```

---

## 🎯 **CHỨC NĂNG CHÍNH**

### **1. Giám sát (Monitoring):**
- ✅ Nhiệt độ & Độ ẩm real-time (DHT11)
- ✅ Trạng thái thiết bị (Light ON/OFF, Fan ON/OFF)
- ✅ Chất lượng WiFi (RSSI)
- ✅ Device online/offline status
- ✅ Auto-update mỗi 3 giây

### **2. Điều khiển (Control):**
- ✅ Toggle Light (Flutter App)
  - Relay GPIO 5: ON/OFF
  - NeoPixel GPIO 48: GREEN/OFF
- ✅ Toggle Fan (Software only - không có relay)
- ✅ Lệnh: "on", "off", "toggle"
- ✅ Feedback ngay lập tức

### **3. Đồng bộ (Synchronization):**
- ✅ Flutter gửi lệnh → ESP32 nhận → Cập nhật state
- ✅ ESP32 publish state → Flutter & Web nhận → Update UI
- ✅ Retained messages cho state persistence
- ✅ LWT cho offline detection

---

## 📈 **QoS LEVELS**

| Topic | QoS | Retained | Purpose |
|-------|-----|----------|---------|
| sensor/state | 0 | No | High frequency, loss acceptable |
| device/state | 1 | Yes | Important, need persistence |
| device/cmd | 1 | No | Command delivery guaranteed |
| sys/online | 1 | Yes | Status persistence |

---

## 🔒 **SECURITY**

### **Current Setup:**
- Username: `admin`
- Password: `public`
- No encryption (testing only)

### **Production Recommendations:**
- ✅ Sử dụng TLS/SSL
- ✅ Strong credentials
- ✅ Client certificates
- ✅ Access Control Lists (ACL)

---

## 🎨 **UI/UX HIGHLIGHTS**

### **Flutter App:**
- Modern gradient design (Blue → Purple)
- Card-based responsive layout
- Status indicators với animation
- Visual feedback cho user actions
- Material Design 3 components

### **Web Dashboard:**
- Professional gradient background
- Real-time value animations
- Color-coded status badges
- Hover effects và transitions
- Mobile-responsive grid layout

---

## 📝 **NOTES & LIMITATIONS**

### **Current Implementation:**
1. ✅ **Light Control:** 
   - Hardware: Relay + NeoPixel
   - NeoPixel: GREEN when ON, OFF when off
   
2. ⚠️ **Fan Control:** 
   - Software only (không có relay GPIO 6)
   - Chỉ update state, không có output thực

3. ✅ **Sensor:**
   - DHT11 only (temp + humidity)
   - Light sensor đã remove

4. ✅ **Connection:**
   - WebSocket cho Flutter & Web
   - TCP cho ESP32
   - Auto-reconnect implemented

### **Known Issues:**
- Fan relay không được kết nối (GPIO 6 unused)
- WebSocket path `/mqtt` hardcoded
- No authentication beyond basic username/password
- No data logging/history

---

## 🔮 **POSSIBLE ENHANCEMENTS**

1. **Add more sensors:** Light sensor, Motion, Gas, etc.
2. **Implement Fan relay:** Connect GPIO 6
3. **Data logging:** InfluxDB, MongoDB
4. **Charts:** Historical data visualization
5. **Notifications:** Push notifications, Alerts
6. **Voice control:** Google Assistant, Alexa
7. **Automation:** Rules, Schedules, Triggers
8. **Security:** JWT, OAuth2, TLS

---

## 📚 **LEARNING OUTCOMES**

Sau khi phân tích dự án này, bạn hiểu được:

1. ✅ **IoT Architecture:** Client-Broker-Device pattern
2. ✅ **MQTT Protocol:** Pub/Sub, QoS, Retained messages, LWT
3. ✅ **WebSocket:** Real-time bidirectional communication
4. ✅ **Flutter:** Cross-platform development, State management
5. ✅ **ESP32:** Embedded programming, GPIO control
6. ✅ **Integration:** Synchronizing multiple clients
7. ✅ **JSON:** Data serialization/parsing
8. ✅ **Real-time UI:** Animations, Status updates

---

## 🎓 **SUMMARY**

**Dự án này là một hệ thống IoT hoàn chỉnh với:**

- 🌐 **Web Dashboard** để giám sát real-time
- 📱 **Flutter Mobile App** để điều khiển thiết bị
- 🤖 **ESP32-S3 Firmware** để kết nối phần cứng
- 🔄 **MQTT Broker** để đồng bộ dữ liệu
- 💡 **Light Control** với NeoPixel LED feedback
- 🌡️ **DHT11 Sensor** cho temperature & humidity
- 🔌 **WebSocket** cho real-time communication
- 📊 **Modern UI/UX** với animations và gradients

**Kiến trúc này có thể mở rộng cho:**
- Smart Home automation
- Industrial IoT monitoring
- Agricultural sensors
- Building management systems

---

**📅 Ngày tạo:** 2025-01-09  
**👨‍💻 Người phân tích:** AI Assistant  
**🎯 Mục đích:** Educational documentation

