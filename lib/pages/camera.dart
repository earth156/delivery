import 'dart:developer';  // ใช้สำหรับ log
import 'dart:io';         // นำเข้า dart:io เพื่อใช้ File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // นำเข้า ImagePicker

class CameraPage extends StatefulWidget {
  final String userId;

  const CameraPage({super.key, required this.userId});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker picker = ImagePicker(); // สร้างตัวแปร ImagePicker
  XFile? image;  // ตัวแปรสำหรับเก็บผลลัพธ์ของภาพที่เลือก

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เลือกภาพหรือถ่ายภาพ'), // ตั้งชื่อแถบ
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () async {
                // เลือกภาพจากแกลเลอรี่
                image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  log('Selected image from gallery: ${image!.path}');  // แสดง path ของภาพใน log
                }
                setState(() {});  // อัปเดต UI
              },
              child: const Text('เลือกจากแกลเลอรี่'), // แก้ไขการสะกดคำ
            ),
            const SizedBox(height: 20), // เพิ่มระยะห่างระหว่างปุ่ม
            FilledButton(
              onPressed: () async {
                // เลือกภาพจากกล้อง
                image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  log('Captured image from camera: ${image!.path}');  // แสดง path ของภาพใน log
                }
                setState(() {});  // อัปเดต UI
              },
              child: const Text('ถ่ายภาพจากกล้อง'),
            ),
            const SizedBox(height: 20), // เพิ่มระยะห่างระหว่างปุ่ม
            if (image != null) // ตรวจสอบว่ามีภาพที่เลือกหรือไม่
              Column(
                children: [
                  Image.file(
                    File(image!.path),  // แสดงภาพที่เลือก
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 20), // เพิ่มระยะห่างด้านล่างภาพ
                  Text('Path: ${image!.path}'), // แสดง path ของภาพ
                ],
              ),
          ],
        ),
      ),
    );
  }
}
