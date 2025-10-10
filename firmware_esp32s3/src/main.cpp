#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <DHT.h>
#include <Adafruit_NeoPixel.h>

// =============================================================================
// CONFIGURATION
// =============================================================================

// WiFi Configuration
// const char* WIFI_SSID = "3q1";
// const char* WIFI_PASSWORD = "12101210";

const char* WIFI_SSID = "SGP";
const char* WIFI_PASSWORD = "12100204";
// MQTT Broker Configuration
// const char* MQTT_HOST = "192.168.43.108"; //3q1
const char* MQTT_HOST = "192.168.1.4"; //SGP
const int MQTT_PORT = 1883;
const char* MQTT_USERNAME = "admin";
const char* MQTT_PASSWORD = "public";

// Device Configuration
const char* DEVICE_ID = "esp32_demo_001";
const char* FIRMWARE_VERSION = "demo1-1.0.0";
const char* TOPIC_NS = "lab/room1";

// GPIO Pin Configuration - ESP32-S3
const int DHT_PIN = 4;
const int LIGHT_RELAY_PIN = 5;
const int FAN_RELAY_PIN = 6;
const int STATUS_LED_PIN = 2;

// NEOPIXEL Configuration
#define NEOPIXEL_PIN 48
#define NEOPIXEL_COUNT 1
Adafruit_NeoPixel strip(NEOPIXEL_COUNT, NEOPIXEL_PIN, NEO_GRB + NEO_KHZ800);

// DHT11 Sensor Configuration
#define DHT_TYPE DHT11
DHT dht(DHT_PIN, DHT_TYPE);

// Timing Configuration
const unsigned long SENSOR_PUBLISH_INTERVAL = 3000;
const unsigned long HEARTBEAT_INTERVAL = 15000;
const unsigned long WIFI_RECONNECT_INTERVAL = 5000;
const unsigned long MQTT_RECONNECT_INTERVAL = 5000;

// =============================================================================
// GLOBAL VARIABLES
// =============================================================================

WiFiClient espClient;
PubSubClient mqttClient(espClient);

// Device state
bool lightState = false;
bool fanState = false;
bool deviceOnline = false;

// Timing variables
unsigned long lastSensorPublish = 0;
unsigned long lastHeartbeat = 0;
unsigned long lastWifiCheck = 0;
unsigned long lastMqttCheck = 0;

// MQTT Topics
String topicSensorState;
String topicDeviceState;
String topicDeviceCmd;
String topicSysOnline;

// =============================================================================
// SETUP FUNCTION
// =============================================================================

void setup() {
  Serial.begin(115200);
  delay(1000);
  
  Serial.println("\n=== ESP32-S3 IoT Demo Starting ===");
  Serial.printf("Device ID: %s\n", DEVICE_ID);
  Serial.printf("Firmware: %s\n", FIRMWARE_VERSION);
  Serial.printf("Topic Namespace: %s\n", TOPIC_NS);

  initNeoPixel();
  initGPIO();
  initTopics();
  initWiFi();
  initMQTT();

  Serial.println("=== Setup Complete ===\n");
}

// =============================================================================
// MAIN LOOP
// =============================================================================

void loop() {
  unsigned long currentTime = millis();

  checkWiFi(currentTime);
  checkMQTT(currentTime);

  if (mqttClient.connected()) {
    mqttClient.loop();

    if (currentTime - lastSensorPublish >= SENSOR_PUBLISH_INTERVAL) {
      publishSensorData();
      lastSensorPublish = currentTime;
    }

    if (currentTime - lastHeartbeat >= HEARTBEAT_INTERVAL) {
      publishDeviceState();
      lastHeartbeat = currentTime;
    }
  }

  updateStatusLED();
  delay(100);
}

// =============================================================================
// INITIALIZATION FUNCTIONS
// =============================================================================

void initNeoPixel() {
  Serial.println("Initializing NeoPixel...");
  strip.begin();
  strip.show();
  strip.setBrightness(50);
  Serial.printf("NeoPixel initialized on pin: %d\n", NEOPIXEL_PIN);
}

