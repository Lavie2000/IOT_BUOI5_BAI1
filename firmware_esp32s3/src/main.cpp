#include <WiFi.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <DHT.h>
#include <Adafruit_NeoPixel.h>

// ===============================
// CONFIGURATION
// ===============================
const char* WIFI_SSID = "3q1";
const char* WIFI_PASSWORD = "12101210";
const char* MQTT_HOST = "192.168.43.108";
const int   MQTT_PORT = 1883;
const char* MQTT_USERNAME = "admin";
const char* MQTT_PASSWORD = "public";

const char* DEVICE_ID = "esp32_s3_iot_001";
const char* TOPIC_NS  = "lab/room1";

// GPIO setup
#define DHT_PIN         4
#define DHT_TYPE        DHT11
#define LED_EXT_PIN     5
#define STATUS_LED_PIN  2

// Motor pins
#define ENA 9
#define IN1 10
#define IN2 11

// NeoPixel
#define NEOPIXEL_PIN 48
#define NEOPIXEL_COUNT 1
Adafruit_NeoPixel strip(NEOPIXEL_COUNT, NEOPIXEL_PIN, NEO_GRB + NEO_KHZ800);

DHT dht(DHT_PIN, DHT_TYPE);
WiFiClient espClient;
PubSubClient mqttClient(espClient);

// state
bool ledState = false;
bool fanState = false;
bool motorRunning = false;
bool directionForward = true;

// timing
unsigned long lastSensorTime = 0;

// Topics
String topicSensor, topicCmd, topicState, topicOnline;

// ===============================
// FORWARD DECLARATIONS
// ===============================
void setupWiFi();
void setupMQTT();
void setupTopics();
void reconnectMQTT();
void onMessage(char* topic, byte* payload, unsigned int length);
void publishSensor();
void publishState();
void publishOnline(bool online);
void motorForward(int speed);
void motorBackward(int speed);
void motorStop();
void updateStatusLED();

// ===============================
// SETUP
// ===============================
void setup() {
  Serial.begin(115200);
  pinMode(LED_EXT_PIN, OUTPUT);
  pinMode(STATUS_LED_PIN, OUTPUT);
  pinMode(ENA, OUTPUT);
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  digitalWrite(LED_EXT_PIN, LOW);
  motorStop();

  dht.begin();
  strip.begin();
  strip.show();
  strip.setBrightness(60);

  setupWiFi();
  setupMQTT();
  setupTopics();
  Serial.println("System Ready!");
}

// ===============================
// LOOP
// ===============================
void loop() {
  if (!mqttClient.connected()) reconnectMQTT();
  mqttClient.loop();

  unsigned long now = millis();
  if (now - lastSensorTime > 3000) {
    publishSensor();
    lastSensorTime = now;
  }

  updateStatusLED();
}

// ===============================
// WIFI & MQTT
// ===============================
void setupWiFi() {
  Serial.printf("Connecting WiFi: %s\n", WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500); Serial.print(".");
  }
  Serial.printf("\nWiFi OK. IP: %s\n", WiFi.localIP().toString().c_str());
}

void setupMQTT() {
  mqttClient.setServer(MQTT_HOST, MQTT_PORT);
  mqttClient.setCallback(onMessage);
  reconnectMQTT();
}

void reconnectMQTT() {
  while (!mqttClient.connected()) {
    Serial.print("Connecting MQTT...");
    if (mqttClient.connect(DEVICE_ID, MQTT_USERNAME, MQTT_PASSWORD)) {
      Serial.println("connected!");
      mqttClient.subscribe(topicCmd.c_str());
      publishOnline(true);
    } else {
      Serial.print("failed, rc=");
      Serial.print(mqttClient.state());
      delay(2000);
    }
  }
}

// ===============================
// TOPICS
// ===============================
void setupTopics() {
  topicCmd    = String(TOPIC_NS) + "/device/cmd";
  topicState  = String(TOPIC_NS) + "/device/state";
  topicSensor = String(TOPIC_NS) + "/sensor/state";
  topicOnline = String(TOPIC_NS) + "/sys/online";
  Serial.println("MQTT Topics Ready.");
}

