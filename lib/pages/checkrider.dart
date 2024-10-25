import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CheckRiderPage extends StatefulWidget {
  final String userId;
  const CheckRiderPage({super.key, required this.userId});

  @override
  State<CheckRiderPage> createState() => _CheckRiderPageState();
}

class _CheckRiderPageState extends State<CheckRiderPage> {
  List<dynamic> _deliveries = [];

  Future<void> _fetchDeliveries(String riderId) async {
    try {
      final response = await http.get(Uri.parse('https://appdeli.onrender.com/api/deliveries/$riderId')); // เปลี่ยน URL ตามเซิร์ฟเวอร์ที่คุณใช้
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _deliveries = data['data'];
        });
      } else {
        throw Exception('Failed to load deliveries');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchDeliveries(widget.userId); // แทนที่ด้วย riderId ที่ถูกต้อง
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Status'),
      ),
      body: ListView.builder(
        itemCount: _deliveries.length,
        itemBuilder: (context, index) {
          final delivery = _deliveries[index];
          return _buildDeliveryCard(delivery);
        },
      ),
    );
  }

  Widget _buildDeliveryCard(Map<String, dynamic> delivery) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'รายละเอียด: ${delivery['details']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            Text(
              'สถานะ: ${delivery['status']}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 4.0),
            Text(
              'ที่อยู่ผู้ส่ง: ${delivery['user_send_name']} (${delivery['user_send_phone']})',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4.0),
            Text(
              'ที่อยู่ผู้รับ: ${delivery['user_receive_name']} (${delivery['user_receive_phone']})',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4.0),
            Text(
              'ไรเดอร์: ${delivery['rider_name']} (${delivery['rider_phone']})',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
