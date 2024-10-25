import 'package:delivery/pages/rider_map.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReceiveOrderPage extends StatefulWidget {
  final Map<String, dynamic> order;
  final String userId; // รับ userId ของไรเดอร์

  const ReceiveOrderPage({super.key, required this.order, required this.userId});

  @override
  _ReceiveOrderPageState createState() => _ReceiveOrderPageState();
}

class _ReceiveOrderPageState extends State<ReceiveOrderPage> {
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;

  // ฟังก์ชันสำหรับเลือกภาพ
  Future<void> _pickImage(BuildContext context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    } else {
      print('No image selected.');
    }
  }

  // ฟังก์ชันที่ใช้สำหรับยืนยันการรับสินค้า
  Future<void> _confirmReceipt() async {
    final response = await http.put(
      Uri.parse('https://appdeli.onrender.com/rider/product/${widget.order['pro_id']}'), // เปลี่ยนเป็น pro_id ของออเดอร์
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'details': widget.order['details'],
        'img': _imagePath, // ส่งพาธของภาพที่เลือก
        'status': 'received',
        'user_send': widget.order['user_send_id'],
        'user_receive': widget.order['user_receive_id'],
        'rider': widget.userId // ID ของไรเดอร์ที่รับงาน
      }),
    );

    if (response.statusCode == 200) {
      print('Order updated successfully: ${response.body}');
      // นำทางไปยังหน้า RiderMapPage พร้อมกับส่งพิกัด
      final userSendGps = widget.order['user_send_gps'];
      final userReceiveGps = widget.order['user_receive_gps'];

      // นำทางไปยังหน้า RiderMapPage
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RiderMapPage(
            // userSendGps: userSendGps,
            // userReceiveGps: userReceiveGps,
            userId: widget.userId, // ส่ง userId ของไรเดอร์ไปด้วย
          ),
        ),
      );
    } else {
      print('Failed to update order: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายละเอียดออเดอร์ที่รับ'),
        backgroundColor: const Color(0xFF56EE0F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'รายละเอียดออเดอร์',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                      ),
                      const SizedBox(height: 10),
                      Divider(color: Colors.grey[600]),
                      const SizedBox(height: 10),
                      _buildDetailRow('รายละเอียดออเดอร์:', widget.order['details']),
                      const SizedBox(height: 10),
                      _buildDetailRow('ผู้ส่ง:', widget.order['user_send_name']),
                      _buildDetailRow('ที่อยู่ผู้ส่ง:', widget.order['user_send_address'] ?? "ไม่มีข้อมูล"),
                      _buildDetailRow('พิกัดผู้ส่ง:', widget.order['user_send_gps'] ?? "ไม่มีข้อมูล"),
                      const SizedBox(height: 10),
                      _buildDetailRow('ผู้รับ:', widget.order['user_receive_name']),
                      _buildDetailRow('ที่อยู่ผู้รับ:', widget.order['user_receive_address'] ?? "ไม่มีข้อมูล"),
                      _buildDetailRow('พิกัดผู้รับ:', widget.order['user_receive_gps'] ?? "ไม่มีข้อมูล"),
                      const SizedBox(height: 10),
                      _buildDetailRow('สถานะ:', widget.order['status']),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // เพิ่มช่องเพิ่มภาพs
            Container(
              width: 200,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, size: 40),
                  onPressed: () => _pickImage(context),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // แสดงภาพที่เลือก
            if (_imagePath != null)
              Column(
                children: [
                  Text('ภาพที่เลือก:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Image.file(File(_imagePath!), height: 200, fit: BoxFit.cover),
                ],
              ),
            const SizedBox(height: 20),
            // ปุ่มยืนยันการรับสินค้า
            ElevatedButton(
              onPressed: _confirmReceipt,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF56EE0F),
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('ยืนยันการรับสินค้า'),
            ),
          ],
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างแถวแสดงข้อมูล
  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}
