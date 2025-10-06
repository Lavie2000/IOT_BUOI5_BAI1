import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MqttController(),
      child: MaterialApp(
        title: 'IoT Controller',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Inter', // Modern font similar to web dashboard
          cardTheme: CardThemeData(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            shadowColor: Colors.black.withOpacity(0.1),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
          appBarTheme: AppBarTheme(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.black87,
            titleTextStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const IoTControllerPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// class MqttController extends ChangeNotifier {
//   MqttServerClient? _client;
//   bool _isConnected = false;
//   bool _deviceOnline = false;
//   String _lightState = 'off';
//   String _fanState = 'off';
//   String _rssi = '--';
//   String _firmware = '--';
//   String _lastUpdate = '--';
//   double _temperature = 0.0;
//   double _humidity = 0.0;
//   // Light sensor removed - DHT11 only provides temp/humidity

//   // MQTT Configuration - WebSocket
//   // static const String _broker = '10.34.136.80';  // EMQX Broker IP

//   //   static const String _broker = '192.168.1.2';  // SGP
//   // static const int _port = 8083;  // WebSocket port for EMQX
//   // static const String _topicNamespace = 'lab/room1';  // Match với ESP32
//   // static const String _path = '/mqtt'; // thêm dòng này

//  static const String _broker = '192.168.1.2'; // địa chỉ EMQX LAN
//   static const int _port = 8083;               // WebSocket port
//   static const String _path = '/mqtt';         // WebSocket path
//   static const String _topicNamespace = 'lab/room1';
//   static const String _username = 'admin';
//   static const String _password = 'public';

//   // Getters
//   bool get isConnected => _isConnected;
//   bool get deviceOnline => _deviceOnline;
//   String get lightState => _lightState;
//   String get fanState => _fanState;
//   String get rssi => _rssi;
//   String get firmware => _firmware;
//   String get lastUpdate => _lastUpdate;
//   double get temperature => _temperature;
//   double get humidity => _humidity;
//   // Light level getter removed

// Future<void> connect() async {
//   try {
//     final clientId = 'flutter_mobile_${DateTime.now().millisecondsSinceEpoch}';
//     _client = MqttServerClient.withPort('ws://192.168.1.2/mqtt', clientId, 8083);

//     _client!.useWebSocket = true; // ✅ Bắt buộc để bật WebSocket
//     _client!.websocketProtocols = ['mqtt'];
//     _client!.keepAlivePeriod = 60;
//     _client!.connectTimeoutPeriod = 10000;
//     _client!.autoReconnect = true;
//     _client!.logging(on: true);

//     _client!.onConnected = _onConnected;
//     _client!.onDisconnected = _onDisconnected;
//     _client!.onSubscribed = _onSubscribed;

//     final connMessage = MqttConnectMessage()
//         .withClientIdentifier(clientId)
//         .startClean()
//         .withWillQos(MqttQos.atLeastOnce);

//     _client!.connectionMessage = connMessage;

//     print('🔄 Connecting to WebSocket MQTT: ws://192.168.1.2:8083/mqtt');
//     await _client!.connect('admin', 'public');

//     if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
//       print('✅ Connected to EMQX via WebSocket');
//       _isConnected = true;

//       _client!.subscribe('lab/room1/device/state', MqttQos.atLeastOnce);
//       _client!.subscribe('lab/room1/sensor/state', MqttQos.atMostOnce);
//       _client!.subscribe('lab/room1/sys/online', MqttQos.atLeastOnce);

//       _client!.updates!.listen(_onMessage);
//     } else {
//       print('⚠️ Connection failed - state: ${_client!.connectionStatus?.state}');
//     }
//   } catch (e) {
//     print('❌ MQTT WebSocket connection error: $e');
//   }
// }

//   void _onConnected() {
//     print('✅ MQTT Connected');
//     _isConnected = true;
//     notifyListeners();
//   }

//   void _onDisconnected() {
//     print('❌ MQTT Disconnected');
//     _isConnected = false;
//     _deviceOnline = false;
//     notifyListeners();
//   }

//   void _onSubscribed(String topic) {
//     print('📡 Subscribed to: $topic');
//   }

//   void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
//     for (final message in messages) {
//       final topic = message.topic;
//       final payload = MqttPublishPayload.bytesToStringAsString(
//         (message.payload as MqttPublishMessage).payload.message,
//       );

//       print('📥 Received [$topic]: $payload');

//       try {
//         final data = jsonDecode(payload);

//         if (topic.endsWith('/device/state')) {
//           _lightState = data['light'] ?? 'unknown';
//           _fanState = data['fan'] ?? 'unknown';
//           _rssi = '${data['rssi'] ?? 0} dBm';
//           _firmware = data['fw'] ?? '--';
//           _lastUpdate = DateTime.now().toString().substring(11, 19);
//         } else if (topic.endsWith('/sys/online')) {
//           _deviceOnline = data['online'] ?? false;
//         } else if (topic.endsWith('/sensor/state')) {
//           _temperature = (data['temp_c'] ?? 0.0).toDouble();
//           _humidity = (data['hum_pct'] ?? 0.0).toDouble();
//           // Light level removed - DHT11 sensor only
//         }

//         notifyListeners();
//       } catch (e) {
//         print('❌ Error parsing message: $e');
//       }
//     }
//   }

//   void sendCommand(String device, String action) {
//     if (!_isConnected || _client == null) {
//       print('❌ MQTT not connected');
//       return;
//     }

//     final command = {device: action};
//     final payload = jsonEncode(command);
//     final topic = '$_topicNamespace/device/cmd';

//     final builder = MqttClientPayloadBuilder();
//     builder.addString(payload);

//     _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
//     print('📤 Sent command [$topic]: $payload');
//   }

//   void toggleLight() {
//     sendCommand('light', 'toggle');
//   }

//   void toggleFan() {
//     sendCommand('fan', 'toggle');
//   }

//   @override
//   void dispose() {
//     _client?.disconnect();
//     super.dispose();
//   }
// }

class MqttController extends ChangeNotifier {
  // static const String _broker = '192.168.1.3'; // Địa chỉ EMQX LAN
  static const String _broker = '192.168.43.108'; // 3q1

  static const int _port = 8083; // WebSocket port
  static const String _path = '/mqtt'; // WebSocket path
  static const String _topicNamespace = 'lab/room1';
  static const String _username = 'admin';
  static const String _password = 'public';

  MqttServerClient? _client;
  bool _isConnected = false;
  bool _deviceOnline = false;
  String _lightState = 'off';
  String _fanState = 'off';
  String _rssi = '--';
  String _firmware = '--';
  String _lastUpdate = '--';
  double _temperature = 0.0;
  double _humidity = 0.0;

  // Getters
  bool get isConnected => _isConnected;
  bool get deviceOnline => _deviceOnline;
  String get lightState => _lightState;
  String get fanState => _fanState;
  String get rssi => _rssi;
  String get firmware => _firmware;
  String get lastUpdate => _lastUpdate;
  double get temperature => _temperature;
  double get humidity => _humidity;

  Future<void> connect() async {
    try {
      final clientId = 'flutter_${DateTime.now().millisecondsSinceEpoch}';
      _client = MqttServerClient.withPort(_broker, clientId, _port);

      _client!.useWebSocket = true; // ✅ Bắt buộc để bật WebSocket
      _client!.websocketProtocols = ['mqtt'];
      // _client!.websocketPath = _path;
      _client = MqttServerClient.withPort(
        // 'ws://192.168.1.3/mqtt',
        'ws://192.168.43.108/mqtt',

        clientId,
        8083,
      );
      _client!.useWebSocket = true;
      _client!.websocketProtocols = ['mqtt'];

      _client!.keepAlivePeriod = 60;
      _client!.connectTimeoutPeriod = 10000;
      _client!.autoReconnect = true;
      _client!.logging(on: true);

      _client!.onConnected = _onConnected;
      _client!.onDisconnected = _onDisconnected;
      _client!.onSubscribed = _onSubscribed;

      final connMessage = MqttConnectMessage()
          .withClientIdentifier(clientId)
          .withWillQos(MqttQos.atMostOnce);

      _client!.connectionMessage = connMessage;

      print('🔄 Connecting to ws://$_broker:$_port$_path');
      await _client!.connect(_username, _password);

      if (_client!.connectionStatus!.state == MqttConnectionState.connected) {
        print('✅ Connected to EMQX via WebSocket');
        _isConnected = true;

        _client!.subscribe(
          '$_topicNamespace/device/state',
          MqttQos.atLeastOnce,
        );
        _client!.subscribe('$_topicNamespace/sensor/state', MqttQos.atMostOnce);
        _client!.subscribe('$_topicNamespace/sys/online', MqttQos.atLeastOnce);

        _client!.updates!.listen(_onMessage);
      } else {
        print('⚠️ Connection failed: ${_client!.connectionStatus}');
      }
    } catch (e) {
      print('❌ MQTT connection error: $e');
      _isConnected = false;
      notifyListeners();
    }
  }

  void _onConnected() {
    print('✅ MQTT Connected');
    _isConnected = true;
    notifyListeners();
  }

  void _onDisconnected() {
    print('❌ MQTT Disconnected');
    _isConnected = false;
    _deviceOnline = false;
    notifyListeners();
  }

  void _onSubscribed(String topic) {
    print('📡 Subscribed to: $topic');
  }

  void _onMessage(List<MqttReceivedMessage<MqttMessage>> messages) {
    for (final message in messages) {
      final topic = message.topic;
      final payload = MqttPublishPayload.bytesToStringAsString(
        (message.payload as MqttPublishMessage).payload.message,
      );

      print('📥 Received [$topic]: $payload');
      try {
        final data = jsonDecode(payload);

        if (topic.endsWith('/device/state')) {
          _lightState = data['light'] ?? 'unknown';
          _fanState = data['fan'] ?? 'unknown';
          _rssi = '${data['rssi'] ?? 0} dBm';
          _firmware = data['fw'] ?? '--';
          _lastUpdate = DateTime.now().toString().substring(11, 19);
        } else if (topic.endsWith('/sys/online')) {
          _deviceOnline = data['online'] ?? false;
        } else if (topic.endsWith('/sensor/state')) {
          _temperature = (data['temp_c'] ?? 0.0).toDouble();
          _humidity = (data['hum_pct'] ?? 0.0).toDouble();
        }

        notifyListeners();
      } catch (e) {
        print('❌ Error parsing message: $e');
      }
    }
  }

  void sendCommand(String device, String action) {
    if (!_isConnected || _client == null) {
      print('❌ MQTT not connected');
      return;
    }

    final payload = jsonEncode({device: action});
    final builder = MqttClientPayloadBuilder()..addString(payload);
    _client!.publishMessage(
      '$_topicNamespace/device/cmd',
      MqttQos.atLeastOnce,
      builder.payload!,
    );
    print('📤 Sent command: $payload');
  }

  void toggleLight() => sendCommand('light', 'toggle');
  void toggleFan() => sendCommand('fan', 'toggle');

  @override
  void dispose() {
    _client?.disconnect();
    super.dispose();
  }
}

class IoTControllerPage extends StatefulWidget {
  const IoTControllerPage({super.key});

  @override
  State<IoTControllerPage> createState() => _IoTControllerPageState();
}

class _IoTControllerPageState extends State<IoTControllerPage> {
  @override
  void initState() {
    super.initState();
    // Connect to MQTT when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MqttController>().connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MqttController>(
      builder: (context, mqtt, child) {
        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text('🏠 IoT Device Controller'),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.shade400.withOpacity(0.8),
                    Colors.purple.shade400.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade50,
                  Colors.purple.shade50,
                  Colors.white,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Status Cards with enhanced design
                    Row(
                      children: [
                        Expanded(
                          child: _StatusCard(
                            title: 'MQTT Broker',
                            status: mqtt.isConnected
                                ? 'Connected'
                                : 'Connecting...',
                            color:
                                mqtt.isConnected ? Colors.green : Colors.orange,
                            icon:
                                mqtt.isConnected ? Icons.wifi : Icons.wifi_off,
                            gradient: mqtt.isConnected
                                ? [Colors.green.shade400, Colors.green.shade600]
                                : [
                                    Colors.orange.shade400,
                                    Colors.orange.shade600,
                                  ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatusCard(
                            title: 'ESP32 Device',
                            status: mqtt.deviceOnline ? 'Online' : 'Offline',
                            color:
                                mqtt.deviceOnline ? Colors.blue : Colors.grey,
                            icon: mqtt.deviceOnline
                                ? Icons.developer_board
                                : Icons.developer_board_off,
                            gradient: mqtt.deviceOnline
                                ? [Colors.blue.shade400, Colors.blue.shade600]
                                : [Colors.grey.shade400, Colors.grey.shade600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Sensor Data Card
                    if (mqtt.deviceOnline) ...[
                      Card(
                        elevation: 6,
                        shadowColor: Colors.green.withOpacity(0.3),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade50,
                                Colors.teal.shade50,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.sensors,
                                        color: Colors.green.shade700,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Sensor Data',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade800,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    _SensorTile(
                                      icon: Icons.thermostat,
                                      label: 'Temperature',
                                      value:
                                          '${mqtt.temperature.toStringAsFixed(1)}°C',
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 20),
                                    _SensorTile(
                                      icon: Icons.water_drop,
                                      label: 'Humidity',
                                      value:
                                          '${mqtt.humidity.toStringAsFixed(1)}%',
                                      color: Colors.blue,
                                    ),
                                    // Light sensor tile removed - DHT11 only
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Control Cards with modern design
                    Expanded(
                      child: Column(
                        children: [
                          _ControlCard(
                            title: '💡 Smart Light',
                            icon: Icons.lightbulb_rounded,
                            value: mqtt.lightState == 'on',
                            onChanged: mqtt.isConnected && mqtt.deviceOnline
                                ? (value) {
                                    mqtt.toggleLight();
                                    _showFeedback(
                                      context,
                                      'Light command sent!',
                                    );
                                  }
                                : null,
                            subtitle:
                                'Status: ${mqtt.lightState.toUpperCase()}',
                            activeGradient: [
                              Colors.orange.shade400,
                              Colors.orange.shade600,
                            ],
                          ),

                          const SizedBox(height: 16),

                          _ControlCard(
                            title: '🌀 Smart Fan (Software Only)',
                            icon: Icons.air_rounded,
                            value: mqtt.fanState == 'on',
                            onChanged: mqtt.isConnected && mqtt.deviceOnline
                                ? (value) {
                                    mqtt.toggleFan();
                                    _showFeedback(
                                      context,
                                      'Fan command sent (no hardware)!',
                                    );
                                  }
                                : null,
                            subtitle:
                                'Status: ${mqtt.fanState.toUpperCase()} (No Hardware)',
                            activeGradient: [
                              Colors.cyan.shade400,
                              Colors.cyan.shade600,
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Enhanced Device Info Card
                          Card(
                            elevation: 8,
                            shadowColor: Colors.purple.withOpacity(0.3),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.purple.shade50,
                                    Colors.blue.shade50,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.purple.shade100,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.info_rounded,
                                            color: Colors.purple.shade700,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Device Information',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.purple.shade800,
                                              ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    _InfoRow('📡 WiFi Signal', mqtt.rssi),
                                    _InfoRow('💿 Firmware', mqtt.firmware),
                                    _InfoRow('⏰ Last Update', mqtt.lastUpdate),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Connection status info
                    if (!mqtt.isConnected)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange.shade300),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Connecting to MQTT broker...',
                              style: TextStyle(color: Colors.orange.shade700),
                            ),
                          ],
                        ),
                      ),

                    // Sync status indicator
                    if (mqtt.isConnected && mqtt.deviceOnline)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.sync,
                              color: Colors.green.shade700,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Synced with IoT System',
                              style: TextStyle(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFeedback(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _InfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.purple.shade700,
              fontSize: 14,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: Colors.purple.shade800,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String status;
  final Color color;
  final IconData icon;
  final List<Color> gradient;

  const _StatusCard({
    required this.title,
    required this.status,
    required this.color,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: color.withOpacity(0.3),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String subtitle;
  final List<Color> activeGradient;

  const _ControlCard({
    required this.title,
    required this.icon,
    required this.value,
    required this.onChanged,
    required this.subtitle,
    required this.activeGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: value ? 8 : 4,
      shadowColor: value
          ? activeGradient.first.withOpacity(0.3)
          : Colors.black.withOpacity(0.1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: value
              ? LinearGradient(
                  colors: activeGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.grey.shade100, Colors.grey.shade200],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: value
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: value ? Colors.white : Colors.grey.shade600,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: value ? Colors.white : Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: value ? Colors.white70 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 1.2,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Colors.white,
                  activeTrackColor: Colors.white.withOpacity(0.3),
                  inactiveThumbColor: Colors.grey.shade400,
                  inactiveTrackColor: Colors.grey.shade300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SensorTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SensorTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