// ===============================
// MESSAGE HANDLER
// ===============================
void onMessage(char* topic, byte* payload, unsigned int length) {
  String msg;
  for (int i=0; i<length; i++) msg += (char)payload[i];
  Serial.printf("MQTT [%s]: %s\n", topic, msg.c_str());

  JsonDocument doc;
  DeserializationError err = deserializeJson(doc, msg);
  if (err) return;

  if (doc.containsKey("light")) {
    String cmd = doc["light"];
    if (cmd == "on") ledState = true;
    else if (cmd == "off") ledState = false;
    else ledState = !ledState;
    digitalWrite(LED_EXT_PIN, ledState);
    strip.setPixelColor(0, ledState ? strip.Color(0,255,0) : 0);
    strip.show();
  }

  // Handle "fan" command (map to motor)
  if (doc.containsKey("fan")) {
    String cmd = doc["fan"];
    if (cmd == "on") {
      directionForward = true;
      motorForward(255);
    } else if (cmd == "off") {
      motorStop();
    } else {
      // Toggle fan
      if (motorRunning) motorStop();
      else motorForward(255);
    }
  }

  // Handle "motor" command (direct control)
  if (doc.containsKey("motor")) {
    String cmd = doc["motor"];
    if (cmd == "forward") {
      directionForward = true;
      motorForward(255);
    } else if (cmd == "backward") {
      directionForward = false;
      motorBackward(255);
    } else if (cmd == "stop") {
      motorStop();
    }
  }

  publishState();
}

// ===============================
// SENSOR & STATE
// ===============================
void publishSensor() {
  float t = dht.readTemperature();
  float h = dht.readHumidity();
  if (isnan(t) || isnan(h)) return;

  JsonDocument doc;
  doc["temp_c"] = round(t * 10) / 10.0;  // ĐỔI TỪ "temp" → "temp_c"
  doc["hum_pct"] = round(h * 10) / 10.0; // ĐỔI TỪ "hum" → "hum_pct"
  doc["ts"] = millis();
  String payload;
  serializeJson(doc, payload);
  mqttClient.publish(topicSensor.c_str(), payload.c_str());
  Serial.printf("Published Sensor: %s\n", payload.c_str());
}

void publishState() {
  JsonDocument doc;
  doc["light"] = ledState ? "on" : "off";
  doc["fan"] = motorRunning ? "on" : "off";  // For Flutter/Web compatibility
  doc["motor"] = motorRunning ? (directionForward ? "forward" : "backward") : "stop";
  doc["rssi"] = WiFi.RSSI();
  String payload;
  serializeJson(doc, payload);
  mqttClient.publish(topicState.c_str(), payload.c_str(), true);
  Serial.printf("Published State: %s\n", payload.c_str());
}

void publishOnline(bool online) {
  JsonDocument doc;
  doc["online"] = online;
  String payload;
  serializeJson(doc, payload);
  mqttClient.publish(topicOnline.c_str(), payload.c_str(), true);
}

// ===============================
// MOTOR CONTROL
// ===============================
void motorForward(int speed) {
  analogWrite(ENA, speed);
  digitalWrite(IN1, HIGH);
  digitalWrite(IN2, LOW);
  motorRunning = true;
  Serial.println("Motor → Forward");
}

void motorBackward(int speed) {
  analogWrite(ENA, speed);
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, HIGH);
  motorRunning = true;
  Serial.println("Motor ← Backward");
}

void motorStop() {
  analogWrite(ENA, 0);
  digitalWrite(IN1, LOW);
  digitalWrite(IN2, LOW);
  motorRunning = false;
  Serial.println("Motor STOP");
}

// ===============================
// STATUS LED
// ===============================
void updateStatusLED() {
  static unsigned long lastBlink = 0;
  static bool led = false;
  unsigned long now = millis();

  if (WiFi.status() != WL_CONNECTED) {
    if (now - lastBlink > 1000) { led = !led; digitalWrite(STATUS_LED_PIN, led); lastBlink = now; }
  } else if (!mqttClient.connected()) {
    if (now - lastBlink > 250) { led = !led; digitalWrite(STATUS_LED_PIN, led); lastBlink = now; }
  } else {
    digitalWrite(STATUS_LED_PIN, HIGH);
  }
}