import 'dart:developer';
import 'dart:io';
import 'package:delivery/model/ShowUser.dart';
import 'package:delivery/pages/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image_picker/image_picker.dart';

class CreateSendPage extends StatefulWidget {
  final String userId;

  const CreateSendPage({super.key, required this.userId});

  @override
  State<CreateSendPage> createState() => _CreateSendPageState();
}

class _CreateSendPageState extends State<CreateSendPage> {
  final TextEditingController _recipientIdController = TextEditingController(); 
  final TextEditingController _recipientNameController = TextEditingController();
  final TextEditingController _recipientAddressController = TextEditingController();
  final TextEditingController _recipientPhoneController = TextEditingController();
  final TextEditingController _productDetailsController = TextEditingController();

  List<ShowUser> _contactList = [];
  List<ShowUser> _filteredContacts = [];
  final ImagePicker _picker = ImagePicker();
  XFile? _image; // ตัวแปรสำหรับเก็บภาพที่เลือก

  @override
  void initState() {
    super.initState();
    fetchContacts(); 
  }

  Future<void> fetchContacts() async {
    try {
      final response = await http.get(Uri.parse('https://appdeli.onrender.com/showUser'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        
        if (jsonResponse.containsKey('users')) {
          List<dynamic> data = jsonResponse['users'];
          setState(() {
            _contactList = data
                .map<ShowUser>((json) => ShowUser.fromJson(json))
                .where((user) => user.userId.toString() != widget.userId)
                .toList();
            _filteredContacts = _contactList; // ตั้งค่าเริ่มต้น
          });
        } else {
          throw Exception('ไม่พบคีย์ "users" ในการตอบกลับ');
        }
      } else {
        print('เกิดข้อผิดพลาดในการดึงข้อมูลผู้ติดต่อ: ${response.body}');
        throw Exception('ไม่สามารถโหลดข้อมูลผู้ติดต่อได้ รหัสสถานะ: ${response.statusCode}');
      }
    } catch (error) {
      print('เกิดข้อผิดพลาดในการดึงข้อมูลผู้ติดต่อ: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการดึงข้อมูลผู้ติดต่อ: $error')),
      );
    }
  }

  void _filterContacts(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredContacts = _contactList;
      });
    } else {
      setState(() {
        _filteredContacts = _contactList.where((contact) {
          return contact.name.contains(query) || contact.phone.contains(query);
        }).toList();
      });
    }
  }

  Future<void> _pickImage() async {
    // เลือกภาพจากแกลเลอรี่
    _image = await _picker.pickImage(source: ImageSource.gallery);
    if (_image != null) {
      log('Selected image: ${_image!.path}');
      setState(() {}); // อัปเดต UI
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('สร้างรายการส่งสินค้า'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            const Text(
              'กรอกข้อมูลผู้รับและรายละเอียดสินค้า',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 20.0),
            Text(
              'User ID ของคุณ: ${widget.userId}', 
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _recipientPhoneController,
              decoration: const InputDecoration(
                labelText: 'ค้นหาผู้รับ (ชื่อ/เบอร์โทร)',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _filterContacts(value),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 20.0),
            ListView.builder(
              itemCount: _filteredContacts.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final contact = _filteredContacts[index];
                return ListTile(
                  title: Text('${contact.name} - ${contact.phone}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contact.address),
                      Text('User ID: ${contact.userId}'), 
                    ],
                  ),
                  onTap: () {
                    _recipientIdController.text = contact.userId.toString(); 
                    _recipientNameController.text = contact.name;
                    _recipientAddressController.text = contact.address;
                    _recipientPhoneController.text = contact.phone;
                  },
                );
              },
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _recipientNameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อผู้รับ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _recipientAddressController,
              decoration: const InputDecoration(
                labelText: 'ที่อยู่ผู้รับ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _productDetailsController,
              decoration: const InputDecoration(
                labelText: 'รายละเอียดสินค้า',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _pickImage, // เรียกใช้ฟังก์ชันเลือกภาพ
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 15.0),
              ),
              child: const Text(
                'เลือกภาพสินค้า',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20.0),
            // แสดงภาพที่เลือก
            if (_image != null) 
              Column(
                children: [
                  Image.file(
                    File(_image!.path),
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 10),
                  Text('Path: ${_image!.path}'),
                ],
              ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () async {
                String recipientId = _recipientIdController.text; 
                String recipientName = _recipientNameController.text;
                String recipientAddress = _recipientAddressController.text;
                String recipientPhone = _recipientPhoneController.text;
                String productDetails = _productDetailsController.text;

                try {
                  final response = await http.post(
                    Uri.parse('https://appdeli.onrender.com/insertProduct/${widget.userId}/$recipientId'),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({
                      'details': productDetails,
                      // คุณสามารถส่ง path ของภาพที่เลือกได้ถ้าต้องการ
                      'imagePath': _image?.path, // ส่ง path ของภาพที่เลือก
                    }),
                  );

                  if (response.statusCode == 201) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('สร้างรายการส่งสินค้าสำเร็จ: $recipientName')),
                    );

                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('เกิดข้อผิดพลาดในการสร้างรายการ: ${response.body}')),
                    );
                  }
                } catch (error) {
                  print('Error sending product: $error');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('เกิดข้อผิดพลาดในการส่งข้อมูล: $error')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 15.0),
              ),
              child: const Text(
                'ยืนยันการสร้าง',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
