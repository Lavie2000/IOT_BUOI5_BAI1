import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/register_device_dto.dart';

class RegisterDeviceScreen extends StatefulWidget {
  const RegisterDeviceScreen({super.key});

  @override
  State<RegisterDeviceScreen> createState() => _RegisterDeviceScreenState();
}

class _RegisterDeviceScreenState extends State<RegisterDeviceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deviceIdController = TextEditingController();
  final _deviceNameController = TextEditingController();
  String _deviceType = 'light';
  String _location = 'room1';
  bool _isSubmitting = false;
  
  final ApiService _apiService = ApiService();
  
  @override
  void dispose() {
    _deviceIdController.dispose();
    _deviceNameController.dispose();
    super.dispose();
  }
  
  Future<void> _registerDevice() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      try {
        final dto = RegisterDeviceDTO(
          deviceId: _deviceIdController.text.trim(),
          deviceName: _deviceNameController.text.trim(),
          deviceType: _deviceType,
          location: _location,
        );
        
        await _apiService.registerDevice(dto);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Device registered successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() => _isSubmitting = false);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Device'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.purple.shade50,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Device Information',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Device ID
                        TextFormField(
                          controller: _deviceIdController,
                          decoration: InputDecoration(
                            labelText: 'Device ID',
                            hintText: 'esp32_demo_003',
                            prefixIcon: const Icon(Icons.fingerprint),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Device ID is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Device Name
                        TextFormField(
                          controller: _deviceNameController,
                          decoration: InputDecoration(
                            labelText: 'Device Name',
                            hintText: 'Living Room Light',
                            prefixIcon: const Icon(Icons.label),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Device name is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Device Type
                        DropdownButtonFormField<String>(
                          value: _deviceType,
                          decoration: InputDecoration(
                            labelText: 'Device Type',
                            prefixIcon: const Icon(Icons.category),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'light',
                              child: Row(
                                children: [
                                  Icon(Icons.lightbulb, size: 20),
                                  SizedBox(width: 8),
                                  Text('Light'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: 'fan',
                              child: Row(
                                children: [
                                  Icon(Icons.wind_power, size: 20),
                                  SizedBox(width: 8),
                                  Text('Fan'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _deviceType = value!);
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Location
                        DropdownButtonFormField<String>(
                          value: _location,
                          decoration: InputDecoration(
                            labelText: 'Location',
                            prefixIcon: const Icon(Icons.location_on),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'room1', child: Text('Room 1')),
                            DropdownMenuItem(value: 'room2', child: Text('Room 2')),
                            DropdownMenuItem(value: 'kitchen', child: Text('Kitchen')),
                            DropdownMenuItem(value: 'bedroom', child: Text('Bedroom')),
                            DropdownMenuItem(value: 'living_room', child: Text('Living Room')),
                            DropdownMenuItem(value: 'bathroom', child: Text('Bathroom')),
                          ],
                          onChanged: (value) {
                            setState(() => _location = value!);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Submit Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _registerDevice,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'REGISTER DEVICE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                
                const SizedBox(height: 16),
                
                // Info Card
                Card(
                  color: Colors.blue.shade50,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.blue.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'The device will be registered as offline. '
                            'It will become online when it connects to the MQTT broker.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

