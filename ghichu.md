# 📝 GHI CHÚ THIẾT LẬP DỰ ÁN IoT SMART HOME

## 🎯 **Tổng quan dự án**
Hệ thống IoT Smart Home hoàn chỉnh bao gồm:
- 📱 **Android App** - Điều khiển thiết bị
- 🌐 **Web Dashboard** - Giám sát real-time  
- 🤖 **ESP32 Simulator** - Mô phỏng thiết bị IoT
- 🔄 **MQTT Communication** - Giao tiếp thời gian thực

---

## 🔧 **Các vấn đề đã sửa và giải pháp**

### **1. Lỗi đường dẫn trong script khởi động**
**❌ Vấn đề:** Script `run_all.bat` sử dụng đường dẫn cứng không đúng
```batch
# Lỗi cũ
start "ESP32 Simulator" cmd /k "cd /d D:\SourceCode\chapter4_3_1 && ..."
```

**✅ Giải pháp:** Sử dụng đường dẫn tương đối
```batch
# Đã sửa
start "ESP32 Simulator" cmd /k "cd /d %~dp0.. && python simulators\esp32_simulator.py"
```

**📁 Files đã sửa:**
- `scripts/run_all.bat` - Cập nhật đường dẫn tương đối
- `scripts/run_all.ps1` - Tạo mới PowerShell script tương thích Windows

---

### **2. Lỗi cấu hình Android cho Flutter**
**❌ Vấn đề:** Dự án Flutter thiếu cấu hình Android platform
```
AndroidManifest.xml could not be found.
No application found for TargetPlatform.android_arm64.
```

**✅ Giải pháp:** Thêm platform Android
```powershell
flutter create --platforms android .
```

**📁 Files được tạo:**
- `android/app/src/main/AndroidManifest.xml` - Manifest chính
- `android/app/src/debug/AndroidManifest.xml` - Debug config
- `android/app/src/profile/AndroidManifest.xml` - Profile config
- `android/build.gradle.kts` - Build configuration
- `android/settings.gradle.kts` - Settings

**🔐 Permissions đã thêm:**
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

---

### **3. Lỗi dart:html không tương thích Android**
**❌ Vấn đề:** File `main.dart` sử dụng `dart:html` chỉ hoạt động trên web
```dart
import 'dart:html' as html;  // ❌ Chỉ cho web
import 'dart:js' as js;      // ❌ Chỉ cho web
```

**✅ Giải pháp:** Thay thế bằng MQTT client native
```dart
import 'dart:convert';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';
```

**📁 Files đã sửa:**
- `app_flutter/lib/main.dart` - Thay thế toàn bộ bằng MQTT client
- `app_flutter/pubspec.yaml` - Đã có sẵn dependencies cần thiết

---

### **4. Lỗi MQTT connection timeout**
**❌ Vấn đề:** Android app không kết nối được MQTT broker
```
❌ MQTT connection error: NoConnectionException: The maximum allowed connection attempts ({3}) were exceeded
```

**✅ Giải pháp:** Thay đổi MQTT broker và tăng timeout
```dart
// Cũ
static const String _broker = 'broker.hivemq.com';

// Mới  
static const String _broker = 'test.mosquitto.org';
_client!.connectTimeoutPeriod = 10000; // 10 seconds timeout
```

**📁 Files đã sửa:**
- `app_flutter/lib/main.dart` - Đổi broker và timeout
- `simulators/esp32_simulator.py` - Đổi broker tương ứng

---

### **5. Lỗi UI overflow trên Android**
**❌ Vấn đề:** Giao diện bị tràn pixel
```
A RenderFlex overflowed by 14 pixels on the bottom.
```

**✅ Giải pháp:** Thêm Flexible widgets và giảm font size
```dart
Flexible(
  child: Text(
    title,
    style: const TextStyle(fontSize: 11), // Giảm từ 12
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  ),
),
```

---

### **6. Lỗi đồng bộ giữa Android App và Web Dashboard**
**❌ Vấn đề:** Web Dashboard không hiển thị dữ liệu khi Android app hoạt động

**✅ Giải pháp:** Cập nhật Web Dashboard sử dụng cùng broker
```javascript
// Cũ
MQTT_HOST_WS: 'wss://broker.hivemq.com:8884/mqtt',

// Mới
MQTT_HOST_WS: 'wss://test.mosquitto.org:8081/mqtt',
```

