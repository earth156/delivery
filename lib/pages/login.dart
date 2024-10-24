import 'dart:convert';
import 'package:delivery/pages/rider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:delivery/pages/regisCus.dart';
import 'package:delivery/pages/regisRider.dart';
import 'package:delivery/pages/userSend.dart';
import 'package:delivery/model/users_login.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String errorText = '';

  // ฟังก์ชันแสดง Bottom Sheet สำหรับการสมัครสมาชิก
  void _showSignUpOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 200,
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 77, 219, 20),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'เลือกประเภทการสมัครสมาชิก',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisCutPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 15.0),
                    ),
                    child: const Text(
                      'ผู้ใช้ระบบ',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RegisRiderPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30.0, vertical: 15.0),
                    ),
                    child: const Text(
                      'ไรเดอร์',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ฟังก์ชันสำหรับล็อกอิน
  Future<void> login() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        errorText = 'กรุณากรอกชื่อผู้ใช้และรหัสผ่าน';
      });
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.122.196:3000/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}'); // ปริ้นผลลัพธ์ของ response

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // ตรวจสอบค่า null และแปลงให้เป็น String
        final userId = responseData['user_id']?.toString() ?? '';
        final userType = responseData['type']?.toString() ?? '';

        if (responseData.containsKey('message') &&
            responseData.containsKey('user_id') &&
            responseData.containsKey('type')) {
          final userLogin = UserLogin.fromJson(responseData);

          // เช็คประเภทของผู้ใช้
          if (userLogin.type == 'user') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    UserSendPage(userId: userId), // ส่ง userId ที่ไม่เป็น null
              ),
            );
          } else if (userLogin.type == 'rider') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    RiderPage(userId: userId), // ส่ง userId ที่ไม่เป็น null
              ),
            );
          } else {
            setState(() {
              errorText = 'ประเภทผู้ใช้ไม่ถูกต้อง';
            });
            print('ประเภทผู้ใช้ไม่ถูกต้อง: ${userLogin.type}');
          }
        } else {
          setState(() {
            errorText = 'ข้อมูลการตอบกลับจากเซิร์ฟเวอร์ไม่ถูกต้อง';
          });
          print('ข้อมูลการตอบกลับไม่ถูกต้อง: $responseData');
        }
      } else {
        setState(() {
          errorText = 'เกิดข้อผิดพลาดในการเข้าสู่ระบบ';
        });
        print('เกิดข้อผิดพลาดในการเข้าสู่ระบบ: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorText = 'ไม่สามารถเข้าสู่ระบบได้ ลองอีกครั้ง';
      });
      print('เกิดข้อผิดพลาด: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100.0),
              const Text(
                'Delivery',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 30.0),
              const Text(
                'ล็อคอิน',
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30.0),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อบัญชี',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20.0),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'รหัสผ่าน',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20.0),
              GestureDetector(
                onTap: _showSignUpOptions,
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'สมัครสมาชิก',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 60.0, vertical: 15.0),
                ),
                child: const Text(
                  'เข้าสู่ระบบ',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10.0),
              if (errorText.isNotEmpty)
                Text(
                  errorText,
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
