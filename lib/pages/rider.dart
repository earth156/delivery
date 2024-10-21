import 'package:flutter/material.dart';

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
      ),
      body: SingleChildScrollView(
        child: Center( // ใช้ Center เพื่อให้ข้อความอยู่กลาง
          child: Text('Rider ID: ${widget.userId}'), // แสดง userId
        ),
      ),
    );
  }
}
