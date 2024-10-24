import 'package:delivery/pages/checkrider.dart';
import 'package:delivery/pages/login.dart';
import 'package:delivery/pages/profile.dart';
import 'package:delivery/pages/userSend.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // นำเข้า http
import 'dart:convert'; // นำเข้า dart:convert

class ReceivePage extends StatefulWidget {
  final String userId;

  const ReceivePage({super.key, required this.userId});

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  final List<dynamic> _itemList = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchReceivedItems(); // เรียกฟังก์ชันเพื่อดึงข้อมูล
  }

  Future<void> _fetchReceivedItems() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.122.196:3000/showProReceive/${widget.userId}'));
      if (response.statusCode == 200) {
        setState(() {
          _itemList.addAll(json.decode(response.body));
        });
      } else {
        throw Exception('Failed to load received items');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CheckRiderPage(userId: widget.userId)),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage(userId: widget.userId)),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReceivePage(userId: widget.userId)),
      );
    } else if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserSendPage(userId: widget.userId)),
      );
    }
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
    body: Column( // ใช้ Column เพื่อรวมแถบด้านบนและรายการ
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0), // เพิ่ม padding
          child: const Text(
            'รายการรับสินค้า', // ข้อความที่ต้องการแสดง
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
        ),
        Expanded( // ใช้ Expanded เพื่อให้ ListView เต็มพื้นที่
          child: ListView.builder(
            itemCount: _itemList.length,
            itemBuilder: (context, index) {
              final item = _itemList[index];
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: const Icon(Icons.inventory),
                  title: Text(item['details'] ?? 'ไม่มีรายละเอียด'), // แสดงรายละเอียดสินค้า
                  subtitle: Text('ผู้ส่ง: ${item['user_send_name'] ?? 'ไม่ระบุ'}'), // แสดงชื่อผู้ส่ง
                  trailing: Text(item['status'] ?? 'ไม่ระบุ'), // แสดงสถานะ
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
}