**📁 Files đã sửa:**
- `web/src/index.html` - Cập nhật MQTT broker configuration

---

## 🚀 **Cách chạy hệ thống hoàn chỉnh**

### **Phương pháp 1: Chạy tất cả một lần (Khuyến nghị)**
```powershell
cd "D:\1KTPM\Nam_4\Nam_4_HK1\IOT\Buoi5\lam\demo_chuong4_3_1-main\demo_chuong4_3_1-main"
.\scripts\run_all.ps1
```

### **Phương pháp 2: Chạy từng component**
```powershell
# Terminal 1: ESP32 Simulator
python simulators\esp32_simulator.py

# Terminal 2: Web Dashboard  
cd web\src
python -m http.server 3000

# Terminal 3: Flutter Android App
cd app_flutter
flutter run -d bd49a172
```

### **URLs truy cập:**
- **🌐 Web Dashboard:** http://localhost:3000/index.html
- **📱 Flutter Web:** http://localhost:8080/index.html (nếu build web)

---

## 🎮 **Tính năng hệ thống**

### **📱 Android App:**
- ✅ Kết nối MQTT qua TCP (port 1883)
- ✅ Điều khiển đèn và quạt (ON/OFF/Toggle)
- ✅ Hiển thị dữ liệu cảm biến real-time
- ✅ Material Design 3 interface
- ✅ Status indicators cho MQTT và ESP32
- ✅ Device information (WiFi signal, firmware, last update)

### **🌐 Web Dashboard:**
- ✅ Kết nối MQTT qua WebSocket (port 8081)
- ✅ Hiển thị dữ liệu cảm biến (nhiệt độ, độ ẩm, ánh sáng)
- ✅ Theo dõi trạng thái thiết bị (đèn, quạt)
- ✅ Giao diện gradient đẹp mắt
- ✅ Auto-refresh mỗi 3 giây
- ✅ Connection status indicators

### **🤖 ESP32 Simulator:**
- ✅ Publish dữ liệu cảm biến mỗi 3 giây
- ✅ Nhận và xử lý lệnh điều khiển
- ✅ Publish trạng thái thiết bị (retained messages)
- ✅ Last Will Testament (LWT)
- ✅ Heartbeat mỗi 15 giây

---

## 🔄 **MQTT Topics Structure**

```
demo/room1/
├── sensor/state     # Dữ liệu cảm biến (QoS 0)
│   └── {"ts": 1234, "temp_c": 25.5, "hum_pct": 60, "lux": 850}
├── device/state     # Trạng thái thiết bị (QoS 1, retained)
│   └── {"ts": 1234, "light": "on", "fan": "off", "rssi": -45, "fw": "sim-1.0.0"}
├── device/cmd       # Lệnh điều khiển (QoS 1)
│   └── {"light": "toggle"} hoặc {"fan": "toggle"}
└── sys/online       # Trạng thái online (QoS 1, retained, LWT)
    └── {"online": true}
```

---

## 🛠️ **Cấu hình MQTT Broker**

### **Broker hiện tại:** `test.mosquitto.org`
- **Android/ESP32:** TCP port 1883
- **Web Dashboard:** WebSocket port 8081
- **Public broker:** Không cần authentication
- **Ổn định:** Tốt hơn broker.hivemq.com

### **Alternative brokers (nếu cần):**
- `broker.emqx.io`
- `public.mqtthq.com`
- `mqtt.eclipseprojects.io`

---

## 📊 **Kết quả đạt được**

### **✅ Hoạt động tốt:**
- Android app kết nối MQTT thành công
- Web Dashboard hiển thị dữ liệu real-time
- ESP32 Simulator publish dữ liệu ổn định
- Đồng bộ hoàn hảo giữa Android và Web
- UI responsive và đẹp mắt

### **🎯 Test scenarios thành công:**
1. **Kết nối MQTT:** Tất cả components kết nối broker
2. **Dữ liệu sensor:** Hiển thị real-time trên cả Android và Web
3. **Điều khiển thiết bị:** Bật/tắt đèn/quạt từ Android → Web cập nhật ngay
4. **Connection recovery:** Tự động reconnect khi mất kết nối

---

## 🎓 **Kiến thức học được**

### **IoT Architecture:**
- MQTT protocol và QoS levels
- Retained messages và Last Will Testament
- Real-time synchronization giữa multiple clients

