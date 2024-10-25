import 'package:delivery/pages/login.dart';
import 'package:delivery/pages/userSend.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ShowUser {
  int userId;
  String name;
  String phone;
  String password;
  dynamic carReg; // carReg อาจจะเป็น null ก็ได้
  String profile;
  String address;
  String gps;
  String type;

  ShowUser({
    required this.userId,
    required this.name,
    required this.phone,
    required this.password,
    required this.carReg,
    required this.profile,
    required this.address,
    required this.gps,
    required this.type,
  });

  factory ShowUser.fromJson(Map<String, dynamic> json) => ShowUser(
    userId: json["user_id"] ?? 0,
    name: json["name"] ?? '',
    phone: json["phone"] ?? '',
    password: json["password"] ?? '',
    carReg: json["car_reg"],
    profile: json["profile"] ?? '',
    address: json["address"] ?? '',
    gps: json["gps"] ?? '',
    type: json["type"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "name": name,
    "phone": phone,
    "password": password,
    "car_reg": carReg,
    "profile": profile,
    "address": address,
    "gps": gps,
    "type": type,
  };
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.userId});

  final String userId;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ShowUser? _userProfile; // เปลี่ยนเป็น ShowUser แทน String หลายตัว
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final response = await http.get(Uri.parse('https://appdeli.onrender.com/userProfile/${widget.userId}'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        setState(() {
          _userProfile = ShowUser.fromJson(jsonResponse);
        });
      } else {
        throw Exception('ไม่สามารถโหลดข้อมูลโปรไฟล์ได้ รหัสสถานะ: ${response.statusCode}');
      }
    } catch (error) {
      print('เกิดข้อผิดพลาดในการดึงข้อมูลโปรไฟล์: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการดึงข้อมูลโปรไฟล์: $error')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserSendPage(userId: widget.userId),
      ),
    );
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Delivery',
          style: TextStyle(color: Colors.purple),
        ),
        backgroundColor: const Color.fromARGB(255, 56, 238, 15),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // แสดงภาพโปรไฟล์
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(_userProfile?.profile ?? 'https://path_to_your_default_image.png'),
            ),
            const SizedBox(height: 20.0),
            // แสดงข้อมูลใน Card
            Expanded(
              child: ListView(
                children: [
                  _buildInfoCard('ชื่อ', _userProfile?.name ?? 'ไม่มีชื่อ'),
                  _buildInfoCard('โทรศัพท์', _userProfile?.phone ?? 'ไม่มีหมายเลขโทรศัพท์'),
                  _buildInfoCard('รหัสผ่าน', _userProfile?.password ?? 'ไม่มีรหัสผ่าน'),
                  _buildInfoCard('ที่อยู่', _userProfile?.address ?? 'ไม่มีที่อยู่'),
                  _buildInfoCard('พิกัด', _userProfile?.gps ?? 'ไม่มีพิกัด'),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ฟังก์ชันแก้ไขยังไม่พร้อมใช้งาน')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 15.0),
              ),
              child: const Text(
                'แก้ไขโปรไฟล์',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าแรก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.call_received_outlined),
            label: 'รับสินค้า',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'เช็คการส่ง',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'โปรไฟล์',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        onTap: _onItemTapped,
        backgroundColor: const Color.fromARGB(255, 56, 238, 15),
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
