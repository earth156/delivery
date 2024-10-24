import 'package:flutter/material.dart';
import 'package:delivery/pages/rider_map.dart'; // นำเข้าหน้า RiderMapPage

class RiderPage extends StatefulWidget {
  final String userId; // เพิ่ม userId

  const RiderPage({super.key, required this.userId}); // รับ userId ใน constructor

  @override
  State<RiderPage> createState() => _RiderPageState();
}

class _RiderPageState extends State<RiderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Page'), // เพิ่ม title ให้ AppBar
        backgroundColor: const Color.fromARGB(255, 56, 238, 15),
      ),
      body: Center( // ใช้ Center เพื่อให้ปุ่มอยู่กลางจอ
        child: Column( // ใช้ Column เพื่อจัดเรียง UI
          mainAxisAlignment: MainAxisAlignment.center, // จัดตำแหน่งแนวตั้งไปยังกลาง
          children: [
            // หากต้องการแสดง Rider ID สามารถเปิดส่วนนี้ได้
            // Text('Rider ID: ${widget.userId}'), // แสดง userId
            const SizedBox(height: 20), // เว้นระยะ
            // เพิ่มปุ่ม "เริ่มงาน" ที่กลางจอ
            ElevatedButton(
              onPressed: () {
                // เมื่อกดปุ่ม จะนำไปยังหน้า RiderMapPage
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  RiderMapPage(userId: widget.userId)), // สร้างหน้า RiderMapPage
                );
              },
              child: const Text('เริ่มงาน'), // ข้อความในปุ่ม
            ),
          ],
        ),
      ),
    );
  }
}
