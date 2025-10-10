import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/device.dart';
import '../models/register_device_dto.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.43.108:8888/api';
  // static const String baseUrl = 'http://192.168.1.4:8888/api';

  
  // Lấy danh sách thiết bị
  Future<List<Device>> getDevices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/devices'));
      
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Device.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load devices: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting devices: $e');
      rethrow;
    }
  }
  
  // Đăng ký thiết bị mới
  Future<Device> registerDevice(RegisterDeviceDTO dto) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/devices/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dto.toJson()),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Device.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to register device: ${response.body}');
      }
    } catch (e) {
      print('Error registering device: $e');
      rethrow;
    }
  }
  
  // Gửi lệnh điều khiển
  Future<void> logCommand(String deviceId, String command, String deviceType, String source) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/devices/$deviceId/control'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'command': command,
          'deviceType': deviceType,
          'source': source,
        }),
      );
      
      if (response.statusCode == 200) {
        print('Command logged successfully: $command');
      } else {
        print('Failed to log command: ${response.statusCode}');
      }
    } catch (e) {
      print('Error logging command: $e');
      // Don't rethrow - logging failure shouldn't stop the app
    }
  }
  
  // Lấy lịch sử điều khiển của một thiết bị
  Future<List<dynamic>> getHistory(String deviceId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history/device/$deviceId')
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load history');
      }
    } catch (e) {
      print('Error getting history: $e');
      rethrow;
    }
  }
}