void initGPIO() {
  Serial.println("Initializing GPIO pins...");
  dht.begin();
  
  pinMode(LIGHT_RELAY_PIN, OUTPUT);
  pinMode(FAN_RELAY_PIN, OUTPUT);
  pinMode(STATUS_LED_PIN, OUTPUT);

  digitalWrite(LIGHT_RELAY_PIN, LOW);
  digitalWrite(FAN_RELAY_PIN, LOW);
  digitalWrite(STATUS_LED_PIN, LOW);

  Serial.printf("DHT11 sensor: pin %d\n", DHT_PIN);
  Serial.printf("Light relay: pin %d\n", LIGHT_RELAY_PIN);
  Serial.printf("Status LED: pin %d\n", STATUS_LED_PIN);
}

void initTopics() {
  topicSensorState = String(TOPIC_NS) + "/sensor/state";
  topicDeviceState = String(TOPIC_NS) + "/device/state";
  topicDeviceCmd = String(TOPIC_NS) + "/device/cmd";
  topicSysOnline = String(TOPIC_NS) + "/sys/online";
  
  Serial.println("MQTT Topics:");
  Serial.printf("  Sensor: %s\n", topicSensorState.c_str());
  Serial.printf("  Device: %s\n", topicDeviceState.c_str());
  Serial.printf("  Command: %s\n", topicDeviceCmd.c_str());
  Serial.printf("  Online: %s\n", topicSysOnline.c_str());
}

// =============================================================================
// WIFI FUNCTIONS
// =============================================================================

void initWiFi() {
  Serial.printf("Connecting to WiFi: %s\n", WIFI_SSID);
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.printf("\nWiFi connected! IP: %s\n", WiFi.localIP().toString().c_str());
    Serial.printf("RSSI: %d dBm\n", WiFi.RSSI());
  } else {
    Serial.println("\nWiFi connection failed!");
  }
}

void checkWiFi(unsigned long currentTime) {
  if (currentTime - lastWifiCheck < WIFI_RECONNECT_INTERVAL) return;
  lastWifiCheck = currentTime;

  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi disconnected. Reconnecting...");
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  }
}

// =============================================================================
// MQTT FUNCTIONS
// =============================================================================

void initMQTT() {
  mqttClient.setServer(MQTT_HOST, MQTT_PORT);
  mqttClient.setCallback(onMqttMessage);
  connectMQTT();
}

void checkMQTT(unsigned long currentTime) {
  if (currentTime - lastMqttCheck < MQTT_RECONNECT_INTERVAL) return;
  lastMqttCheck = currentTime;

  if (WiFi.status() == WL_CONNECTED && !mqttClient.connected()) {
    Serial.println("MQTT disconnected. Reconnecting...");
    connectMQTT();
  }
}

void connectMQTT() {
  if (WiFi.status() != WL_CONNECTED) return;

  // Last Will and Testament - thông báo khi mất kết nối
  String lwt = "{\"online\":false}";
  
  bool connected = mqttClient.connect(
    DEVICE_ID,
    MQTT_USERNAME,
    MQTT_PASSWORD,
    topicSysOnline.c_str(),  // LWT topic
    1,                        // QoS
    true,                     // retain
    lwt.c_str()              // LWT message
  );

  if (connected) {
    Serial.println("MQTT connected!");
    
    // Subscribe to command topic
    mqttClient.subscribe(topicDeviceCmd.c_str(), 1);
    Serial.printf("Subscribed to: %s\n", topicDeviceCmd.c_str());
    
    // Publish online status NGAY LẬP TỨC
    publishOnlineStatus(true);
    
    // Publish device state
    publishDeviceState();
    
    deviceOnline = true;
  } else {
    Serial.printf("MQTT connection failed! State: %d\n", mqttClient.state());
    deviceOnline = false;
  }
}

void onMqttMessage(char* topic, byte* payload, unsigned int length) {
  String message;
  for (int i = 0; i < length; i++)
    message += (char)payload[i];

  Serial.printf("Received [%s]: %s\n", topic, message.c_str());

  if (String(topic) == topicDeviceCmd)
    handleDeviceCommand(message);
}

