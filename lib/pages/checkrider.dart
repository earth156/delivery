import 'package:delivery/pages/UserSend.dart';
import 'package:delivery/pages/profile.dart';
import 'package:flutter/material.dart';

class CheckRiderPage extends StatefulWidget {
  const CheckRiderPage({super.key});

  @override
  State<CheckRiderPage> createState() => _CheckRiderPageState();
}

class _CheckRiderPageState extends State<CheckRiderPage> {
    final List<String> _itemList = []; // รายการส่งสินค้าที่จะแสดง
  int _selectedIndex = 0; // ตัวแปรสำหรับติดตาม index ของ Bottom Navigation Bar
 final String userId = '12345'; // เพิ่ม userId สำหรับส่งค่าไปยัง UserSendPage
 
  // ฟังก์ชันสำหรับเปลี่ยนหน้าเมื่อมีการเลือกเมนู
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
        // นำทางไปยังหน้าที่เลือก
    if (index == 0) { // ถ้าเลือกไอคอนโปรไฟล์ (index = 3)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserSendPage(userId: userId)), // นำทางไปหน้า ProfilePage
      );
    }
    //   if (index == 1) { // ถ้าเลือกไอคอนโปรไฟล์ (index = 3)
    //   Navigator.push(
    //     context,
    //     MaterialPageRoute(builder: (context) => const ProfilePage()), // นำทางไปหน้า ProfilePage
    //   );
    // }
    // }
    if (index == 3) { // ถ้าเลือกไอคอนโปรไฟล์ (index = 3)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()), // นำทางไปหน้า ProfilePage
      );
    }
  }


  // รายการส่งของไรเดอร์
  final List<Map<String, String>> _deliveries = [
    {
      'riderName': 'นาย A',
      'deliveryStatus': 'กำลังส่ง',
      'address': '123 ซอย 1, เขต 1',
      'time': '12:30 น.',
    },
    {
      'riderName': 'นาง B',
      'deliveryStatus': 'ส่งสำเร็จ',
      'address': '456 ซอย 2, เขต 2',
      'time': '14:15 น.',
    },
    {
      'riderName': 'นาย C',
      'deliveryStatus': 'กำลังรอส่ง',
      'address': '789 ซอย 3, เขต 3',
      'time': '15:45 น.',
    },
    // คุณสามารถเพิ่มข้อมูลของไรเดอร์อื่นๆ ได้ที่นี่
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ตรวจสอบสถานะการส่งของไรเดอร์'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: _deliveries.length,
          itemBuilder: (context, index) {
            return _buildDeliveryCard(_deliveries[index]);
          },
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

  // ฟังก์ชันสร้าง Card สำหรับแสดงข้อมูลการส่ง
  Widget _buildDeliveryCard(Map<String, String> delivery) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ไรเดอร์: ${delivery['riderName']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            Text(
              'สถานะ: ${delivery['deliveryStatus']}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 4.0),
            Text(
              'ที่อยู่: ${delivery['address']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4.0),
            Text(
              'เวลา: ${delivery['time']}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
