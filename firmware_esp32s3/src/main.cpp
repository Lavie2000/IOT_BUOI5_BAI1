/*
 * ESP32-S3 IoT Demo Firmware (Fixed version for Arduino IDE)
 * 
 * - Dùng millis() thay cho WiFi.getTime()
 * - MQTT có username/password (admin/public)
 * - Dùng LED on-board hoặc relay ngoài
 */

 #include <WiFi.h>
 #include <PubSubClient.h>
 #include <ArduinoJson.h>
 #include <DHT.h>
 
 // =============================================================================
 // CONFIGURATION - Modify these values for your setup
 // =============================================================================
 
 // WiFi Configuration
 const char* WIFI_SSID = "3q1";        // WiFi SSID
 const char* WIFI_PASSWORD = "12101210";  // WiFi password
 
 // MQTT Broker Configuration
 const char* MQTT_HOST = "192.168.43.108";   // EMQX Broker IP
 const int MQTT_PORT = 1883;
 const char* MQTT_USERNAME = "admin";        
 const char* MQTT_PASSWORD = "public";       
 
 // Device Configuration
 const char* DEVICE_ID = "esp32_demo_001";      
 const char* FIRMWARE_VERSION = "demo1-1.0.0";  
 const char* TOPIC_NS = "lab/room1";            
 
 // GPIO Pin Configuration - ESP32-S3
 const int DHT_PIN = 4;            // DHT11 sensor
 const int LIGHT_RELAY_PIN = 5;    // Relay or LED control
 const int FAN_RELAY_PIN = 6;      // Fan relay (not used)
 const int STATUS_LED_PIN = 2;     // Built-in LED
 
 // DHT11 Sensor Configuration
 #define DHT_TYPE DHT11
 DHT dht(DHT_PIN, DHT_TYPE);
 
 // Timing Configuration
 const unsigned long SENSOR_PUBLISH_INTERVAL = 3000;   // 3 seconds
 const unsigned long HEARTBEAT_INTERVAL = 15000;       // 15 seconds
 const unsigned long WIFI_RECONNECT_INTERVAL = 5000;   // 5 seconds
 const unsigned long MQTT_RECONNECT_INTERVAL = 5000;   // 5 seconds
 const unsigned long COMMAND_DEBOUNCE_DELAY = 500;     // 500ms debounce
 
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
 unsigned long lastCommandTime = 0;
 
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
   
   // Initialize GPIO pins
   initGPIO();
   
   // Initialize MQTT topics
   initTopics();
   
   // Initialize WiFi
   initWiFi();
   
   // Initialize MQTT
   initMQTT();
   
   Serial.println("=== Setup Complete ===\n");
 }
 
 // =============================================================================
 // MAIN LOOP
 // =============================================================================
 
 void loop() {
   unsigned long currentTime = millis();
   
   // Check WiFi connection
   checkWiFi(currentTime);
   
   // Check MQTT connection
   checkMQTT(currentTime);
   
   // Handle MQTT messages
   if (mqttClient.connected()) {
     mqttClient.loop();
     
     // Publish sensor data
     if (currentTime - lastSensorPublish >= SENSOR_PUBLISH_INTERVAL) {
       publishSensorData();
       lastSensorPublish = currentTime;
     }
     
     // Publish heartbeat (device state)
     if (currentTime - lastHeartbeat >= HEARTBEAT_INTERVAL) {
       publishDeviceState();
       lastHeartbeat = currentTime;
     }
   }
   
   // Update status LED
   updateStatusLED();
   
   delay(100); // Small delay
 }
 
 // =============================================================================
 // INITIALIZATION FUNCTIONS
 // =============================================================================
 
 void initGPIO() {
   Serial.println("Initializing GPIO pins...");
   
   // Initialize DHT11 sensor
   dht.begin();
   Serial.printf("DHT11 sensor initialized on pin: %d\n", DHT_PIN);
   
   // Configure relay pins as outputs
   pinMode(LIGHT_RELAY_PIN, OUTPUT);
   pinMode(FAN_RELAY_PIN, OUTPUT);
   pinMode(STATUS_LED_PIN, OUTPUT);
   
   // Initialize relays to OFF state
   digitalWrite(LIGHT_RELAY_PIN, LOW);
   digitalWrite(FAN_RELAY_PIN, LOW);
   digitalWrite(STATUS_LED_PIN, LOW);
   
   Serial.printf("Light relay pin: %d\n", LIGHT_RELAY_PIN);
   Serial.printf("Fan relay pin: %d (disabled)\n", FAN_RELAY_PIN);
   Serial.printf("Status LED pin: %d\n", STATUS_LED_PIN);
 }
 
 void initTopics() {
   topicSensorState = String(TOPIC_NS) + "/sensor/state";
   topicDeviceState = String(TOPIC_NS) + "/device/state";
   topicDeviceCmd = String(TOPIC_NS) + "/device/cmd";
   topicSysOnline = String(TOPIC_NS) + "/sys/online";
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
   
   String lwt = "{\"online\":false}";
   
   bool connected = mqttClient.connect(
     DEVICE_ID,
     MQTT_USERNAME,
     MQTT_PASSWORD,
     topicSysOnline.c_str(),
     1, true, lwt.c_str()
   );
   
   if (connected) {
     Serial.println("MQTT connected!");
     mqttClient.subscribe(topicDeviceCmd.c_str(), 1);
     publishOnlineStatus(true);
     publishDeviceState();
     deviceOnline = true;
   } else {
     Serial.printf("MQTT connection failed! State: %d\n", mqttClient.state());
     deviceOnline = false;
   }
 }
 
 void onMqttMessage(char* topic, byte* payload, unsigned int length) {
   String message;
   for (int i = 0; i < length; i++) message += (char)payload[i];
   Serial.printf("Received [%s]: %s\n", topic, message.c_str());
   if (String(topic) == topicDeviceCmd) handleDeviceCommand(message);
 }
 
 void handleDeviceCommand(String message) {
   JsonDocument doc;
   if (deserializeJson(doc, message)) return;
   
   if (doc.containsKey("light")) {
     String cmd = doc["light"].as<String>();
     lightState = (cmd == "on") ? true : (cmd == "off") ? false : !lightState;
     digitalWrite(LIGHT_RELAY_PIN, lightState ? HIGH : LOW);
   }
   
   if (doc.containsKey("fan")) {
     String cmd = doc["fan"].as<String>();
     fanState = (cmd == "on") ? true : (cmd == "off") ? false : !fanState;
     // Fan relay disabled
   }
   
   publishDeviceState();
 }
 
 // =============================================================================
 // PUBLISHING FUNCTIONS
 // =============================================================================
 
 void publishSensorData() {
   float temperature = dht.readTemperature();
   float humidity = dht.readHumidity();
   if (isnan(temperature) || isnan(humidity)) return;
   
   JsonDocument doc;
   doc["ts"] = millis();   // fixed
   doc["temp_c"] = temperature;
   doc["hum_pct"] = humidity;
   
   String payload;
   serializeJson(doc, payload);
   mqttClient.publish(topicSensorState.c_str(), payload.c_str(), false);
 }
 
 void publishDeviceState() {
   JsonDocument doc;
   doc["ts"] = millis();   // fixed
   doc["light"] = lightState ? "on" : "off";
   doc["fan"] = fanState ? "on" : "off";
   doc["rssi"] = WiFi.RSSI();
   doc["fw"] = FIRMWARE_VERSION;
   
   String payload;
   serializeJson(doc, payload);
   mqttClient.publish(topicDeviceState.c_str(), payload.c_str(), true);
 }
 
 void publishOnlineStatus(bool online) {
   JsonDocument doc;
   doc["online"] = online;
   
   String payload;
   serializeJson(doc, payload);
   mqttClient.publish(topicSysOnline.c_str(), payload.c_str(), true);
 }
 
 // =============================================================================
 // LED STATUS
 // =============================================================================
 
 void updateStatusLED() {
   static unsigned long lastBlink = 0;
   static bool ledState = false;
   unsigned long now = millis();
   
   if (WiFi.status() == WL_CONNECTED && mqttClient.connected()) {
     digitalWrite(STATUS_LED_PIN, HIGH); // ON
   } else if (WiFi.status() == WL_CONNECTED) {
     if (now - lastBlink > 250) {
       ledState = !ledState;
       digitalWrite(STATUS_LED_PIN, ledState);
       lastBlink = now;
     }
   } else {
     if (now - lastBlink > 1000) {
       ledState = !ledState;
       digitalWrite(STATUS_LED_PIN, ledState);
       lastBlink = now;
     }
   }
 }
 