void handleDeviceCommand(String message) {
  // Parse JSON command
  JsonDocument doc;
  DeserializationError error = deserializeJson(doc, message);
  
  if (error) {
    Serial.print("JSON parse error: ");
    Serial.println(error.c_str());
    return;
  }

  bool stateChanged = false;

  // Xử lý lệnh LIGHT
  if (doc.containsKey("light")) {
    String cmd = doc["light"].as<String>();
    
    if (cmd == "on") {
      lightState = true;
    } else if (cmd == "off") {
      lightState = false;
    } else {
      lightState = !lightState; // Toggle
    }
    
    // Điều khiển relay
    digitalWrite(LIGHT_RELAY_PIN, lightState ? HIGH : LOW);
    
    // Điều khiển NeoPixel
    if (lightState) {
      strip.setPixelColor(0, strip.Color(0, 255, 0)); // XANH LÁ
      Serial.println("Light ON - NeoPixel GREEN");
    } else {
      strip.setPixelColor(0, strip.Color(0, 0, 0));   // TẮT
      Serial.println("Light OFF - NeoPixel OFF");
    }
    strip.show();
    
    stateChanged = true;
  }

  // Xử lý lệnh FAN (chỉ software)
  if (doc.containsKey("fan")) {
    String cmd = doc["fan"].as<String>();
    fanState = (cmd == "on") ? true : (cmd == "off") ? false : !fanState;
    Serial.printf("Fan state: %s (software only)\n", fanState ? "ON" : "OFF");
    stateChanged = true;
  }

  // Publish device state ngay lập tức khi có thay đổi
  if (stateChanged) {
    publishDeviceState();
  }
}

// =============================================================================
// PUBLISHING FUNCTIONS
// =============================================================================

void publishSensorData() {
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();

  if (isnan(temperature) || isnan(humidity)) {
    Serial.println("DHT sensor read error!");
    return;
  }

  JsonDocument doc;
  doc["ts"] = millis();
  doc["temp_c"] = round(temperature * 10) / 10.0; // Làm tròn 1 chữ số
  doc["hum_pct"] = round(humidity * 10) / 10.0;

  String payload;
  serializeJson(doc, payload);
  
  bool published = mqttClient.publish(topicSensorState.c_str(), payload.c_str(), false);
  if (published) {
    Serial.printf("Published sensor: %s\n", payload.c_str());
  }
}

void publishDeviceState() {
  JsonDocument doc;
  doc["ts"] = millis();
  doc["light"] = lightState ? "on" : "off";
  doc["fan"] = fanState ? "on" : "off";
  doc["rssi"] = WiFi.RSSI();
  doc["fw"] = FIRMWARE_VERSION;

  String payload;
  serializeJson(doc, payload);
  
  // Publish với retained = true để web app nhận được state ngay khi connect
  bool published = mqttClient.publish(topicDeviceState.c_str(), payload.c_str(), true);
  if (published) {
    Serial.printf("Published device state: %s\n", payload.c_str());
  }
}

void publishOnlineStatus(bool online) {
  JsonDocument doc;
  doc["online"] = online;

  String payload;
  serializeJson(doc, payload);
  
  // Publish với retained = true
  bool published = mqttClient.publish(topicSysOnline.c_str(), payload.c_str(), true);
  if (published) {
    Serial.printf("Published online status: %s\n", online ? "ONLINE" : "OFFLINE");
  }
}

// =============================================================================
// LED STATUS
// =============================================================================

void updateStatusLED() {
  static unsigned long lastBlink = 0;
  static bool ledState = false;
  unsigned long now = millis();

  if (WiFi.status() == WL_CONNECTED && mqttClient.connected()) {
    // Kết nối ổn định - LED sáng liên tục
    digitalWrite(STATUS_LED_PIN, HIGH);
  } else if (WiFi.status() == WL_CONNECTED) {
    // WiFi OK nhưng MQTT mất - nhấp nháy nhanh
    if (now - lastBlink > 250) {
      ledState = !ledState;
      digitalWrite(STATUS_LED_PIN, ledState);
      lastBlink = now;
    }
  } else {
    // WiFi mất - nhấp nháy chậm
    if (now - lastBlink > 1000) {
      ledState = !ledState;
      digitalWrite(STATUS_LED_PIN, ledState);
      lastBlink = now;
    }
  }
}