class RegisterDeviceDTO {
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final String location;
  
  RegisterDeviceDTO({
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    required this.location,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceName': deviceName,
      'deviceType': deviceType,
      'location': location,
    };
  }
}