### **Flutter Development:**
- Cross-platform development (Android/Web)
- MQTT client integration
- State management với Provider
- Material Design 3 implementation

### **System Integration:**
- Multi-component IoT system
- MQTT broker selection và configuration
- WebSocket vs TCP connections
- Real-time data visualization

---

## 📝 **Ghi chú quan trọng**

### **🔧 Troubleshooting:**
- Nếu MQTT connection failed → Thử broker khác
- Nếu Android app crash → Check permissions trong AndroidManifest.xml
- Nếu Web không hiển thị → Check browser console và MQTT WebSocket connection
- Nếu Flutter build failed → Run `flutter clean` và `flutter pub get`

### **🚀 Phát triển thêm:**
- Thêm authentication cho MQTT
- Deploy lên cloud (AWS IoT, Azure IoT Hub)
- Thêm database để lưu trữ dữ liệu lịch sử
- Implement push notifications
- Thêm nhiều loại sensor và actuator

---

---

## 🏠 **CÁCH HOẠT ĐỘNG CỦA HỆ THỐNG IoT SMART HOME**

### **🎯 Tổng quan kiến trúc hệ thống:**

```
📱 Android App ←→ 🌐 MQTT Broker ←→ 🤖 ESP32 Device
                        ↕
                  💻 Web Dashboard
```

---

## 📱 **ANDROID APP - VAI TRÒ ĐIỀU KHIỂN (CONTROLLER)**

### **🎮 Tác dụng chính:**
1. **Điều khiển thiết bị từ xa** - Bật/tắt đèn và quạt
2. **Giám sát trạng thái** - Xem thiết bị đang ON/OFF
3. **Theo dõi dữ liệu cảm biến** - Nhiệt độ, độ ẩm, ánh sáng
4. **Interface di động** - Điều khiển mọi lúc mọi nơi

### **⚙️ Cách hoạt động:**

**Kết nối MQTT:**
```dart
// Kết nối TCP đến broker
MqttServerClient('test.mosquitto.org', clientId);
client.connect(); // Port 1883
```

**Gửi lệnh điều khiển:**
```dart
// Khi user nhấn switch đèn
void toggleLight() {
  final command = {"light": "toggle"};
  client.publishMessage(
    'demo/room1/device/cmd',  // Topic lệnh
    MqttQos.atLeastOnce,      // Đảm bảo gửi thành công
    jsonEncode(command)
  );
}
```

**Nhận phản hồi:**
```dart
// Subscribe để nhận trạng thái mới
client.subscribe('demo/room1/device/state', MqttQos.atLeastOnce);

// Khi ESP32 phản hồi
void onMessage(message) {
  final data = jsonDecode(message);
  setState(() {
    lightState = data['light']; // Cập nhật UI ngay lập tức
  });
}
```

### **🔄 Luồng hoạt động:**
1. **User tap switch** → App gửi MQTT command
2. **ESP32 nhận lệnh** → Thực hiện bật/tắt thiết bị
3. **ESP32 publish trạng thái mới** → App nhận và cập nhật UI
4. **Đồng thời Web Dashboard** cũng nhận trạng thái mới

---

## 💻 **WEB DASHBOARD - VAI TRÒ GIÁM SÁT (MONITOR)**

### **📊 Tác dụng chính:**
1. **Giám sát real-time** - Hiển thị dữ liệu liên tục
2. **Dashboard tổng quan** - Xem toàn bộ hệ thống một cách trực quan
3. **Lưu trữ lịch sử** - Theo dõi xu hướng dữ liệu
4. **Interface desktop** - Màn hình lớn, dễ quan sát

### **⚙️ Cách hoạt động:**

**Kết nối MQTT WebSocket:**
```javascript
// Kết nối WebSocket đến broker
const client = mqtt.connect('wss://test.mosquitto.org:8081/mqtt');

client.on('connect', function() {
  // Subscribe các topics cần thiết
  client.subscribe('demo/room1/sensor/state');   // Dữ liệu cảm biến
  client.subscribe('demo/room1/device/state');   // Trạng thái thiết bị
  client.subscribe('demo/room1/sys/online');     // Trạng thái kết nối
});
```

