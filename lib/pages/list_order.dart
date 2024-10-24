import 'package:delivery/pages/rider_map.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ListOrderPage extends StatefulWidget {
  const ListOrderPage({super.key, required this.userId});

  final String userId; // เปลี่ยนเป็น String

  @override
  State<ListOrderPage> createState() => _ListOrderPageState();
}

class _ListOrderPageState extends State<ListOrderPage> {
  List<dynamic> orders = []; // เก็บข้อมูลรายการสั่งซื้อ
    int _selectedIndex = 0; // ตัวแปรสำหรับติดตาม index ของ Bottom Navigation Bar

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // นำทางไปยังหน้าที่เลือก พร้อมส่ง userId
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RiderMapPage(userId: widget.userId), // ส่งค่า userId ไปยัง UserSendPage
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchOrders(); // เรียกใช้ฟังก์ชันเพื่อดึงข้อมูล
  }

  Future<void> fetchOrders() async {
    final response = await http.get(Uri.parse('http://192.168.122.196:3000/orders')); // เปลี่ยน URL ตาม API ของคุณ

    if (response.statusCode == 200) {
      setState(() {
        orders = json.decode(response.body); // แปลง JSON เป็น List
      });
    } else {
      throw Exception('Failed to load orders'); // แสดงข้อผิดพลาด
    }
  }

  Future<void> acceptOrder(int orderId) async {
    final response = await http.post(
      Uri.parse('http://192.168.122.196:3000/orders/accept/$orderId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      // แสดงข้อความว่ารับงานสำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('รับงานสำเร็จสำหรับออเดอร์ $orderId')),
      );
    } else {
      // แสดงข้อผิดพลาดหากรับงานไม่สำเร็จ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('รับงานไม่สำเร็จ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการส่งสินค้า'), // ชื่อหน้าจอ
        backgroundColor: const Color.fromARGB(255, 56, 238, 15),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0), // ระยะห่างรอบๆ ข้อความ
            child: Text(
              'ออเดอร์', // ข้อความที่แสดงใต้ AppBar
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black, // สีของข้อความ
              ),
            ),
          ),
          orders.isEmpty // เช็คว่ามีรายการหรือไม่
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Card( // ใช้ Card เพื่อให้ดูมีมิติ
                        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // ระยะห่างของ Card
                        child: ListTile(
                          title: Text(order['details']), // แสดงรายละเอียดสินค้า
                          subtitle: Text(
                            'ผู้ส่ง: ${order['user_send_name']} \nผู้รับ: ${order['user_receive_name']} \nสถานะ: ${order['status']}',
                          ), // แสดงชื่อผู้ส่ง ผู้รับ และสถานะสินค้า
                          trailing: ElevatedButton(
                            onPressed: () {
                              acceptOrder(order['pro_id']); // รับงานเมื่อกดปุ่ม
                            },
                            child: const Text('รับงาน'),
                          ), // ปุ่มรับงาน
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
            bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'หน้าแรก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'เช็คออเดอร์',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.delivery_dining),
          //   label: 'เช็คการส่ง',
          // ),
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
}
