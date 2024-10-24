import 'package:delivery/pages/list_order.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:developer';
import 'package:latlong2/latlong.dart'; // สำหรับ LatLng

class RiderMapPage extends StatefulWidget {
  final String userId; // เพิ่ม userId
  const RiderMapPage({super.key, required this.userId}); // รับ userId ใน constructor

  @override
  _RiderMapPageState createState() => _RiderMapPageState();
}

class _RiderMapPageState extends State<RiderMapPage> {
  LatLng latLng = const LatLng(16.246825669508297, 103.25199289277295); // ตำแหน่งเริ่มต้น
  MapController mapController = MapController(); // ควบคุมแผนที่
  late Stream<Position> positionStream; // ประกาศตัวแปร Stream สำหรับตำแหน่ง
  int _selectedIndex = 0; // ตัวแปรสำหรับติดตาม index ของ Bottom Navigation Bar

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // นำทางไปยังหน้าที่เลือก พร้อมส่ง userId
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListOrderPage(userId: widget.userId), // ส่งค่า userId ไปยัง UserSendPage
      ),
    );
  }
  
  @override
  void initState() {
    super.initState();
    // เริ่มต้น Stream เพื่อติดตามตำแหน่งของไรเดอร์
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // อัปเดตทุกๆ 10 เมตร
      ),
    );

    // ฟังการเปลี่ยนแปลงตำแหน่ง
    positionStream.listen((Position position) {
      log('${position.latitude} ${position.longitude}'); // แสดงตำแหน่งใน log
      setState(() {
        latLng = LatLng(position.latitude, position.longitude); // อัปเดตตำแหน่ง
        mapController.move(latLng, mapController.camera.zoom); // เลื่อนแผนที่ไปที่ตำแหน่งใหม่
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS and Map'), // ชื่อหน้าจอ
      ),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: latLng, // ใช้ตำแหน่งกลางของแผนที่
                initialZoom: 15.0, // ขนาดการซูมเริ่มต้น
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                  maxNativeZoom: 19,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: latLng, // ตำแหน่งของ Marker
                      width: 40, // ความกว้างของ Marker
                      height: 40, // ความสูงของ Marker
                      child: const Icon( // ไอคอนที่จะใช้เป็น Marker
                        Icons.motorcycle,
                        color: Color.fromARGB(255, 0, 0, 0),
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
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

  @override
  void dispose() {
    // ปิด Stream เมื่อไม่ใช้งาน
    super.dispose();
  }
}
