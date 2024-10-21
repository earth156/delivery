import 'package:delivery/pages/UserSend.dart';
import 'package:flutter/material.dart';
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // ตัวแปรสำหรับเก็บข้อมูลโปรไฟล์
  final String _profileImage = 'https://example.com/profile_image.png'; // ลิงค์ภาพโปรไฟล์
  final String _name = 'นาย A';
  final String _email = 'email@example.com';
  final String _password = '********'; // ไม่แสดงรหัสผ่านในโปรไฟล์
  final String _address = '123 ซอย 1';
  final String _location = '13.7563° N, 100.5018° E'; // พิกัดตัวอย่าง
  final String userId = '12345'; // เพิ่ม userId สำหรับส่งค่าไปยัง UserSendPage

  int _selectedIndex = 0; // ตัวแปรสำหรับติดตาม index ของ Bottom Navigation Bar

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // นำทางไปยังหน้าที่เลือก พร้อมส่ง userId
    if (index == 0 || index == 1 || index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserSendPage(userId: userId)), // ส่งค่า userId ไปยัง UserSendPage
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('โปรไฟล์ของฉัน'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // แสดงภาพโปรไฟล์
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(_profileImage), // แสดงภาพจาก URL
            ),
            const SizedBox(height: 20.0),
            // แสดงข้อมูลใน Card
            Expanded(
              child: ListView(
                children: [
                  _buildInfoCard('ชื่อ', _name),
                  _buildInfoCard('อีเมล', _email),
                  _buildInfoCard('รหัสผ่าน', _password),
                  _buildInfoCard('ที่อยู่', _address),
                  _buildInfoCard('พิกัด', _location),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            // ปุ่มแก้ไขโปรไฟล์
            ElevatedButton(
              onPressed: () {
                // ที่นี่สามารถเพิ่มโค้ดสำหรับแก้ไขข้อมูลโปรไฟล์
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ฟังก์ชันแก้ไขยังไม่พร้อมใช้งาน')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber, // ใช้ backgroundColor แทน primary
                padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 15.0),
              ),
              child: const Text(
                'แก้ไขโปรไฟล์',
                style: TextStyle(color: Colors.black), // เปลี่ยนสีข้อความเป็นสีดำเพื่อให้ตัดกับสีพื้นหลัง
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
            icon: Icon(Icons.history),
            label: 'ประวัติ',
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
        currentIndex: _selectedIndex, // เปลี่ยนตามสถานะที่เลือก
        selectedItemColor: Colors.purple,
        onTap: _onItemTapped, // ฟังก์ชันที่ใช้จัดการการเลือก
        backgroundColor: const Color.fromARGB(255, 56, 238, 15),
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  // ฟังก์ชันสร้าง Card สำหรับข้อมูล
  Widget _buildInfoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0), // ระยะห่างระหว่าง Card
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding ภายใน Card
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
