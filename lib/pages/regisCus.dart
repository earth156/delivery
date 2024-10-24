import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'gps.dart'; // เปลี่ยนชื่อไฟล์ให้ตรงตามที่คุณใช้

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
  
  String? _profileImage; // ตัวแปรสำหรับเก็บ URL ของรูปโปรไฟล์

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
      'profile': _profileImage, // ส่ง URL รูปโปรไฟล์ไปด้วย
      'car_reg': null,
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
    setState(() {
      _profileImage = null; // เคลียร์ URL รูปโปรไฟล์
    });
  }

  // ฟังก์ชันสำหรับคลิกไอคอนแผนที่
  void _onMapIconPressed() async {
    final LatLng? selectedLocation = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const GPSandMapPage(),
      ),
    );

    // ถ้าได้พิกัดกลับมา ให้แสดงในช่องพิกัด
    if (selectedLocation != null) {
      _coordinatesController.text =
          '${selectedLocation.latitude}, ${selectedLocation.longitude}';
    }
  }

  // ฟังก์ชันสำหรับเลือกโปรไฟล์ภาพ
  void _onProfileImageTap() async {
    // ใช้ ImagePicker เพื่อเลือกภาพจาก gallery
    // ในกรณีนี้ คุณสามารถทำการเลือกภาพและเก็บ URL ไว้ใน _profileImage
    // ตัวอย่าง:
    // final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    // setState(() {
    //   _profileImage = pickedFile?.path;
    // });
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
            const SizedBox(height: 10.0),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'เบอร์โทรศัพท์',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'รหัสผ่าน',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'ยืนยันรหัสผ่าน',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'ที่อยู่',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _coordinatesController,
                    decoration: const InputDecoration(
                      labelText: 'พิกัด (latitude, longitude)',
                      border: OutlineInputBorder(),
                    ),
                    readOnly: true,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: _onMapIconPressed, // เรียกฟังก์ชันแสดงแผนที่
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            // ช่องสำหรับรูปโปรไฟล์
            GestureDetector(
              onTap: _onProfileImageTap, // เรียกฟังก์ชันเมื่อคลิก
              child: ClipOval(
                child: Container(
                  width: 100.0,
                  height: 100.0,
                  color: Colors.grey[300], // สีพื้นหลังสำหรับรูปโปรไฟล์
                  child: _profileImage != null
                      ? Image.file(
                          File(_profileImage!), // แสดงรูปโปรไฟล์จากไฟล์
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ), // แสดงไอคอนผู้ใช้
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _register,
              child: const Text('สมัครสมาชิก'),
            ),
          ],
        ),
      ),
    );
  }
}
