import 'package:delivery/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RegisRiderPage extends StatefulWidget {
  @override
  State<RegisRiderPage> createState() => _RegisRiderPageState();
}

class _RegisRiderPageState extends State<RegisRiderPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _licensePlateController = TextEditingController();
  
  File? _profileImage; // ตัวแปรเพื่อเก็บภาพโปรไฟล์

  final ImagePicker _picker = ImagePicker(); // สร้าง ImagePicker

  // ฟังก์ชันเพื่อแสดง AlertDialog
  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ปิดกล่องข้อความ
              },
              child: const Text('ปิด'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _registerRider() async {
    String name = _nameController.text;
    String phone = _phoneController.text;
    String password = _passwordController.text;
    String confirmPassword = _confirmPasswordController.text;
    String licensePlate = _licensePlateController.text;

    // ตรวจสอบข้อมูลที่กรอก
    if (name.isEmpty || phone.isEmpty || password.isEmpty || confirmPassword.isEmpty || licensePlate.isEmpty) {
      _showDialog('ข้อมูลไม่ถูกต้อง', 'กรุณากรอกข้อมูลให้ครบทุกช่อง');
      return;
    }

    if (password != confirmPassword) {
      _showDialog('ข้อมูลไม่ถูกต้อง', 'รหัสผ่านไม่ตรงกัน');
      return;
    }

    // ตรวจสอบเบอร์โทรศัพท์ว่ามีอยู่ในระบบหรือไม่
    try {
      final checkResponse = await http.get(
        Uri.parse('https://appdeli.onrender.com/checkPhone?phone=$phone'),
      );

      if (checkResponse.statusCode == 409) {
        _showDialog('หมายเลขโทรศัพท์มีอยู่แล้ว', 'หมายเลขโทรศัพท์นี้ถูกลงทะเบียนแล้ว');
        return;
      }

    } catch (e) {
      _showDialog('เกิดข้อผิดพลาด', 'Error: $e');
      return;
    }

    // สร้างข้อมูลที่จะส่งไปยัง API
    Map<String, dynamic> data = {
      'name': name,
      'phone': phone,
      'password': password,
      'car_reg': licensePlate,
      // เพิ่มที่นี่เพื่อส่ง URL ของภาพโปรไฟล์ไปยังเซิร์ฟเวอร์
      'profile': _profileImage != null ? base64Encode(_profileImage!.readAsBytesSync()) : null,
    };

    // ทำ POST request
    try {
      final response = await http.post(
        Uri.parse('https://appdeli.onrender.com/registerrider'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        _showDialog('สำเร็จ', 'สมัครสมาชิกสำเร็จ');
        _nameController.clear();
        _phoneController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _licensePlateController.clear();
        setState(() {
          _profileImage = null; // รีเซ็ตภาพโปรไฟล์
        });
      } else {
        throw Exception('ไม่สามารถลงทะเบียนไรเดอร์ได้');
      }
    } catch (e) {
      _showDialog('เกิดข้อผิดพลาด', 'Error: $e');
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สมัครสมาชิกไรเดอร์'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20.0),
            const Text(
              'กรอกข้อมูลสมัครสมาชิกไรเดอร์',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 20.0),
            // ช่องกรอกภาพโปรไฟล์
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: _profileImage != null
                    ? ClipOval(
                        child: Image.file(
                          _profileImage!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20.0),
            // ช่องกรอกชื่อ
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            // ช่องกรอกหมายเลขโทรศัพท์
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'หมายเลขโทรศัพท์',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20.0),
            // ช่องกรอกรหัสผ่าน
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'รหัสผ่าน',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            // ช่องกรอกรหัสผ่านยืนยัน
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'ยืนยันรหัสผ่าน',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            // ช่องกรอกทะเบียน
            TextField(
              controller: _licensePlateController,
              decoration: const InputDecoration(
                labelText: 'ทะเบียนรถ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30.0),
            // ปุ่มสมัครสมาชิก
            ElevatedButton(
              onPressed: _registerRider,
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
}
