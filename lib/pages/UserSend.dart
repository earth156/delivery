import 'package:delivery/pages/CreateSend.dart';
import 'package:delivery/pages/checkrider.dart';
import 'package:delivery/pages/login.dart';
import 'package:delivery/pages/profile.dart';
import 'package:delivery/pages/receive.dart';
import 'package:delivery/pages/ShowProSend.dart';
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
      final response = await http.get(Uri.parse('https://appdeli.onrender.com/showProsend/${widget.userId}'));

      if (response.statusCode == 200) {
        setState(() {
          _itemList.clear();
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
        MaterialPageRoute(builder: (context) => CheckRiderPage(userId: widget.userId)),
      ).then((_) => _fetchSentItems());
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage(userId: widget.userId)),
      ).then((_) => _fetchSentItems());
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ReceivePage(userId: widget.userId)),
      ).then((_) => _fetchSentItems());
    }
  }

  void _goToCreateSendPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateSendPage(userId: widget.userId)),
    ).then((_) => _fetchSentItems());
  }

  void _goToShowProSendPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShowProSend(userId: widget.userId)),
    );
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor:  const Color.fromARGB(255, 56, 238, 15),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'รายการส่งสินค้า',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: ListView.builder(
                itemCount: _itemList.length,
                itemBuilder: (context, index) {
                  final item = _itemList[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      title: Text(
                        item['details'] ?? 'ไม่มีรายละเอียด',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            'ผู้รับ: ${item['user_receive_name'] ?? 'ไม่ระบุ'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            'ที่อยู่: ${item['user_receive_address'] ?? 'ไม่ระบุ'}',
                            style: const TextStyle(
                              color: Colors.black38,
                            ),
                          ),
                          Text(
                            'สถานะ: ${item['status'] ?? 'ไม่ระบุ'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ],
                      ),
                      leading: const Icon(Icons.local_shipping, color: Color.fromARGB(255, 56, 238, 15),),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton.extended(
                  onPressed: _goToCreateSendPage,
                  label: const Text('สร้างรายการ'),
                  icon: const Icon(Icons.edit),
                  backgroundColor: Colors.purple,
                ),
                ElevatedButton(
                  onPressed: _goToShowProSendPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'แสดงพิกัดผู้รับ',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
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
        selectedItemColor:  const Color.fromARGB(255, 56, 238, 15),
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
