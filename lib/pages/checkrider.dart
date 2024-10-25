import 'package:delivery/pages/UserSend.dart';
import 'package:delivery/pages/profile.dart';
import 'package:delivery/pages/receive.dart';
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
  int _selectedIndex = 2;

  Future<void> _fetchDeliveries(String riderId) async {
    try {
      final response = await http.get(Uri.parse('https://appdeli.onrender.com/api/deliveries/$riderId'));
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
    _fetchDeliveries(widget.userId);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // ใช้ if-else แทน switch
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserSendPage(userId: widget.userId)),
      ).then((_) => _fetchDeliveries(widget.userId));
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReceivePage(userId: widget.userId)),
      ).then((_) => _fetchDeliveries(widget.userId));
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CheckRiderPage(userId: widget.userId)),
      ).then((_) => _fetchDeliveries(widget.userId));
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage(userId: widget.userId)),
      ).then((_) => _fetchDeliveries(widget.userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'สถานะการส่งสินค้า',
          style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 56, 238, 15),
      ),
      body: _deliveries.isNotEmpty
          ? ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: _deliveries.length,
              itemBuilder: (context, index) {
                final delivery = _deliveries[index];
                return _buildDeliveryCard(delivery);
              },
            )
          : Center(
              child: Text(
                'ไม่มีข้อมูลการส่งสินค้า',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
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
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
      ),
    );
  }

  Widget _buildDeliveryCard(Map<String, dynamic> delivery) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'รายละเอียด: ${delivery['details'] ?? 'ไม่ระบุ'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 4.0),
            Text(
              'สถานะ: ${delivery['status'] ?? 'ไม่ระบุ'}',
              style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
            ),
            const SizedBox(height: 8.0),
            Text(
              'ที่อยู่ผู้ส่ง: ${delivery['user_send_name'] ?? 'ไม่ระบุ'} (${delivery['user_send_phone'] ?? 'ไม่ระบุ'})',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4.0),
            Text(
              'ที่อยู่ผู้รับ: ${delivery['user_receive_name'] ?? 'ไม่ระบุ'} (${delivery['user_receive_phone'] ?? 'ไม่ระบุ'})',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4.0),
            Text(
              'ไรเดอร์: ${delivery['rider_name'] ?? 'ไม่ระบุ'} (${delivery['rider_phone'] ?? 'ไม่ระบุ'})',
              style: const TextStyle(fontSize: 16, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}
