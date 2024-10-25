import 'package:delivery/pages/checkrider.dart';
import 'package:delivery/pages/login.dart';
import 'package:delivery/pages/profile.dart';
import 'package:delivery/pages/userSend.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      final response = await http.get(Uri.parse('https://appdeli.onrender.com/showProReceive/${widget.userId}'));
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

    // ใช้ if-else แทน switch
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserSendPage(userId: widget.userId)),
      ).then((_) => _fetchReceivedItems());
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReceivePage(userId: widget.userId)),
      ).then((_) => _fetchReceivedItems());
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CheckRiderPage(userId: widget.userId)),
      ).then((_) => _fetchReceivedItems());
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage(userId: widget.userId)),
      ).then((_) => _fetchReceivedItems());
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              'รายการรับสินค้า',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _itemList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Item: ${_itemList[index]['itemName']}'),
                  subtitle: Text('Status: ${_itemList[index]['status']}'),
                  // รายละเอียดเพิ่มเติมที่ต้องการแสดง
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
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
