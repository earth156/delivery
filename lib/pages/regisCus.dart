import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps; // ใช้ as prefix
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisCutPage extends StatefulWidget {
  const RegisCutPage({super.key});

  @override
  State<RegisCutPage> createState() => _RegisCutPageState();
}

class _RegisCutPageState extends State<RegisCutPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _coordinatesController = TextEditingController();

  latlong.LatLng? _selectedLocation;

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await _determinePosition();
      setState(() {
        _selectedLocation = latlong.LatLng(position.latitude, position.longitude);
        _coordinatesController.text = '${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _openMap() async {
    latlong.LatLng? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MapScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
        _coordinatesController.text = '${result.latitude}, ${result.longitude}';
      });
    }
  }

  Future<void> _register() async {
    String name = _nameController.text;
    String phone = _phoneController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String address = _addressController.text;
    String coordinates = _coordinatesController.text;

    // ตรวจสอบข้อมูลกรอกให้ครบ
    if (name.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty || address.isEmpty || coordinates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบทุกช่อง')),
      );
      return;
    }

    // ตรวจสอบรหัสผ่านให้ตรงกัน
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('รหัสผ่านและยืนยันรหัสผ่านไม่ตรงกัน')),
      );
      return;
    }

    // ตรวจสอบเบอร์โทรศัพท์ว่ามีอยู่ในระบบหรือไม่
    try {
      final checkResponse = await http.get(
        Uri.parse('http://192.168.122.196:3000/checkPhone?phone=$phone'),
      );

      if (checkResponse.statusCode == 409) {
        // เบอร์โทรศัพท์มีอยู่แล้ว
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('หมายเลขโทรศัพท์นี้ถูกลงทะเบียนแล้ว')),
        );
        return;
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการตรวจสอบเบอร์โทรศัพท์: $e')),
      );
      return;
    }

    // สร้างข้อมูลสำหรับการลงทะเบียน
    Map<String, dynamic> data = {
      'name': name,
      'phone': phone,
      'password': password,
      'address': address,
      'gps': coordinates,
      'car_reg': null,
      'profile': null,
      'type': phone.isNotEmpty ? 'user' : 'rider',
    };

    // ทำ POST request เพื่อลงทะเบียนผู้ใช้
    try {
      final response = await http.post(
        Uri.parse('http://192.168.122.196:3000/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog(); // แสดงกล่องข้อความสมัครสมาชิกสำเร็จ
        _clearFields(); // เคลียร์ฟิลด์หลังจากลงทะเบียนสำเร็จ
      } else {
        throw Exception('ไม่สามารถลงทะเบียนผู้ใช้ได้');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
      );
    }
  }

  // ฟังก์ชันสำหรับแสดง AlertDialog เมื่อสมัครสมาชิกสำเร็จ
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('สมัครสมาชิกสำเร็จ'),
          content: const Text('คุณได้สมัครสมาชิกเรียบร้อยแล้ว'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิดกล่องข้อความ
              },
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }

  // ฟังก์ชันสำหรับเคลียร์ฟิลด์หลังจากลงทะเบียนสำเร็จ
  void _clearFields() {
    _nameController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _addressController.clear();
    _coordinatesController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สมัครสมาชิกลูกค้า'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20.0),
            const Text(
              'กรอกข้อมูลสมัครสมาชิก',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'หมายเลขโทรศัพท์',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'รหัสผ่าน',
                border: OutlineInputBorder(),
              ),
              obscureText: true, // ซ่อนรหัสผ่าน
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'ยืนยันรหัสผ่าน',
                border: OutlineInputBorder(),
              ),
              obscureText: true, // ซ่อนรหัสผ่าน
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'ที่อยู่',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _coordinatesController,
                    decoration: const InputDecoration(
                      labelText: 'พิกัด (latitude, longitude)',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true, // ทำให้ไม่สามารถแก้ไขพิกัดได้โดยตรง
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: _openMap, // เปิดหน้าจอแผนที่
                ),
                IconButton(
                  icon: const Icon(Icons.my_location),
                  onPressed: _getCurrentLocation, // แสดงพิกัดปัจจุบัน
                ),
              ],
            ),
            const SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: _register, // เรียกฟังก์ชัน _register
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 15.0),
              ),
              child: const Text(
                'สมัครสมาชิก',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('เลือกตำแหน่ง')),
      body: const Center(child: Text('แสดงแผนที่ที่นี่')),
    );
  }
}
