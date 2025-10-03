# 🚀 HƯỚNG DẪN CHẠY DỰ ÁN IoT SMART HOME

## 📋 **Yêu cầu hệ thống**
- ✅ Python 3.8+ (đã có: Python 3.13.1)
- ✅ Flutter SDK (đã có: Flutter 3.35.4)
- ✅ Internet connection (cho MQTT broker)
- ✅ Device Android: `2201117TG (bd49a172)` - đã kết nối

---

## 🎯 **CÁCH 1: CHẠY TẤT CẢ MỘT LẦN (Khuyến nghị cho Demo)**

### **PowerShell Script:**
```powershell
# Mở PowerShell tại thư mục dự án
cd "D:\1KTPM\Nam_4\Nam_4_HK1\IOT\Buoi5\lam\demo_chuong4_3_1-main\demo_chuong4_3_1-main"

# Chạy tất cả components
.\scripts\run_all.ps1
```

**➡️ Kết quả:** Tự động mở:
- 🤖 ESP32 Simulator (console)
- 🌐 Web Dashboard: http://localhost:3000/index.html
- 📱 Flutter Web App: http://localhost:8080/index.html

---

## 🎯 **CÁCH 2: CHẠY FLUTTER TRÊN ANDROID DEVICE**

### **Bước 1: Khởi động ESP32 Simulator**
```powershell
# Terminal 1
cd "D:\1KTPM\Nam_4\Nam_4_HK1\IOT\Buoi5\lam\demo_chuong4_3_1-main\demo_chuong4_3_1-main"
python simulators\esp32_simulator.py
```

### **Bước 2: Chạy Flutter trên Android**
```powershell
# Terminal 2
cd "D:\1KTPM\Nam_4\Nam_4_HK1\IOT\Buoi5\lam\demo_chuong4_3_1-main\demo_chuong4_3_1-main\app_flutter"

# Chạy trên device Android của bạn
flutter run -d bd49a172
```

### **Bước 3: Khởi động Web Dashboard (tùy chọn)**
```powershell
# Terminal 3
cd "D:\1KTPM\Nam_4\Nam_4_HK1\IOT\Buoi5\lam\demo_chuong4_3_1-main\demo_chuong4_3_1-main\web\src"
python -m http.server 3000
# Truy cập: http://localhost:3000/index.html
```

---

## 🎯 **CÁCH 3: DEVELOPMENT MODE (Hot Reload)**

### **Flutter Web Development:**
```powershell
# Terminal 1 - ESP32 Simulator
cd "D:\1KTPM\Nam_4\Nam_4_HK1\IOT\Buoi5\lam\demo_chuong4_3_1-main\demo_chuong4_3_1-main"
python simulators\esp32_simulator.py

# Terminal 2 - Flutter Hot Reload
cd "D:\1KTPM\Nam_4\Nam_4_HK1\IOT\Buoi5\lam\demo_chuong4_3_1-main\demo_chuong4_3_1-main\app_flutter"
flutter run -d web-server --web-port 8080
```

### **Flutter Android Development:**
```powershell
# Terminal 1 - ESP32 Simulator
cd "D:\1KTPM\Nam_4\Nam_4_HK1\IOT\Buoi5\lam\demo_chuong4_3_1-main\demo_chuong4_3_1-main"
python simulators\esp32_simulator.py

# Terminal 2 - Flutter Android Hot Reload
cd "D:\1KTPM\Nam_4\Nam_4_HK1\IOT\Buoi5\lam\demo_chuong4_3_1-main\demo_chuong4_3_1-main\app_flutter"
flutter run -d bd49a172 --debug
```

---

## 🎯 **CÁCH 4: CHẠY TỪNG COMPONENT RIÊNG**

### **A. ESP32 Simulator:**
```powershell
cd "D:\1KTPM\Nam_4\Nam_4_HK1\IOT\Buoi5\lam\demo_chuong4_3_1-main\demo_chuong4_3_1-main"
python simulators\esp32_simulator.py

# Kết quả:
# - Kết nối MQTT broker: broker.hivemq.com
# - Publish sensor data mỗi 3 giây
# - Nhận lệnh điều khiển từ Flutter app
```

### **B. Web Dashboard:**
```powershell
cd "D:\1KTPM\Nam_4\Nam_4_HK1\IOT\Buoi5\lam\demo_chuong4_3_1-main\demo_chuong4_3_1-main\web\src"
python -m http.server 3000

# Truy cập: http://localhost:3000/index.html
# Chức năng: Hiển thị dữ liệu cảm biến real-time
```

### **C. Flutter Web App:**
```powershell
cd "D:\1KTPM\Nam_4\Nam_4_HK1\IOT\Buoi5\lam\demo_chuong4_3_1-main\demo_chuong4_3_1-main\app_flutter\build\web"
python -m http.server 8080

# Truy cập: http://localhost:8080/index.html
# Chức năng: Điều khiển đèn và quạt
```

### **D. Flutter Android App:**
```powershell
cd "D:\1KTPM\Nam_4\Nam_4_HK1\IOT\Buoi5\lam\demo_chuong4_3_1-main\demo_chuong4_3_1-main\app_flutter"
flutter run -d bd49a172

# Chức năng: Native Android app điều khiển IoT
```

