# ESP32-S3 Hardware Setup Guide

## Hardware Requirements

### Components Needed:
- **ESP32-S3 Development Board**
- **DHT11 Temperature & Humidity Sensor**
- **Breadboard and Jumper Wires**
- **10kΩ Pull-up Resistor** (some DHT11 modules have built-in)
- **220Ω Resistor** (if using external LED)

## Wiring Diagram

```
ESP32-S3 Pinout Configuration:
├── 🌡️ DHT11 Sensor
│   ├── VCC → 3.3V
│   ├── GND → GND
│   ├── Data → GPIO 4
│   └── Pull-up → 10kΩ resistor between VCC and Data (if not built-in)
│
├── 💡 Built-in LED Control
│   └── GPIO 2 → Built-in LED (no external wiring needed)
│
└── 🔌 Power Supply
    ├── USB-C → ESP32-S3 (for programming and power)
    └── External 5V → VIN (optional, for standalone operation)
```

## Pin Configuration

| Component | ESP32-S3 Pin | Notes |
|-----------|--------------|-------|
| DHT11 Data | GPIO 4 | Digital input with pull-up |
| Built-in LED | GPIO 2 | Digital output (varies by board) |
| Status LED | GPIO 2 | Same as built-in LED |
| Fan Relay | GPIO 6 | Disabled in software (for future use) |

## Arduino IDE Setup

### 1. Install ESP32 Board Package
```
File → Preferences → Additional Board Manager URLs:
https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json

Tools → Board → Boards Manager → Search "ESP32" → Install
```

### 2. Install Required Libraries
```
Tools → Manage Libraries → Install:
- DHT sensor library by Adafruit
- ArduinoJson by Benoit Blanchon
- PubSubClient by Nick O'Leary
```

### 3. Board Configuration
```
Tools → Board → ESP32 Arduino → ESP32S3 Dev Module
Tools → Port → Select your COM port
Tools → Upload Speed → 921600
Tools → Partition Scheme → Default 4MB with spiffs
```

## Configuration Steps

### 1. Update WiFi Credentials
Edit `firmware_esp32s3/src/main.cpp`:
```cpp
const char* WIFI_SSID = "YourWiFiName";        // Your WiFi network name
const char* WIFI_PASSWORD = "YourWiFiPassword"; // Your WiFi password
```

### 2. MQTT Broker Settings (Default: Public Broker)
```cpp
const char* MQTT_HOST = "test.mosquitto.org";   // Free public broker
const int MQTT_PORT = 1883;
const char* MQTT_USERNAME = "";                 // Leave empty for public broker
const char* MQTT_PASSWORD = "";                 // Leave empty for public broker
```

### 3. Device Identification
```cpp
const char* DEVICE_ID = "esp32_demo_001";       // Unique device name
const char* TOPIC_NS = "demo/room1";            // MQTT topic namespace
```

## Hardware Testing

### 1. DHT11 Sensor Test
- Connect DHT11 to GPIO 4
- Upload firmware
- Open Serial Monitor (115200 baud)
- Check for temperature/humidity readings every 3 seconds

### 2. LED Control Test
- Use Flutter app or Web dashboard
- Send light toggle command
- Verify built-in LED responds

### 3. MQTT Communication Test
- Check Serial Monitor for MQTT connection status
- Verify sensor data publishing
- Test command reception from mobile app

## Troubleshooting

### Common Issues:

**DHT11 Not Reading:**
- Check wiring connections
- Verify 3.3V power supply
- Ensure pull-up resistor is connected
- Try different GPIO pin if needed

**WiFi Connection Failed:**
- Verify SSID and password
- Check 2.4GHz network (ESP32 doesn't support 5GHz)
- Ensure network allows IoT devices

**MQTT Connection Issues:**
- Test internet connectivity
- Try alternative public brokers:
  - `broker.hivemq.com`
  - `test.mosquitto.org`
- Check firewall settings

**LED Not Responding:**
- Verify GPIO 2 is correct for your board
- Some boards use GPIO 48 for built-in LED
- Check device online status in app

## Advanced Configuration

### Custom MQTT Broker
If using your own MQTT broker:
```cpp
const char* MQTT_HOST = "192.168.1.100";       // Your broker IP
const char* MQTT_USERNAME = "your_username";
const char* MQTT_PASSWORD = "your_password";
```

### Alternative GPIO Pins
If GPIO 4 conflicts with your board:
```cpp
const int DHT_PIN = 15;  // Alternative pin for DHT11
```

### External LED (Optional)
To add external LED on GPIO 5:
```cpp
const int EXTERNAL_LED_PIN = 5;
// Add pinMode and digitalWrite in code
```

## System Integration

### 1. Upload Firmware
```bash
# Connect ESP32-S3 via USB
# Select correct port in Arduino IDE
# Click Upload button
```

### 2. Start Mobile App
```bash
cd app_flutter
flutter run -d your_device_id
```

### 3. Open Web Dashboard
```bash
cd web/src
python -m http.server 3000
# Open: http://localhost:3000/index.html
```

## Expected Behavior

### Normal Operation:
- **Built-in LED**: Solid ON when connected, blinking when disconnected
- **Serial Output**: Temperature/humidity readings every 3 seconds
- **MQTT Messages**: Sensor data published to `demo/room1/sensor/state`
- **Mobile Control**: LED toggles via app commands

### Status Indicators:
- **Solid LED**: WiFi + MQTT connected
- **Fast Blink**: WiFi connected, MQTT disconnected  
- **Slow Blink**: WiFi disconnected
- **Serial Messages**: Connection status and sensor readings

## Safety Notes

- Use 3.3V for DHT11 (not 5V)
- Double-check wiring before powering on
- Avoid short circuits on GPIO pins
- Use appropriate resistors for external components

## Next Steps

After successful hardware setup:
1. Test all functionality with real sensors
2. Add relay module for fan control (future)
3. Implement additional sensors as needed
4. Deploy to permanent installation location
