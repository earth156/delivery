import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'gps.dart'; // เปลี่ยนชื่อไฟล์ให้ตรงตามที่คุณใช้
import 'package:image_picker/image_picker.dart'; // เพิ่ม import สำหรับ image_picker

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
  
  String? _profileImage; // ตัวแปรสำหรับเก็บ path ของรูปโปรไฟล์

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
        Uri.parse('https://appdeli.onrender.com/checkPhone?phone=$phone'),
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

    // สร้าง request
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://appdeli.onrender.com/register'),
    );

    // เพิ่มข้อมูลลงใน request
    request.fields['name'] = name;
    request.fields['phone'] = phone;
    request.fields['password'] = password;
    request.fields['address'] = address;
    request.fields['gps'] = coordinates;
    request.fields['car_reg'] = ''; // สามารถปรับเปลี่ยนตามความต้องการ
    request.fields['type'] = phone.isNotEmpty ? 'user' : 'rider';

    // ถ้ามีไฟล์โปรไฟล์ที่เลือกให้เพิ่มลงใน request
    if (_profileImage != null) {
      request.files.add(await http.MultipartFile.fromPath('profile', _profileImage!));
    }

    // ทำการส่ง request
    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        print(responseData); // แสดงผลการตอบกลับ
        _showSuccessDialog(); // แสดงกล่องข้อความสมัครสมาชิกสำเร็จ
        _clearFields(); // เคลียร์ฟิลด์หลังจากลงทะเบียนสำเร็จ
      } else {
        final responseData = await response.stream.bytesToString();
        throw Exception('ไม่สามารถลงทะเบียนผู้ใช้ได้: $responseData');
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
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = pickedFile.path; // เก็บ path ของภาพที่เลือก
      });
    }
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
              'กรอกข้อมูลสมาชิก',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: _onProfileImageTap,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _profileImage != null
                    ? ClipOval(
                        child: Image.file(
                          File(_profileImage!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.camera_alt, size: 50),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'ชื่อ'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'หมายเลขโทรศัพท์'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'รหัสผ่าน'),
              obscureText: false, // แสดงรหัสผ่าน
            ),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: 'ยืนยันรหัสผ่าน'),
              obscureText: false, // แสดงรหัสผ่าน
            ),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(labelText: 'ที่อยู่'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _coordinatesController,
                    decoration: const InputDecoration(labelText: 'พิกัด GPS'),
                    readOnly: true,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: _onMapIconPressed,
                ),
              ],
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
