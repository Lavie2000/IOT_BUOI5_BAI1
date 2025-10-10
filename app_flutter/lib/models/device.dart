class Device {
  final int id;
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final String? location;
  final String status;
  final String? currentState;
  final String? firmware;
  final int? rssi;
  final DateTime registeredAt;
  final DateTime lastSeen;
  
  Device({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    this.location,
    required this.status,
    this.currentState,
    this.firmware,
    this.rssi,
    required this.registeredAt,
    required this.lastSeen,
  });
  
  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      deviceId: json['deviceId'],
      deviceName: json['deviceName'],
      deviceType: json['deviceType'],
      location: json['location'],
      status: json['status'],
      currentState: json['currentState'],
      firmware: json['firmware'],
      rssi: json['rssi'],
      registeredAt: DateTime.parse(json['registeredAt']),
      lastSeen: DateTime.parse(json['lastSeen']),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'location': location,
      'status': status,
      'currentState': currentState,
      'firmware': firmware,
      'rssi': rssi,
      'registeredAt': registeredAt.toIso8601String(),
      'lastSeen': lastSeen.toIso8601String(),
    };
  }
}