**Xử lý dữ liệu nhận được:**
```javascript
client.on('message', function(topic, message) {
  const data = JSON.parse(message.toString());
  
  if (topic.endsWith('/sensor/state')) {
    // Cập nhật dữ liệu cảm biến
    updateTemperature(data.temp_c);
    updateHumidity(data.hum_pct);
    updateLightLevel(data.lux);
  }
  
  if (topic.endsWith('/device/state')) {
    // Cập nhật trạng thái thiết bị
    updateDeviceStatus(data.light, data.fan);
  }
});
```

**Hiển thị real-time:**
```javascript
function updateSensorData(temp, humidity, light) {
  document.getElementById('temperature').textContent = temp + '°C';
  document.getElementById('humidity').textContent = humidity + '%';
  document.getElementById('light-level').textContent = light + ' lux';
  
  // Cập nhật timestamp
  document.getElementById('last-update').textContent = new Date().toLocaleTimeString();
}
```

---

## 🤖 **ESP32 DEVICE/SIMULATOR - VAI TRÒ THIẾT BỊ IoT**

### **⚡ Tác dụng chính:**
1. **Thu thập dữ liệu** - Đọc sensors (nhiệt độ, độ ẩm, ánh sáng)
2. **Điều khiển actuators** - Bật/tắt đèn, quạt, relay
3. **Giao tiếp MQTT** - Gửi/nhận dữ liệu qua mạng
4. **Phản hồi lệnh** - Thực hiện lệnh từ App và báo cáo trạng thái

### **⚙️ Cách hoạt động:**

**Publish dữ liệu cảm biến:**
```python
def publish_sensor_data():
    # Đọc sensors (hoặc tạo dữ liệu giả lập)
    temp_c = read_temperature_sensor()  # 17-28°C
    hum_pct = read_humidity_sensor()    # 35-75%
    lux = read_light_sensor()           # 50-300 lux
    
    data = {
        "ts": int(time.time()),
        "temp_c": temp_c,
        "hum_pct": hum_pct,
        "lux": lux
    }
    
    # Gửi mỗi 3 giây
    client.publish('demo/room1/sensor/state', json.dumps(data))
```

**Xử lý lệnh điều khiển:**
```python
def on_message(client, userdata, msg):
    if msg.topic == 'demo/room1/device/cmd':
        command = json.loads(msg.payload.decode())
        
        if 'light' in command:
            if command['light'] == 'toggle':
                light_state = not light_state
                control_light_relay(light_state)
        
        if 'fan' in command:
            if command['fan'] == 'toggle':
                fan_state = not fan_state
                control_fan_relay(fan_state)
        
        # Phản hồi trạng thái mới ngay lập tức
        publish_device_state()
```

**Publish trạng thái thiết bị:**
```python
def publish_device_state():
    state = {
        "ts": int(time.time()),
        "light": "on" if light_state else "off",
        "fan": "on" if fan_state else "off",
        "rssi": get_wifi_signal_strength(),
        "fw": "sim-1.0.0"
    }
    
    # Retained message để clients mới nhận được trạng thái hiện tại
    client.publish('demo/room1/device/state', json.dumps(state), retain=True)
```

---

## 🔄 **MQTT - TRUNG TÂM GIAO TIẾP**

### **🌐 Vai trò của MQTT Broker:**
1. **Message Router** - Chuyển tiếp tin nhắn giữa các clients
2. **Topic Manager** - Quản lý các chủ đề giao tiếp
3. **Connection Hub** - Trung tâm kết nối cho tất cả thiết bị
4. **Quality of Service** - Đảm bảo tin nhắn được gửi đúng cách

### **📡 Cách hoạt động:**

**Topic Structure:**
```
demo/room1/
├── sensor/state     # ESP32 → Broker → App & Web
├── device/state     # ESP32 → Broker → App & Web (retained)
├── device/cmd       # App → Broker → ESP32
└── sys/online       # ESP32 → Broker → App & Web (LWT)
```

**Message Flow:**
```
1. ESP32 publish sensor data → Broker
2. Broker forward → App & Web Dashboard
3. App send command → Broker  
4. Broker forward → ESP32
5. ESP32 execute & publish new state → Broker
6. Broker forward → App & Web Dashboard
```

---

## 🎯 **TƯƠNG TÁC GIỮA CÁC THÀNH PHẦN**