### **E. Flutter Windows Desktop:**
```powershell
cd "D:\1KTPM\Nam_4\Nam_4_HK1\IOT\Buoi5\lam\demo_chuong4_3_1-main\demo_chuong4_3_1-main\app_flutter"
flutter run -d windows

# Chức năng: Windows desktop app
```

---

## 🎯 **CÁCH 5: BUILD & DEPLOY**

### **Build Flutter Web:**
```powershell
cd "D:\1KTPM\Nam_4\Nam_4_HK1\IOT\Buoi5\lam\demo_chuong4_3_1-main\demo_chuong4_3_1-main\app_flutter"
flutter build web --release

# Output: build/web/
# Deploy: Copy build/web/ to web server
```

### **Build Android APK:**
```powershell
cd "D:\1KTPM\Nam_4\Nam_4_HK1\IOT\Buoi5\lam\demo_chuong4_3_1-main\demo_chuong4_3_1-main\app_flutter"
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
# Install: adb install app-release.apk
```

### **Build Windows Desktop:**
```powershell
cd "D:\1KTPM\Nam_4\Nam_4_HK1\IOT\Buoi5\lam\demo_chuong4_3_1-main\demo_chuong4_3_1-main\app_flutter"
flutter build windows --release

# Output: build/windows/x64/runner/Release/
# Run: iot_controller.exe
```

---

## 🎯 **DEMO SCENARIOS**

### **Scenario 1: Full System Demo**
```powershell
# Chạy tất cả
.\scripts\run_all.ps1

# Mở 3 tabs browser:
# 1. Web Dashboard: http://localhost:3000/index.html
# 2. Flutter Web: http://localhost:8080/index.html
# 3. ESP32 Console: Xem logs real-time

# Demo:
# - Bật/tắt đèn trên Flutter → Xem Web Dashboard cập nhật
# - Xem dữ liệu cảm biến cập nhật mỗi 3 giây
```

### **Scenario 2: Mobile App Demo**
```powershell
# Terminal 1: ESP32 Simulator
python simulators\esp32_simulator.py

# Terminal 2: Flutter Android
cd app_flutter
flutter run -d bd49a172

# Demo trên điện thoại Android:
# - Mở app IoT Controller
# - Điều khiển đèn/quạt
# - Xem trạng thái real-time
```

### **Scenario 3: Development Demo**
```powershell
# Terminal 1: ESP32 Simulator
python simulators\esp32_simulator.py

# Terminal 2: Flutter Hot Reload
cd app_flutter
flutter run -d web-server --web-port 8080

# Demo development:
# - Sửa code Flutter → Hot reload
# - Test tính năng mới ngay lập tức
```

---

## 🛠️ **TROUBLESHOOTING**

### **Lỗi thường gặp:**

**1. Port đã được sử dụng:**
```powershell
# Kill processes sử dụng port
taskkill /f /im python.exe
netstat -ano | findstr :3000
netstat -ano | findstr :8080
```

**2. Flutter device không nhận diện:**
```powershell
# Kiểm tra devices
flutter devices

# Refresh devices
flutter doctor

# Enable USB Debugging trên Android
```

**3. MQTT connection failed:**
```powershell
# Test MQTT connectivity
python tests\test_mqtt_command.py

# Kiểm tra internet connection
ping broker.hivemq.com
```

**4. ESP32 Simulator lỗi encoding:**
```powershell
# Đã fix trong code, nếu vẫn lỗi:
chcp 65001  # Set UTF-8 encoding
python simulators\esp32_simulator.py
```

---

## 📊 **SYSTEM URLS**

| Component | URL | Chức năng |
|-----------|-----|-----------|
| Web Dashboard | http://localhost:3000/index.html | Monitoring dữ liệu cảm biến |
| Flutter Web | http://localhost:8080/index.html | Điều khiển thiết bị |
| Android App | Native app trên device | Mobile control |
| Windows App | Desktop executable | Desktop control |
| ESP32 Simulator | Console application | Device simulation |

---

## 🎓 **LEARNING OBJECTIVES**

Sau khi chạy thành công dự án, bạn sẽ hiểu:

1. **IoT Architecture** - Kiến trúc hệ thống IoT
2. **MQTT Protocol** - Giao thức messaging
3. **Flutter Cross-platform** - Phát triển đa nền tảng
4. **Real-time Communication** - Giao tiếp thời gian thực
5. **Device Simulation** - Mô phỏng thiết bị
6. **Web Technologies** - HTML/CSS/JavaScript
7. **System Integration** - Tích hợp hệ thống

---

## 🚀 **QUICK START COMMANDS**

```powershell
# Cách nhanh nhất - Chạy tất cả
cd "D:\1KTPM\Nam_4\Nam_4_HK1\IOT\Buoi5\lam\demo_chuong4_3_1-main\demo_chuong4_3_1-main"
.\scripts\run_all.ps1

# Cách 2 - Flutter Android
cd app_flutter
flutter run -d bd49a172

# Cách 3 - Development mode
flutter run -d web-server --web-port 8080
```

**🎉 Hệ thống sẵn sàng cho demo và học tập!**

