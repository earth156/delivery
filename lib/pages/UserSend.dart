import 'package:delivery/pages/CreateSend.dart';
import 'package:delivery/pages/checkrider.dart';
import 'package:delivery/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserSendPage extends StatefulWidget {
  final String userId;

  const UserSendPage({super.key, required this.userId});

  @override
  State<UserSendPage> createState() => _UserSendPageState();
}

class _UserSendPageState extends State<UserSendPage> {
  final List<dynamic> _itemList = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchSentItems();
  }

  Future<void> _fetchSentItems() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.122.196:3000/showProsend/${widget.userId}'));

      if (response.statusCode == 200) {
        setState(() {
          _itemList.addAll(json.decode(response.body));
        });
      } else {
        throw Exception('Failed to load sent items');
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
        MaterialPageRoute(builder: (context) => const CheckRiderPage()),
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ProfilePage()),
      );
    }
  }

  void _goToCreateSendPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateSendPage(userId: widget.userId)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deliverey',style: TextStyle(color: Colors.purple),),
        backgroundColor: const Color.fromARGB(255, 56, 238, 15),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // เพิ่มหัวข้อด้านบนรายการ
            const Text(
              'รายการส่งสินค้า',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 16.0), // Space between title and list
            Expanded(
              child: ListView.builder(
                itemCount: _itemList.length,
                itemBuilder: (context, index) {
                  final item = _itemList[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(item['details'] ?? 'ไม่มีรายละเอียด', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ผู้รับ: ${item['user_receive_name'] ?? 'ไม่ระบุ'}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'ที่อยู่: ${item['user_receive_address'] ?? 'ไม่ระบุ'}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      leading: const Icon(Icons.local_shipping, color: Colors.purple),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0), // Space between list and button
            ElevatedButton(
              onPressed: _goToCreateSendPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 15.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text(
                'สร้างรายการส่ง',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
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
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.purple,
        onTap: _onItemTapped,
        backgroundColor: const Color.fromARGB(255, 56, 238, 15),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