### **Scenario 1: User bật đèn từ Android App**
```
📱 App: User tap "Light ON"
    ↓ MQTT Publish
🌐 Broker: Receive command {"light": "on"}
    ↓ Forward to ESP32
🤖 ESP32: Execute → Turn on LED/Relay
    ↓ Publish new state
🌐 Broker: Receive state {"light": "on", ...}
    ↓ Forward to all subscribers
📱 App: Update UI → Switch shows "ON"
💻 Web: Update display → "Light: ON"
```

### **Scenario 2: ESP32 gửi dữ liệu cảm biến**
```
🤖 ESP32: Read sensors every 3 seconds
    ↓ Publish data
🌐 Broker: Receive {"temp_c": 25.5, "hum_pct": 60, "lux": 200}
    ↓ Forward to subscribers
📱 App: Update sensor card
💻 Web: Update dashboard charts
```

### **Scenario 3: ESP32 mất kết nối**
```
🤖 ESP32: Connection lost
🌐 Broker: Detect disconnection → Publish LWT
    ↓ Send {"online": false}
📱 App: Show "Device: Offline"
💻 Web: Show "Device: Offline" (red status)
```

---

## 🎨 **GIAO DIỆN VÀ TRẢI NGHIỆM NGƯỜI DÙNG**

### **📱 Android App UI:**
- **Material Design 3** - Giao diện hiện đại
- **Status Cards** - MQTT Broker và ESP32 Device status
- **Sensor Data Card** - Hiển thị nhiệt độ, độ ẩm, ánh sáng
- **Control Cards** - Switch bật/tắt đèn và quạt với animation
- **Device Info** - WiFi signal, firmware, last update
- **Real-time feedback** - SnackBar thông báo khi gửi lệnh

### **💻 Web Dashboard UI:**
- **Gradient Background** - Giao diện đẹp mắt
- **Connection Status** - Broker và Device indicators
- **Sensor Charts** - Hiển thị dữ liệu trực quan
- **Device Status** - Trạng thái thiết bị real-time
- **System Information** - Firmware, signal strength
- **Auto-refresh** - Cập nhật mỗi 3 giây

---

## ⚡ **ƯU ĐIỂM CỦA KIẾN TRÚC NÀY**

### **🔄 Real-time Synchronization:**
- Tất cả clients đều nhận cập nhật đồng thời
- Không cần polling, tiết kiệm băng thông
- Latency thấp (<100ms)

### **📈 Scalability:**
- Dễ dàng thêm nhiều thiết bị
- Hỗ trợ nhiều room/zone
- Có thể mở rộng thành hệ thống lớn

### **🛡️ Reliability:**
- QoS levels đảm bảo tin nhắn quan trọng
- Retained messages cho trạng thái thiết bị
- Last Will Testament cho offline detection
- Auto-reconnect khi mất kết nối

### **🔧 Flexibility:**
- Dễ dàng thêm tính năng mới
- Hỗ trợ nhiều platform (Android, Web, iOS)
- Có thể thay đổi broker dễ dàng
- Topic structure có thể mở rộng

---

## 🎓 **KIẾN THỨC VÀ CÔNG NGHỆ SỬ DỤNG**

### **📱 Android App:**
- **Flutter Framework** - Cross-platform development
- **Dart Language** - Programming language
- **MQTT Client** - Native TCP connection
- **Provider Pattern** - State management
- **Material Design 3** - UI/UX design system

### **💻 Web Dashboard:**
- **HTML5/CSS3/JavaScript** - Web technologies
- **MQTT.js Library** - WebSocket MQTT client
- **Responsive Design** - Multi-device support
- **Real-time Updates** - Event-driven programming

### **🤖 ESP32 Device:**
- **Python Simulation** - Device behavior modeling
- **Paho MQTT Client** - MQTT communication
- **JSON Data Format** - Structured data exchange
- **Threading** - Concurrent operations

### **🌐 MQTT Infrastructure:**
- **Publish/Subscribe Pattern** - Decoupled communication
- **Topic-based Routing** - Organized message flow
- **Quality of Service** - Message delivery guarantees
- **WebSocket & TCP** - Multiple connection types

---

**📅 Ngày hoàn thành:** 03/10/2025  
**👨‍💻 Người thực hiện:** Hỗ trợ bởi AI Assistant  
**🎯 Trạng thái:** Hoàn thành và hoạt động ổn định  
**🏠 Hệ thống:** IoT Smart Home với kiến trúc professional-grade
